//
//  NDSEmulatorConfiguration.swift
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

import Foundation
import AVFoundation

import DeltaCore

public struct NDSEmulatorConfiguration: EmulatorConfiguration
{
    public let gameSaveFileExtension: String = "sav"
    
    public var audioBufferInfo: AudioManager.BufferInfo {
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
        
        let bufferInfo = AudioManager.BufferInfo(inputFormat: inputFormat, preferredSize: 2184)
        return bufferInfo
    }
    
    public var videoBufferInfo: VideoManager.BufferInfo {
        let bufferInfo = VideoManager.BufferInfo(inputFormat: .argb1555, inputDimensions: CGSize(width: 256, height: 384), outputDimensions: CGSize(width: 256, height: 384))
        return bufferInfo
    }
    
    public var supportedCheatFormats: [CheatFormat] {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }
    
    public let supportedRates: ClosedRange<Double> = 1...3
}
