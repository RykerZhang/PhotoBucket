//
//  storageManager.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/28/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
class storageManager{
    static let shared = storageManager()
    var _storageRef: StorageReference
    private init(){
        _storageRef = Storage.storage().reference()
        
    }
    func uploadProfilePhoto(uid: String, image: UIImage) {
        guard let imageData = ImageUtils.resize(image: image) else {
            print("Converting the image to data failed!")
            return
        }
        
        let photoRef = _storageRef.child(kUserPath).child(uid)
        photoRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print("There was an error uploading the image \(error)")
                return
            }
            print("updated complete")
            
            photoRef.downloadURL { downloadURL, error in
                if let error = error{
                    print("There was an error getting the download URL \(error)")
                    return
                }
                print("Get the download URL \(downloadURL?.absoluteString)")
                UserManager.shared.updatePhotoUrl(PhotoUrl: downloadURL?.absoluteString ?? "")
            }
        }
    }
    
    func uploadPhotoBucketPhoto(caption: String, image: UIImage){
        guard let imageData = ImageUtils.resize(image: image) else {
            print("Converting the image to data failed!")
            return
        }
        let photoRef = _storageRef.child(kPhotoCollectionPath).child(caption)
        photoRef.putData(imageData, metadata: nil){metadata, error in
            if let error = error{
                print("There was an error uploading the image \(error)")
                return
            }
            print("updated complete")
            photoRef.downloadURL{ downloadURL, error in
                if let error = error{
                    print("There was an error getting the download URL \(error)")
                    return
                }
                print("Get the download URL \(downloadURL?.absoluteString)")
                photoBucketDocumentManager.shared.updatePhotoUrl(PhotoUrl: downloadURL!.absoluteString)
                
            }
        }
    }
}
