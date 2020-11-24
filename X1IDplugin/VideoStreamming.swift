//
//  VideoStreamming.swift
//  X1IDplugin
//
//  Created by admin on 11/24/20.
//

import Foundation



public class VideoStreamming{
    public init(){}
    public func verifyPermissions(){
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
    return true
} else {
    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
        if granted {
           return true
        } else {
            return false
        }
    })
}
    }
    public func requestPermissions(){
        var locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      
    }

}
