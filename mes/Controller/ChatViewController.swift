//
//  ChatViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import UIKit
import MessageKit

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType{
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    private let selfsender = Sender(photoURL: "", senderId: "1", displayName: "Yourself")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfsender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
        messages.append(Message(sender: selfsender, messageId: "1", sentDate: Date(), kind: .text("me")))
        view.backgroundColor = .systemTeal
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return selfsender
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
