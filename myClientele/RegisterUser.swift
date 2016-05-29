//
//  RegisterUser.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/29/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import Foundation

func registerUserDeviceId() {
    
    if backendless.messagingService.getRegistration().deviceId != nil {
        
        let deviceId = backendless.messagingService.getRegistration().deviceId
        
        let properties = ["deviceId" : deviceId]
        
        backendless.userService.currentUser!.updateProperties(properties)
        backendless.userService.update(backendless.userService.currentUser)
        
    }
}

func updateBackendlessUser(avatarUrl: String) {
    
    var properties: [String: String]
    
    if backendless.messagingService.getRegistration().deviceId != nil {
        let deviceId = backendless.messagingService.getRegistration().deviceId
        
        properties = ["Avatar" : avatarUrl, "deviceId" : deviceId]
        
    } else {
        properties = ["Avatar" : avatarUrl]
    }
    
    
    
    
    
    backendless.userService.currentUser.updateProperties(properties)
    
    backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser : BackendlessUser!) -> Void in
        
        print("new user id is : \(updatedUser)")
        
        }) { (fault : Fault!) -> Void in
            print("Error could not update the devices id: \(fault)")
    }
}

func removeDeviceIdFromUser() {
    
    let properties = ["deviceId" : ""]
    
    backendless.userService.currentUser!.updateProperties(properties)
    backendless.userService.update(backendless.userService.currentUser)
}
