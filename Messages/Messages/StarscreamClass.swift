//
//  StarscreamClass.swift
//  Messages
//
//  Created by Juliette Bois on 04.02.21.
//

import Foundation
import Starscream

class WebSocketClass: NSObject, WebSocketDelegate {
    
    public var socket: WebSocket!
    public var isConnected = false
    public var connectionMethod: () -> Void = {}
    public var deconnectionMethod: () -> Void = {}
    public var receiveTextMethod: (String) -> Void = { _ in }
    public var request: URLRequest!
    
    init(url: String) {
        super.init()
        
        request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func setReceiveTextMethod(receiveTextMethod: ((String) -> Void)?) {
        self.receiveTextMethod = receiveTextMethod ?? { _ in }
    }
    
    func setConnectionMethod(connectionMethod: (() -> Void)?) {
        self.connectionMethod = connectionMethod ?? { }
    }
    
    func write(text: String) {
        print("write\(text)")
        socket.write(string: text)
    }
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            connectionMethod()
        case .disconnected(let reason, let code):
            deconnectionMethod()
            print("websocket is disconnected: \(reason) with code: \(code)")
            isConnected = false
        case .text(let string):
            print("Received text: \(string)")
            self.receiveTextMethod(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}
