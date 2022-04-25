//
//  tableViewController.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/12/22.
//

import Foundation
import UIKit
import Firebase

class photoBucketViewCell: UITableViewCell{
    
    @IBOutlet weak var captionLabel: UILabel!
}
class tableViewController: UITableViewController{

    let kphotoBucketCell = "photoBucketCell"
    let kdetailSegue = "detailSegue"
    var photoListenerRegistration: ListenerRegistration?
    var isShowingAllPhoto = true;
    var doEdit = true;
    var logoutHandle : AuthStateDidChangeListenerHandle?


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
 //       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showAddPhotoDialog))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action:#selector(showMenu))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningForPhotoBuckets()
//                if(AuthManager.shared.isSignedIn){
//                    print("User is already signed in")
//                }else{
//                    print("No USER.")
//                    AuthManager.shared.signInAnonymously()
//                }
        
//        photoListenerRegistration = photoBucketCollectionManager.shared.startListening{
//            print("The photo were updated")
//            for photo in photoBucketCollectionManager.shared.latestPhotoBuckets{
//                print("\(photo.caption)")
//            }
//            self.tableView.reloadData()
//        }
        logoutHandle = AuthManager.shared.addLogoutObserver(callback: {print("Someone signed out")
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photoBucketCollectionManager.shared.stopListening(photoListenerRegistration)
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let addPhoto = UIAlertAction(title: "Add Photo", style: UIAlertAction.Style.default) { UIAlertAction in
            self.showAddPhotoDialog()
        }
        
        let showMyPhoto = UIAlertAction(title: isShowingAllPhoto ? "Show my Photo" : "Show all photos", style: UIAlertAction.Style.default) { UIAlertAction in
            self.isShowingAllPhoto = !self.isShowingAllPhoto
            self.startListeningForPhotoBuckets()
        }
        
        let signOut = UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default) { UIAlertAction in
            print("You signed out")
            AuthManager.shared.signOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in
        }
        
        let edit = UIAlertAction(title: !isEditing ? "Edit" : "End Editing", style: UIAlertAction.Style.default){
            UIAlertController in
            self.isEditing = !self.isEditing
        }
        alertController.addAction(addPhoto)

        alertController.addAction(showMyPhoto)

        alertController.addAction(signOut)
        alertController.addAction(edit)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func showAddPhotoDialog(){
        let alertController = UIAlertController(title: "Add a new photo", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Caption in"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "URL in"
        }
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil )
        
        let submitAction = UIAlertAction(title: "Create ", style: UIAlertAction.Style.default){ UIAlertAction in
            let captionTextField = alertController.textFields![0] as UITextField
            let URLTextField = alertController.textFields![1] as UITextField
            let photo = photoBucket(caption: captionTextField.text!, url: URLTextField.text!)
            photoBucketCollectionManager.shared.add(photo)

            //self.photoBuckets.insert(photo, at: 0)
            self.tableView.reloadData()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in

        }
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    
    }
    
    func startListeningForPhotoBuckets(){
        stopListeningForPhotoBuckets()
        photoListenerRegistration = photoBucketCollectionManager.shared.startListening(filterByAuthor: isShowingAllPhoto ? nil: AuthManager.shared.currentUser?.uid, changeListener: {
            self.tableView.reloadData()
        })
    }
    
    func stopListeningForPhotoBuckets(){
        photoBucketCollectionManager.shared.stopListening(photoListenerRegistration)
    }
    
        //delete the own pb
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let pb = photoBucketCollectionManager.shared.latestPhotoBuckets[indexPath.row]
        return AuthManager.shared.currentUser?.uid==pb.authorUid
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoBucketCollectionManager.shared.latestPhotoBuckets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kphotoBucketCell, for: indexPath) as! photoBucketViewCell
        let photo = photoBucketCollectionManager.shared.latestPhotoBuckets[indexPath.row]
        cell.captionLabel.text = photo.caption
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //movieQuotes.remove(at: indexPath.row)
            //tableView.reloadData()
            //TODO: Implement delete
            //photoBuckets.remove(at: indexPath.row)
            //tableView.reloadData()
            
            let photoToDelete = photoBucketCollectionManager.shared.latestPhotoBuckets[indexPath.row]
            photoBucketCollectionManager.shared.delete(photoToDelete.documentId!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kdetailSegue{
            let pbdvc = segue.destination as! photoDetailController

            if let indexPath = tableView.indexPathForSelectedRow{
                let photo = photoBucketCollectionManager.shared.latestPhotoBuckets[indexPath.row]
                pbdvc.photoBucketDocumentId = photo.documentId!
            }
        }
    }
}
