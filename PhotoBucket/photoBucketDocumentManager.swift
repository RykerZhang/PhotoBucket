//
//  photoBucketDocumentManager.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/12/22.
//

import Foundation
import Firebase

class photoBucketDocumentManager{
    var latestPhoto: photoBucket?
    static let shared = photoBucketDocumentManager()
    var _collectionRef: CollectionReference
    
    private init(){
        _collectionRef = Firestore.firestore().collection(kPhotoCollectionPath)
    }
    
    func startListening(for documentId: String, changeListener: @escaping (()-> Void))->ListenerRegistration{
        let query = _collectionRef.document(documentId)
        return query.addSnapshotListener{documentSnapshot, error in
            guard let document = documentSnapshot else{
                return
            }
            guard let data = document.data() else{
                return
            }
            self.latestPhoto = photoBucket(documentSnapshot:document)
            changeListener()
        }
    }
    func stopListening(_ listenerRegistration: ListenerRegistration?){
        listenerRegistration?.remove()
    }
    
    func update(url: String, caption: String){
         
        _collectionRef.document(latestPhoto!.documentId!).updateData([
            kPhotoURL: url,
            kPhotoCaption: caption,
            kCreateTime: Timer.init(),]){
                err in
                if let err = err{
                    print("Error uodateing: \(err)")
                }else{
                    print("Document updated")
                }
            }
    }

}
