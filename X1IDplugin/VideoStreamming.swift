//
//  VideoStreamming.swift
//  X1IDplugin
//
//  Created by admin on 11/24/20.
//

import Foundation
import UIKit
import Starscream
import WebRTC
import UIKit

public class VideoStreamming: WebSocketDelegate, WebRTCClientDelegate, CameraSessionDelegate {
  
    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    var tryToConnectWebSocket: Timer!
    var cameraSession: CameraSession?
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    
    // Constants
    // MARK: Change this ip address in your case
    let ipAddress: String = "192.168.0.80:8080"
    let wsStatusMessageBase = "WebSocket: "
    let webRTCStatusMesasgeBase = "WebRTC: "
    let likeStr: String = "Like"
    
    
    //MARK: - ViewController Override Methods
    public func startConnecion() {
        #if targetEnvironment(simulator)
        // simulator does not have camera
        self.useCustomCapturer = false
        #endif
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
        webRTCClient.setup(videoTrack: true, audioTrack: true, dataChannel: true, customFrameCapturer: useCustomCapturer)
        
        if useCustomCapturer {
            print("--- use custom capturer ---")
            self.cameraSession = CameraSession()
            self.cameraSession?.delegate = self
            self.cameraSession?.setupSession()
            
        }
        
        socket = WebSocket(url: URL(string: "ws://" + ipAddress + "/")!)
        socket.delegate = self
        
        tryToConnectWebSocket = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.webRTCClient.isConnected || self.socket.isConnected {
                return
            }
            
            self.socket.connect()
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    // MARK: - WebRTC Signaling
    private func sendSDP(sessionDescription: RTCSessionDescription){
        do {
            
            if self.socket.isConnected {
                self.socket.write(string: "message")
            }
        }catch{
            print(error)
        }
    }
    
    private func sendCandidate(iceCandidate: RTCIceCandidate){
        do {
            
            if self.socket.isConnected {
                self.socket.write(string: "message")
            }
        }catch{
            print(error)
        }
    }
    


// MARK: - WebSocket Delegate

    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("-- websocket did connect --")
        
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
       
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
         
        do{
            let signalingMessage = try text.data(using: .utf8)!
            
            print(signalingMessage)
        }catch{
            print(error)
        }
        
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }


// MARK: - WebRTCClient Delegate
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        self.sendCandidate(iceCandidate: iceCandidate)
    }
    
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState) {
        var state = ""
        
        switch iceConnectionState {
        case .checking:
            state = "checking..."
        case .closed:
            state = "closed"
        case .completed:
            state = "completed"
        case .connected:
            state = "connected"
        case .count:
            state = "count..."
        case .disconnected:
            state = "disconnected"
        case .failed:
            state = "failed"
        case .new:
            state = "new..."
        }
    }
    
    func didConnectWebRTC() {
        // MARK: Disconnect websocket
        self.socket.disconnect()
    }
    
    func didDisconnectWebRTC() {
        
    }
    
    func didOpenDataChannel() {
        print("did open data channel")
    }
    
    func didReceiveData(data: Data) {
        if data == likeStr.data(using: String.Encoding.utf8) {
            print(data)
        }
    }
    
    func didReceiveMessage(message: String) {
        print(message)
    }


// MARK: - CameraSessionDelegate
  func didOutput(_ sampleBuffer: CMSampleBuffer) {
        if self.useCustomCapturer {
            if let cvpixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
                 self.webRTCClient.captureCurrentFrame(sampleBuffer:cvpixelBuffer )
                
            }else{
                print("no pixelbuffer")
            }
            //            self.webRTCClient.captureCurrentFrame(sampleBuffer: buffer)
        }
    }


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
}
