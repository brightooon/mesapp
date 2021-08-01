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

