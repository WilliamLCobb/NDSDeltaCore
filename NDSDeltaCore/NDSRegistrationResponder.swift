//
//  NDSRegistrationResponder.swift
//  NDSDeltaCore
//
//  Created by Will Cobb on 8/23/17.
//  Copyright © 2017 Will Cobb. All rights reserved.
//

import Foundation

public class NDSRegistrationResponder: NSObject
{
    public class func handleDeltaRegistrationRequest(_ notification: Notification)
    {
        guard let object = notification.object else { return }
        
        // unsafeBitCast needed for Swift Playground support
        let response = unsafeBitCast(object, to: Delta.RegistrationResponse.self)
        response.handler(NDS.core)
    }
}
