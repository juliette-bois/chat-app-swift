//
//  Server.swift
//  Server
//
//  Created by Juliette Bois on 04.02.21.
//

import Foundation
import Swifter
import Dispatch

class Server: NSObject {
    
    var server = HttpServer()
    var roomList:[String] = []
    var roomMessage = [String : [String]]()
    
    func start() {
        initListRoom()
        initCreateRoom()
        server["/"] = scopes {
          html {
            body {
              center {
                img { src = "https://swift.org/assets/images/swift.svg" }
              }
            }
          }
        }
        server["/files/:path"] = directoryBrowser("/")

        let semaphore = DispatchSemaphore(value: 0)
        do {
          try server.start(9081, forceIPv4: true)
          print("Server has started ( port = \(try server.port()) ). Try to connect now...")
          semaphore.wait()
        } catch {
          print("Server start error: \(error)")
          semaphore.signal()
        }
    }
    
    func stop() {
        server.stop()
    }
    
    func initListRoom() {
        server["/roomList"] = websocket(binary: { session, binary in
            session.writeBinary(binary)
        }, connected: {[self] session in
            print("connection to list room socket")
            session.writeText(roomList.joined(separator: "|"))
        })
    }
    
    func initCreateRoom() {
        server["/roomCreation"] = websocket(text: { [self] sessionCreation, textCreation in
            print("received text: \(textCreation)")
            // "Creation|NomDeLaRoom"
            
            let tab = textCreation.components(separatedBy: "|")
            let action = tab[0]
            let roomName = tab[1]
            if action == "Creation" {
                roomList.append(roomName)
                createCommunicationSocket(roomName: roomName)
                sessionCreation.writeText("Creation|OK|\(roomName)")
            }
            
        }, binary: { session, binary in
            print("received binary: \(binary)")
          session.writeBinary(binary)
        }, connected: {session in
            // get socketsession
            print("connection to create room socket")
        })
    }
    
    func createCommunicationSocket(roomName:String) {
        var socketSessions = [Int : WebSocketSession]()
        server["/\(roomName)"] = websocket(text: { [self] session, text in
            print("received : \(text)")
            let message = MessageObject(message: text)
            roomMessage[roomName]!.append(text)
            for (_, _session) in socketSessions
            {
                if (_session == session) {
                    continue;
                }
                _session.writeText(message.toString())
            }
        }, binary: { session, binary in
            print("received binary: \(binary)")
            session.writeBinary(binary)
        }, connected: {[self] session in
            print("connection to room \(roomName)")
            // get socketsession
            if (socketSessions[session.hashValue] == nil) {
                socketSessions[session.hashValue] = session
            }
            // send all messages at connection
            if (roomMessage[roomName] == nil) {
                roomMessage[roomName] = []
            }
            session.writeText(roomMessage[roomName]!.joined(separator: "$") ?? "")
        }, disconnected: { (session) in
            // remove socket sessions when disconnected
            socketSessions.removeValue(forKey: session.hashValue)
        })
    }
}
