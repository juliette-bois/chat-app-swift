//
//  ChatViewController.swift
//  Messages
//
//  Created by Juliette Bois on 03.02.21.
//

import UIKit
import InputBarAccessoryView
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var receiver: SenderType
    var message: String
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate, InputBarAccessoryViewDelegate {
    

    var currentUser: Sender!
    var otherUser: Sender!

    var messages = [MessageType]()
    
    let formatter = DateFormatter()
    
    public var messageWebSocket: WebSocketClass!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageWebSocket = WebSocketClass(url: "ws://127.0.0.1:9081/\(self.title ?? "")")
        messageWebSocket.establishConnection()
        messageWebSocket.setReceiveTextMethod(receiveTextMethod: {[self] text in
            let split = text.split(separator: "$")
            print(split)
            if (split.count > 1) {
                messages = split.map({value in
                    return fromString(message: String(value))
                })
                messagesCollectionView.reloadData()
                DispatchQueue.main.async {
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            } else if (text != "") {
                self.insertNewMessage(fromString(message: text))
            }
        })
        formatter.dateStyle = .short
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
        messageInputBar.delegate = self
    }
    
    func toString(message: Message) -> String {
        "#\(toEnumKind(kind: message.kind))|\(message.message)|\(message.receiver.displayName)|\(formatter.string(from:message.sentDate))|\(message.sender.displayName)"
    }
    
    func toEnumKind(kind: MessageKind) -> String {
        switch (kind) {
            case .text:
                return "#0"
            case .video:
                return "#1"
            case .audio:
                return "#2"
            default:
                return "#0"
        }
    }
    
    func fromEnumKind(kind: String, value: Any) -> MessageKind {
        switch kind {
        case "#0":
            return .text(value as! String)
        case "#1":
            return .video(value as! MediaItem)
        case "#2":
            return .audio(value as! AudioItem)
        default:
            return .text(value as! String)
        }
    }
        
    func fromString(message: String) -> Message {
        let split = message.components(separatedBy: "|")
        _ = (split[2] == currentUser.displayName ? currentUser : otherUser)
        return Message(sender: (split[4] == currentUser.displayName ? currentUser : otherUser),
                       messageId: "#\(incrementID())",
                       sentDate: Date(),
                       kind: fromEnumKind(kind: split[0], value: split[1]),
                       receiver: (split[2] == currentUser.displayName ? currentUser : otherUser),
                       message: split[1])
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        

        let message = Message(sender: currentUser,
                              messageId: "#\(incrementID())",
                              sentDate: Date(),
                              kind: .text(text),
                              receiver: otherUser,
                              message: text)
        
        insertNewMessage(message)
        
        messageWebSocket.write(text: toString(message: message))

        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
        
        print(message)
    }
    
    var index:Int = 0
    private func incrementID() -> Int {
        index += 1
        return index
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.reloadData()

        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    

    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }


    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
