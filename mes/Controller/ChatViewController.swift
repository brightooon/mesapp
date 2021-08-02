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
    private var messages = [Message]()
    private var selfsender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        return Sender(photoURL: "", senderId: email, displayName: "Some")
    }
    
    init(with email: String){
        self.anotheremail = email
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfsender = self.selfsender, let messageID = createMessageID() else{
            return
        }
        print("Sending: \(text)")
        //send message
        if isNewchat {
            //create con in database
            let message = Message(sender: selfsender, messageId: messageID, sentDate: Date(), kind: .text(text))
            databaseset.shared.createConversation(with: anotheremail,firstMessage: message, completion: { success in
                if success {
                    print("sent")
                }else{
                    print("failed")
                }
            })
        }
        else{
           //append the existing conversation data
        }
    }
    
    private func createMessageID() -> String? {
        //date, anotheremail, senderemail, randomint
       
        guard let useremail = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeemail = databaseset.safeemail(email: useremail as! String)
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
        return Sender(photoURL: "", senderId: "9523", displayName: "Yo")
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
