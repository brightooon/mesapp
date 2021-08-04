//
//  ChatViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
extension MessageKind{
    var description: String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
struct Sender: SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    public static var dateFormat: DateFormatter = {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .medium
        format.locale = .current
        return format
    }()
    
    public var isNewchat = false
    public var anotheremail: String
    private var conversationID: String?
    private var messages = [Message]()
    private var selfsender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeemail = databaseset.safeemail(email: email)
        return Sender(photoURL: "", senderId: safeemail, displayName: "Me")
    }
    
    init(with email: String, id: String?){
        self.anotheremail = email
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    private func listenMessage(id: String, shouldScrollToBottom: Bool){
        databaseset.shared.getMessageInConversation(with: id, completion: { [weak self] result in
            switch result{
            case .success(let messages):
                print("success getting messages: \(messages)")
                guard !messages.isEmpty else{
                    print("empty message")
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        //self?.messagesCollectionView.scrollToLastItem()
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("failed: \(error)")
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationID{
            listenMessage(id: conversationID, shouldScrollToBottom: true)
        }
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfsender = self.selfsender, let messageID = createMessageID() else{
            return
        }
        print("Sending: \(text)")
        let message = Message(sender: selfsender, messageId: messageID, sentDate: Date(), kind: .text(text))
        //send message
        if isNewchat {
            //create con in database
            databaseset.shared.createConversation(with: anotheremail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("sent")
                    self?.isNewchat = false
                }else{
                    print("failed")
                }
            })
        }
        else{
           //append the existing conversation data
            guard let conversationID = conversationID, let name = self.title else{
                return
            }
            databaseset.shared.sendMessage(to: conversationID, anotheremail: anotheremail ,name: name, message: message, completion: { success in
                if success{
                    print("message sent")
                }
                else{
                    print("failed sent")
                }
            })
        }
    }
    
    private func createMessageID() -> String? {
        //date, anotheremail, senderemail, randomint
       
        guard let useremail = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeemail = databaseset.safeemail(email: useremail)
        let date = Self.dateFormat.string(from: Date())
        let newidentifier = "\(anotheremail)_\(safeemail)_\(date)"
        print("created messgae ID: \(newidentifier)")
        return newidentifier
    }
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfsender{
            return sender
        }
        fatalError("Self Sender is nil, email not cached")
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
