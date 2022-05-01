//
//  photoBucketCollectionManager.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/12/22.
//

import Foundation
import Firebase

class photoBucketCollectionManager{
    static let shared = photoBucketCollectionManager()
    var _collectionRef: CollectionReference
    private init(){
        _collectionRef = Firestore.firestore().collection(kPhotoCollectionPath)
    }
    var latestPhotoBuckets = [photoBucket]()
    
    func startListening(filterByAuthor authorFilter: String?, changeListener: @escaping (()-> Void))->ListenerRegistration{
        
       
        
        var query = _collectionRef.order(by: kCreateTime, descending: true).limit(to:50)
        
        if let authorFilter = authorFilter {
            query = query.whereField(kPhotoBucketUID, isEqualTo: authorFilter)
        }
        
         return query.addSnapshotListener{querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
               //print("error")
                return
            }
            self.latestPhotoBuckets.removeAll()
            for document in documents{
              //  print("\(document.documentID) => \(document.data())")
                self.latestPhotoBuckets.append(photoBucket(documentSnapshot:document))
            }
            changeListener()
        }
    }
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    func add(_ photo: photoBucket){
        _collectionRef.addDocument(data: [
            kPhotoCaption: photo.caption,
            kPhotoURL: photo.url,
            kCreateTime: Timestamp.init(),
            kPhotoBucketUID: AuthManager.shared.currentUser!.uid
        ]){ err in
            if let err = err{
                //print("Error adding document \(err)")
            }
        }
    }
    func delete(_ documentId: String){
        _collectionRef.document(documentId).delete() { err in
            if let err = err {
               // print("Error removing document: \(err)")
            } else {
                //print("Document successfully removed!")
            }
        }
    }
}

