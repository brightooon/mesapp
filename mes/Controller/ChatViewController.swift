//
//  ChatViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
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
        messagesCollectionView.messageCellDelegate = self
        //messagesCollectionView.delegate = self
        messageInputBar.delegate = self
        setInputButton()
    }
    
    private func setInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 38, height: 38), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside{ [weak self] _ in
            self?.presentInputaction()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    private func presentInputaction(){
        let action = UIAlertController(title: "Media", message: "", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self] _ in
            self?.presentPhotoinputAction()
        }))
        action.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoinputAction()
        }))
        action.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
    }
    
    private func presentPhotoinputAction(){
        let action = UIAlertController(title: "Photo", message: "", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] _ in
            let pick = UIImagePickerController()
            pick.sourceType = .camera
            pick.delegate = self
            pick.mediaTypes = ["public.movie"]
            pick.videoQuality = .typeMedium
            pick.allowsEditing = true
            self?.present(pick, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let pick = UIImagePickerController()
            pick.sourceType = .photoLibrary
            pick.delegate = self
            pick.mediaTypes = ["public.movie"]
            pick.videoQuality = .typeMedium
            pick.allowsEditing = true
            self?.present(pick, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
    }
    
    private func presentVideoinputAction(){
        let action = UIAlertController(title: "Video", message: "", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] _ in
            let pick = UIImagePickerController()
            pick.sourceType = .camera
            pick.delegate = self
            pick.allowsEditing = true
            self?.present(pick, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let pick = UIImagePickerController()
            pick.sourceType = .photoLibrary
            pick.delegate = self
            pick.allowsEditing = true
            self?.present(pick, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
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
                        self?.messagesCollectionView.scrollToLastItem()
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let imagedata = image.pngData(),
              let messageID = createMessageID(),
              let conversationID = conversationID,
              let name = self.title,
              let selfsender = selfsender else{
            return
        }
        let filename = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + "_png"
        /// upload image and send message
        StorageSet.shared.uploadMessagephoto(with: imagedata, fileName: filename , completion: { [weak self] result in
            guard let strongself = self else{
                return
            }
            switch result{
            case .success(let urlString):
                print("uploaded message photo: \(urlString)")
                guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else{
                    return
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                let message = Message(sender: selfsender, messageId: messageID, sentDate: Date(), kind: .photo(media))
                
                databaseset.shared.sendMessage(to: conversationID, anotheremail: strongself.anotheremail, name: name, message: message, completion: { success in
                    if success {
                        print("sent photo")
                    }
                    else{
                        print("failed to send photo")
                    }
                })
            case .failure(let error):
                print("photo upload error: \(error)")
            }
        })
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
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else{
                return
            }
            imageView.sd_setImage(with: imageURL, completed: nil)
        default:
            break
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension ChatViewController: MessageCellDelegate{
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else{
                return
            }
            let vc = PhotoViewController(with: imageURL)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
