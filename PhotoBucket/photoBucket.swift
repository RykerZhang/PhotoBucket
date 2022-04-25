//
//  photoBucket.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/12/22.
//

import Foundation
import Firebase
class photoBucket{
    var caption: String
    var url: String
    var documentId: String?
    var authorUid: String?
    
    init(caption:String, url:String){
        self.caption = caption
        self.url = url
    }
    
    init(documentSnapshot: DocumentSnapshot){
        self.documentId = documentSnapshot.documentID
        let data = documentSnapshot.data()
        self.caption = data?[kPhotoCaption] as! String
        self.url = data?[kPhotoURL] as! String
        self.authorUid = data?[kPhotoBucketUID] as? String? ?? ""
    }
}
