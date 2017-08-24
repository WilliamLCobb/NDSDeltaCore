//
//  NDS.swift
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17
//  Copyright © 2017 Will Cobb. All rights reserved.
//

import Foundation

public extension GameType
{
    public static let nds = GameType("com.rileytestut.delta.game.nds")
}

public struct NDS: DeltaCoreProtocol
{
    public static let core = NDS()
    
    public let bundleIdentifier: String = "com.rileytestut.NDSDeltaCore"
    
    public let supportedGameTypes: Set<GameType> = [.nds]
    
    public let emulatorBridge: EmulatorBridging = NDSEmulatorBridge.shared
    
    public let emulatorConfiguration: EmulatorConfiguration = NDSEmulatorConfiguration()
    
    public let inputTransformer: InputTransforming = NDSInputTransformer()
    
    private init()
    {
    }
    
}
