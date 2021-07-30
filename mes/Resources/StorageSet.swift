//
//  StorageSet.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import Foundation
import FirebaseStorage

final class StorageSet {
    static let shared = StorageSet()
    private let storage = Storage.storage().reference()
    
    public typealias uploadPicComplete = (Result<String, Error>) -> Void
    public func uploadProfilePic(with data: Data, fileName: String, completion: @escaping uploadPicComplete){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                //failed
                print("failed to upload pic")
                completion(.failure(StorageErrors.failedupload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("failed to get download url")
                    completion(.failure(StorageErrors.faileddownload))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageErrors: Error {
        case failedupload
        case faileddownload
    }
}
