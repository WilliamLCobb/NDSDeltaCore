//
//  NDSInputTransformer.swift
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

import Foundation

import DeltaCore

@objc public enum NDSGameInput: Int, Input
{
    case up = 8
    case down = 4
    case left = 2
    case right = 1
    case a = 128
    case b = 64
    case x = 512
    case y = 256
    case l = 1024
    case r = 2048
    case start = 32
    case select = 16
    case lid = 4096
    case touch = 8192
}

public struct NDSInputTransformer: InputTransforming
{
    public var gameInputType: Input.Type = NDSGameInput.self
    
    public func inputs(for controllerSkin: ControllerSkin, item: ControllerSkin.Item, point: CGPoint) -> [Input]
    {
        var inputs: [Input] = []
        
        for key in item.keys
        {
            print("Key:", key)
            switch key
            {
            case "touch":
                let bridge: NDSEmulatorBridge = NDSEmulatorBridge.shared
                bridge.hack_touchPoint = point
                print(bridge)
                inputs.append(NDSGameInput.touch)
                
            case "dpad":
                let topRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width, height: item.frame.height / 3.0)
                let bottomRect = CGRect(x: item.frame.minX, y: item.frame.maxY - item.frame.height / 3.0, width: item.frame.width, height: item.frame.height / 3.0)
                let leftRect = CGRect(x: item.frame.minX, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                let rightRect = CGRect(x: item.frame.maxX - item.frame.width / 3.0, y: item.frame.minY, width: item.frame.width / 3.0, height: item.frame.height)
                
                if topRect.contains(point)
                {
                    inputs.append(NDSGameInput.up)
                }
                
                if bottomRect.contains(point)
                {
                    inputs.append(NDSGameInput.down)
                }
                
                if leftRect.contains(point)
                {
                    inputs.append(NDSGameInput.left)
                }
                
                if rightRect.contains(point)
                {
                    inputs.append(NDSGameInput.right)
                }
                
            case "a": inputs.append(NDSGameInput.a)
            case "b": inputs.append(NDSGameInput.b)
            case "x": inputs.append(NDSGameInput.x)
            case "y": inputs.append(NDSGameInput.y)
            case "l": inputs.append(NDSGameInput.l)
            case "r": inputs.append(NDSGameInput.r)
            case "start": inputs.append(NDSGameInput.start)
            case "select": inputs.append(NDSGameInput.select)
            case "lid": inputs.append(NDSGameInput.lid)
            case "menu": inputs.append(ControllerInput.menu)
            default: break
            }
        }
        
        return inputs
    }
    
    public func inputs(for controller: MFiExternalController, input: MFiExternalControllerInput) -> [Input]
    {
        var inputs: [Input] = []
        
        switch input
        {
        case let .dPad(xAxis: xAxis, yAxis: yAxis): inputs.append(contentsOf: self.inputs(forXAxis: xAxis, YAxis: yAxis))
        case let .leftThumbstick(xAxis: xAxis, yAxis: yAxis): inputs.append(contentsOf: self.inputs(forXAxis: xAxis, YAxis: yAxis))
        case .rightThumbstick(xAxis: _, yAxis: _): break
        case .a: inputs.append(NDSGameInput.a)
        case .b: inputs.append(NDSGameInput.b)
        case .x: inputs.append(NDSGameInput.x)
        case .y: inputs.append(NDSGameInput.y)
        case .l: inputs.append(NDSGameInput.l)
        case .r: inputs.append(NDSGameInput.r)
        case .leftTrigger: inputs.append(NDSGameInput.l)
        case .rightTrigger: inputs.append(NDSGameInput.r)
        }
        
        return inputs
    }
}

private extension NDSInputTransformer
{
    func inputs(forXAxis xAxis: Float, YAxis yAxis: Float) -> [Input]
    {
        var inputs: [Input] = []
        
        if xAxis > 0.0
        {
            inputs.append(NDSGameInput.right)
        }
        else if xAxis < 0.0
        {
            inputs.append(NDSGameInput.left)
        }
        
        if yAxis > 0.0
        {
            inputs.append(NDSGameInput.up)
        }
        else if yAxis < 0.0
        {
            inputs.append(NDSGameInput.down)
        }
        
        return inputs
    }
}
