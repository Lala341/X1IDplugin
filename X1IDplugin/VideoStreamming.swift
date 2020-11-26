//
//  VideoStreamming.swift
//  X1IDplugin
//
//  Created by admin on 11/24/20.
//

import Foundation
import UIKit
import AVFoundation
import SwiftyWebRTC

public class VideoStreamming: RTCClientDelegate{
    public init(){}
    public func verifyPermissions(){
     var ans=false   
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
    ans=true
}
    }
    public func requestPermissions(){
         var ans=false   
       AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
        if response {
            ans=true
        }
    }

    }
    public func sendDataWebRTC(){
        var videoClient: RTCClient?
        var captureController: RTCCapturer!

    }
    public  func configureVideoClient() {
    // You can pass on iceServers your app wanna use 
    // RTCClient can be used for only audio call also where videoCall is by default
      let iceServers: RTCICEServer = RTCICEServer(uri: "http://670e4c8c3ac0.ngrok.io",  username: "", password: "");
        
        let client = RTCClient(iceServers: iceServers, videoCall: true)
        client.delegate = self
        self.videoClient = client
        client.startConnection()
    }
    func rtcClient(client: RTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
    // To handle when camera is not available
        if UIDevice.current.modelName != "Simulator" {
            let settingsModel = RTCCapturerSettingsModel()
            self.captureController = RTCCapturer.init(withCapturer: capturer, settingsModel: settingsModel)
            captureController.startCapture()
        }
    }
    
    func rtcClient(client : RTCClient, didReceiveError error: Error) {
        // Error Received
        }
    }

    func rtcClient(client : RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
     // iceCandidate generated, pass this to other user using any signal method your app uses
    }

    func rtcClient(client : RTCClient, startCallWithSdp sdp: String) {
       // SDP generated, pass this to other user using any signal method your app uses
    }

    func rtcClient(client : RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
    // Use localVideoTrack generated for rendering stream to remoteVideoView
        localVideoTrack.add(self.localVideoView)
        self.localVideoTrack = localVideoTrack
    }
    func rtcClient(client : RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
    // Use remoteVideoTrack generated for rendering stream to remoteVideoView
        remoteVideoTrack.add(self.remoteVideoView)
        self.remoteVideoTrack = remoteVideoTrack
    }
}
