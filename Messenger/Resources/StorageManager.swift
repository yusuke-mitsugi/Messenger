//
//  StorageManager.swift
//  Messenger
//
//  Created by Yusuke Mitsugi on 2020/06/17.
//  Copyright © 2020 Yusuke Mitsugi. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init(){}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images\(fileName)").putData(data, metadata: nil) {[weak self] (metadata, error) in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                //エラー
                print("upload失敗")
                completion(.failure(StorageErrors.faildToUpload))
                return
            }
            strongSelf.storage.child("images\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("ダウンロードURLの取得失敗")
                    completion(.failure(StorageErrors.faildToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("ストレージからURLが返された: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public func uploadMessagePhoto(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion) {
           storage.child("message_images/\(fileName)").putData(data, metadata: nil) {[weak self] (metadata, error) in
               guard error == nil else {
                   //エラー
                   print("upload失敗")
                   completion(.failure(StorageErrors.faildToUpload))
                   return
               }
               self?.storage.child("message_images/\(fileName)").downloadURL { (url, error) in
                   guard let url = url else {
                       print("ダウンロードURLの取得失敗")
                       completion(.failure(StorageErrors.faildToGetDownloadUrl))
                       return
                   }
                   let urlString = url.absoluteString
                   print("ストレージからURLが返された: \(urlString)")
                   completion(.success(urlString))
               }
           }
       }
    
    public func uploadMessageVideo(with fileUrl: URL,fileName: String, completion: @escaping UploadPictureCompletion) {
           storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) {[weak self] (metadata, error) in
               guard error == nil else {
                   //エラー
                   print("ムービーのupload失敗")
                   completion(.failure(StorageErrors.faildToUpload))
                   return
               }
               self?.storage.child("message_videos/\(fileName)").downloadURL { (url, error) in
                   guard let url = url else {
                       print("ダウンロードURLの取得失敗")
                       completion(.failure(StorageErrors.faildToGetDownloadUrl))
                       return
                   }
                   let urlString = url.absoluteString
                   print("ストレージからURLが返された: \(urlString)")
                   completion(.success(urlString))
               }
           }
       }

    public enum StorageErrors: Error {
        case faildToUpload
        case faildToGetDownloadUrl
    }
    
    public func downloadURL(for path: String,  completion: @escaping (Result<URL, Error>) -> Void) {
        let referennce = storage.child(path)
        referennce.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.faildToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    
}
