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

public class VideoStreamming: WebRTCClientDelegate, CameraSessionDelegate {
  
    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    var tryToConnectWebSocket: Timer!
    var cameraSession: CameraSession?
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    
    // Constants
    // MARK: Change this ip address in your case
    let ipAddress: String = "https://3101934a26b1.ngrok.io/offer"
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
        if !webRTCClient.isConnected {
                    webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                        self.sendSDP(sessionDescription: offerSDP)
                    })
                }
        


        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   
    private func sendSDP(sessionDescription: RTCSessionDescription){
       
        var offer = sessionDescription
        let sdp = SDP.init(sdp: sessionDescription.sdp)
        
        var offerData = [
            "sdp": (sdp.sdp as String),
            "type": "offer",
            "video_transform": "No transform",
            "id": "12345",
        ] as [String: Any]

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        let session = URLSession(configuration: configuration)
        
        let url = URL(string: ipAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters = offerData
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                print(error)
                return
            }
            
            do {
                print("The Response are")
                print(data!)
                
                let json = try JSONDecoder().decode(SignalingMessage.self, from: data!)
                print("The Response is : ",json)
                let sdp = (json).sdp;
                
                self.webRTCClient.receiveOffer(offerSDP: RTCSessionDescription(type: .offer, sdp: sdp!), onCreateAnswer: {(answerSDP: RTCSessionDescription) -> Void in
                    self.sendSDP(sessionDescription: answerSDP)
                })

                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
        })
        
        task.resume()
    }


// MARK: - WebRTCClient Delegate
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        // self.sendCandidate(iceCandidate: iceCandidate)
        print("send candidate")
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
        print("did disconect webrec")
    }
    
    func didDisconnectWebRTC() {
        print("didDisconnectWebRTC")
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
