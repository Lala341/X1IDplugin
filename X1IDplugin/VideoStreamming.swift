//
//  VideoStreamming.swift
//  X1IDplugin
//
//  Created by admin on 11/24/20.
//

import Foundation
import UIKit
import AVFoundation


public class VideoStreamming{
    public init(){}
    public func verifyPermissions(){
     var ans=false   
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
    ans=true
} 
return ans
    }
    public func requestPermissions(){
         var ans=false   
       AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
        if response {
            ans=true
        }
    }
return ans
    }
    public func sendDataWebRTC(){

    }
}
