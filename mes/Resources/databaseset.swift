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
    public func insert(with user: chatuser){
        database.child(user.safeemail).setValue([
            "first_name": user.firstname,
            "last_name": user.lastname
        ])
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
}

