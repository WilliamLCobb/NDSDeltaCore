//
//  NDS.swift
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17
//  Copyright © 2017 Will Cobb. All rights reserved.
//

import Foundation
import AVFoundation

import DeltaCore

public extension GameType
{
    public static let nds = GameType("com.rileytestut.delta.game.nds")
}

public struct NDS: DeltaCoreProtocol
{
    public static let core = NDS()
    
    public let gameType = GameType.nds
    
    public let bundleIdentifier = "com.willcobb.NDSDeltaCore"
    
    public let gameSaveFileExtension = "sav"
    
    public let frameDuration = (1.0 / 60.0)
    
    public let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 32768, channels: 2, interleaved: true)
    
    public let videoFormat = VideoFormat(pixelFormat: .abgr1555, dimensions: CGSize(width: 256, height: 384))
    
    public let supportedCheatFormats: Set<CheatFormat> = {
        let actionReplayFormat = CheatFormat(name: NSLocalizedString("Action Replay", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .actionReplay)
        let gameSharkFormat = CheatFormat(name: NSLocalizedString("GameShark", comment: ""), format: "XXXXXXXX YYYYYYYY", type: .gameShark)
        let codeBreakerFormat = CheatFormat(name: NSLocalizedString("Code Breaker", comment: ""), format: "XXXXXXXX YYYY", type: .codeBreaker)
        return [actionReplayFormat, gameSharkFormat, codeBreakerFormat]
    }()
    
    public let emulatorBridge: EmulatorBridging = NDSEmulatorBridge.shared
    
    public let inputTransformer: InputTransforming = NDSInputTransformer()
    
    private init()
    {
    }
    
}
