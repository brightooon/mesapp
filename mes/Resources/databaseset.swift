//
//  database.swift
//  mes
//
//  Created by Chun Hei Law on 7/24/21.
//

import Foundation
import FirebaseDatabase

final class databaseset{
    static let shared = databaseset()
    private let database = Database.database().reference()
    static func safeemail(email:String) -> String {
        var safeemail = email.replacingOccurrences(of: ".", with: "-")
        safeemail = safeemail.replacingOccurrences(of: "@", with: "-")
        return safeemail
    }
}

extension databaseset{
    public func getdata(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value){ snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.failedFetch))
                return
            }
            completion(.success(value))
        }
    }
}
extension databaseset{
    public func vaildateuser(with email: String, completion: @escaping ((Bool) -> Void )){
        var safeemail = email.replacingOccurrences(of: ".", with: "-")
        safeemail = safeemail.replacingOccurrences(of: "@", with: "-")
        database.child(safeemail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func insert(with user: chatuser, completion: @escaping (Bool)-> Void){
        database.child(user.safeemail).setValue([
            "first_name": user.firstname,
            "last_name": user.lastname
        ], withCompletionBlock: { done, _ in
            guard done == nil else {
                print("failed to write into database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var userCollection = snapshot.value as? [[String: String]] {
                    let newuser = [
                        "name": user.firstname + " " + user.lastname,
                        "email": user.email
                    ]
                    userCollection.append(newuser)
                    self.database.child("users").setValue(userCollection, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstname + " " + user.lastname,
                            "email": user.safeemail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
           // completion(true)
        })
    }
    
    public func alluser(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                print("get users failed")
                completion(.failure(DatabaseError.failedFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error{
        case failedFetch
    }
}
// send messages in conversation
extension databaseset{
    ///create new conservation
    public func createConversation(with anotheremail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentemail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else{
            return
        }
        let safeemail = databaseset.safeemail(email: currentemail)
        let refernce = database.child("\(safeemail)")
        refernce.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var node = snapshot.value as? [String: Any] else{
                completion(false)
                print("not found")
                return
            }
            let messagedate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormat.string(from: messagedate)
            var mes = ""
            switch firstMessage.kind{
            case .text(let messagetext):
                mes = messagetext
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversation: [String: Any] = [
                "id": conversationID,
                "taget_email": anotheremail,
                "name": name,
                "latest_mesage": [
                    "date": dateString,
                    "message": mes,
                    "read": false
                ]
            ]
            let recipientNewConversation: [String: Any] = [
                "id": conversationID,
                "taget_email": safeemail,
                "name": currentName,
                "latest_mesage": [
                    "date": dateString,
                    "message": mes,
                    "read": false
                ]
            ]
            //update recipient conversation
            self?.database.child("\(anotheremail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipientNewConversation)
                    self?.database.child("\(anotheremail)/conversations").setValue(conversations)
                }else{
                    //create
                    self?.database.child("\(anotheremail)/conversations").setValue([recipientNewConversation])
                }
            })
            //update user conversation entry
            if var conversation = node["conversations"] as? [[String: Any]]{
                ///conversation exists for user and do append
                conversation.append(newConversation)
                node["conversations"] = conversation
                refernce.setValue(node, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreate(name: name, ConversationID: conversationID, firstmessage: firstMessage, completion: completion)
                })
            }
            else{
                //conversation array doesn't exist and create it
                node["conversations"] = [
                    newConversation
                ]
                refernce.setValue(node, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreate(name: name, ConversationID: conversationID, firstmessage: firstMessage, completion: completion)
                })
            }
        })
    }
    private func finishCreate(name: String, ConversationID: String, firstmessage: Message, completion: @escaping (Bool) -> Void){
        let messagedate = firstmessage.sentDate
        let dateString = ChatViewController.dateFormat.string(from: messagedate)
        var mes = ""
        switch firstmessage.kind{
        case .text(let messagetext):
            mes = messagetext
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let selfemail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentemail = databaseset.safeemail(email: selfemail)
        let collectionmessage: [String: Any] = [
            "id": firstmessage.messageId,
            "type": firstmessage.kind.description,
            "content": mes,
            "date": dateString,
            "target_email": currentemail,
            "read": false,
            "name": name
        ]
        let value: [String: Any] = [
            "messages": [
            collectionmessage
            ]
        ]
        database.child("\(ConversationID)").setValue( value, withCompletionBlock: { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    ///fetches all conversation for users
    public func getConversation(for email: String, completion: @escaping (Result<[conversation], Error>) -> Void){
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("get conversations failed")
                completion(.failure(DatabaseError.failedFetch))
                return
            }
            let conversations: [conversation] = value.compactMap({ dict in
                guard let conversationID = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let target = dict["taget_email"] as? String,
                      let latestMessage = dict["latest_mesage"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let read = latestMessage["read"] as? Bool else{
                        return nil
                }
                let latestMessageObject = LatestMessage(date: date, text: message, read: read)
                return conversation(id: conversationID, name: name, targetemail: target, latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        })
    }
    public func getMessageInConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        database.child("\(id)/messages").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("get conversations failed")
                completion(.failure(DatabaseError.failedFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dict in
                guard let messageID = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let target = dict["taget_email"] as? String,
                      let dateString = dict["date"] as? String,
                      let date = ChatViewController.dateFormat.date(from: dateString),
                      let message = dict["content"] as? String,
                      let read = dict["read"] as? Bool,
                      let type = dict["type"] as? String else{
                        return nil
                }
                let sender = Sender(photoURL: "", senderId: target, displayName: name)
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(message))
            })
            completion(.success(messages))
        })
        
    }
    public func sendMessage(to conversation: String, anotheremail: String ,name: String, message: Message, completion: @escaping (Bool) -> Void){
            /// update sender and recipient new messages, append new message to message
        guard let myemail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentmyemail = databaseset.safeemail(email: myemail)
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongself = self else{
                return
            }
            guard var currentMessage = snapshot.value as? [[String: Any]] else{
                completion(false)
                return
            }
            let messagedate = message.sentDate
            let dateString = ChatViewController.dateFormat.string(from: messagedate)
            var mes = ""
            switch message.kind{
            case .text(let messagetext):
                mes = messagetext
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let selfemail = UserDefaults.standard.value(forKey: "email") as? String else{
                completion(false)
                return
            }
            let currentemail = databaseset.safeemail(email: selfemail)
            let newmessage: [String: Any] = [
                "id": message.messageId,
                "type": message.kind.description,
                "content": mes,
                "date": dateString,
                "target_email": currentemail,
                "read": false,
                "name": name
            ]
            currentMessage.append(newmessage)
            strongself.database.child("\(conversation)/messages").setValue(currentMessage) { error , _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                strongself.database.child("\(currentmyemail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentconversations = snapshot.value as? [[String: Any]] else{
                        completion(false)
                        return
                    }
                    let updated: [String: Any] = [
                        "date": dateString,
                        "read": false,
                        "message": mes
                    ]
                    var targetConversation: [String: Any]?
                    var position = 0
                    for conversationdict in currentconversations{
                        if let currentID = conversationdict["id"] as? String, currentID == conversation{
                            targetConversation = conversationdict
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updated
                    guard let targetConversation = targetConversation else{
                        completion(false)
                        return
                    }
                    currentconversations[position] = targetConversation
                    strongself.database.child("\(currentmyemail)/conversations").setValue(currentconversations, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        ///update latest for recipent
                        strongself.database.child("\(anotheremail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var targetuserconversations = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                return
                            }
                            let updated: [String: Any] = [
                                "date": dateString,
                                "read": false,
                                "message": mes
                            ]
                            var targetConversation: [String: Any]?
                            var position = 0
                            for conversationdict in targetuserconversations{
                                if let currentID = conversationdict["id"] as? String, currentID == conversation{
                                    targetConversation = conversationdict
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updated
                            guard let targetConversation = targetConversation else{
                                completion(false)
                                return
                            }
                            targetuserconversations[position] = targetConversation
                            strongself.database.child("\(anotheremail)/conversations").setValue(targetuserconversations, withCompletionBlock: { error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                        //completion(true)
                    })
                })
                //completion(true)
            }
        })
    }
}

struct chatuser{
    let firstname: String
    let lastname: String
    let email: String
    var safeemail: String{
        var safeemail = email.replacingOccurrences(of: ".", with: "-")
        safeemail = safeemail.replacingOccurrences(of: "@", with: "-")
        return safeemail
    }
    
    var profilePic: String{
        return "\(safeemail)_profile_picture_png"
    }
}

