//
//  Message.swift
//  Messages
//
//  Created by Juliette Bois on 05/02/2021.
//

import Foundation
import MessageKit

//struct Sender: SenderType {
//    var senderId: String
//    var displayName: String
//}
//
//enum EnumMessageType: String {
//    case text = "#0"
//    case image = "#1"
//    case sound = "#2"
//}
//
//class Message: MessageType {
//    
//    var sender: SenderType
//    
//    var messageId: String
//    
//    var sentDate: Date
//    
//    var kind: MessageKind
//    
//    var hour: String
//    
//    var message: String
//    
//    var messageType: EnumMessageType
//    
//    var receiver: SenderType
//    
//    init(messageType: MessageKind, message: String, receiver: SenderType, hour: String, sender: SenderType) {
//        self.receiver = receiver
//        self.hour = hour
//        self.message = message
//        self.kind = messageType
//        self.sender = sender
//    }
//    
//    init(message: String) {
//        let split = message.components(separatedBy: "|")
//        self.messageType = EnumMessageType(rawValue: split[0]) ?? EnumMessageType(rawValue: "#0")!
//        self.message = split[1]
//        self.receiver = split[2]
//        self.hour = split[3]
//        self.sender = split[4]
//    }
//}
