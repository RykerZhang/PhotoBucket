//
//  photoDetailController.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/12/22.
//

//import Foundation
import UIKit
import Firebase
class photoDetailController: UIViewController{
    @IBOutlet weak var photoDisplay: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    //var tphotoBucket : photoBucket?
    var photoListenerRegistration: ListenerRegistration?
    var photoBucketDocumentId: String!
    var userListenerRegistration: ListenerRegistration?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(showEditDialog))
        updateView()
    }
    
    func showOrHideEditButton(){
        if(AuthManager.shared.currentUser?.uid == photoBucketDocumentManager.shared.latestPhoto?.authorUid){
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showEditDialog))
        }else{
            print("This is not yours, don't allow dit")
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoListenerRegistration = photoBucketDocumentManager.shared.startListening(for: photoBucketDocumentId!){
            print("TODO")
            self.updateView()
            self.showOrHideEditButton()
            
            self.stackView.isHidden = true
            if let authorUid = photoBucketDocumentManager.shared.latestPhoto?.authorUid{
                UserManager.shared.stopListening(self.userListenerRegistration)
                self.userListenerRegistration = UserManager.shared.startListening(for: authorUid){
                    self.updateAuthorBox()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoBucketDocumentManager.shared.stopListening(photoListenerRegistration)
    }
    
    func updateView(){

    //TODO: Update the view using the manager's data
        if let photo = photoBucketDocumentManager.shared.latestPhoto{
            captionLabel.text = photo.caption
//            if let imgUrl = URL(string: photo.url) {
//                    DispatchQueue.global().async { // Download in the background
//                      do {
//                          print("The url is :\(photo.url)")
//                        let data = try Data(contentsOf: imgUrl)
//                        DispatchQueue.main.async { // Then update on main thread
//                          self.photoDisplay.image = UIImage(data: data)
//                        }
//                      } catch {
//                        print("Error downloading image: \(error)")
//                      }
//                    }
//                  }
            ImageUtils.load(imageView: photoDisplay, from: photoBucketDocumentManager.shared.latestPhoto!.url)


        }
    }
    
    @objc func showEditDialog(){
        let alertController = UIAlertController(title: "Edit this photo", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Caption in"
            textField.text = photoBucketDocumentManager.shared.latestPhoto?.caption
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "URL in"
            textField.text = photoBucketDocumentManager.shared.latestPhoto?.url
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil )
        
        let editAction = UIAlertAction(title: "Submit ", style: UIAlertAction.Style.default){ UIAlertAction in
            let captionTextField = alertController.textFields![0] as UITextField
            let URLTextField = alertController.textFields![1] as UITextField
          //  let photo = photoBucket(caption: captionTextField.text!, url: URLTextField.text!)
         //   self.tphotoBucket?.caption = captionTextField.text!
          //  self.tphotoBucket?.url = URLTextField.text!
            photoBucketDocumentManager.shared.update(url: URLTextField.text!, caption: captionTextField.text!)
            self.updateView()

        }
        alertController.addAction(editAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        updateView()
    }
    
    func updateAuthorBox(){
        self.stackView.isHidden   = UserManager.shared.name.isEmpty && UserManager.shared.photoUrl.isEmpty
        nameLabel.text = UserManager.shared.name
        if !UserManager.shared.photoUrl.isEmpty{
            ImageUtils.load(imageView: imageView, from: UserManager.shared.photoUrl)
        }
    }
}
