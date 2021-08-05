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
                    completion(.failure(StorageErrors.failedgetdownload))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadMessagephoto(with data: Data, fileName: String, completion: @escaping uploadPicComplete){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                //failed
                print("failed to upload pic")
                completion(.failure(StorageErrors.failedupload))
                return
            }
            self.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedgetdownload))
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
        case failedgetdownload
    }
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child(path)
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedgetdownload))
                return
            }
            completion( .success(url))
        })
    }
}
