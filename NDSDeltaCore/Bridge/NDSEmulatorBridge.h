//
//  NDSEmulatorBridge.h
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeltaCore/DeltaCore.h>
#import <DeltaCore/DeltaCore-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDSEmulatorBridge : NSObject <DLTAEmulatorBridging>

@property (class, nonatomic, readonly) NDSEmulatorBridge *sharedBridge;

@property (nonatomic) CGPoint HACK_touchPoint;

@end

NS_ASSUME_NONNULL_END
