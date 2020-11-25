//
//  VideoStreamming.swift
//  X1IDplugin
//
//  Created by admin on 11/24/20.
//

import Foundation
import UIKit



public class VideoStreamming{
    public init(){}
    public func verifyPermissions(){
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
    return true
} 
    }
    public func requestPermissions(){
       AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
        if response {
            return true
        } else {
            return false
        }
    }

    }
    public func sendDataWebRTC(){
        
    }
}
