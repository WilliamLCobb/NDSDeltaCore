//
//  NDSRegistrationResponder+Dynamic.m
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

#import "NDSRegistrationResponder+Dynamic.h"

@import DeltaCore;

@implementation NDSRegistrationResponder (Dynamic)

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeltaRegistrationRequest:) name:DeltaRegistrationRequestNotification object:nil];
}

@end
