//
//  MessageObject.swift
//  Messages
//
//  Created by Juliette Bois on 04.02.21.
//

import Foundation

enum MessageType: String {
    case text = "#0"
    case image = "#1"
    case sound = "#2"
}

class MessageObject {
    var receiver: String
    var hour: String
    var message: String
    var messageType: MessageType
    var sender: String
    
    init(messageType: MessageType, message: String, receiver: String, hour: String, sender: String) {
        self.receiver = receiver
        self.hour = hour
        self.message = message
        self.messageType = messageType
        self.sender = sender
    }
    
    init(message: String) {
        let split = message.components(separatedBy: "|")
        self.messageType = MessageType(rawValue: split[0]) ?? MessageType(rawValue: "#0")!
        self.message = split[1]
        self.receiver = split[2]
        self.hour = split[3]
        self.sender = split[4]
    }
    
    func toString() -> String {
        return "\(messageType)|\(message)|\(receiver)|\(hour)|\(sender)"
    }
}
