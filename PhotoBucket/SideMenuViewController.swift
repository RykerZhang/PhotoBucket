//
//  SideMenuViewController.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/28/22.
//

import Foundation
import UIKit
class SideMenuViewController: UIViewController{
    
    var tableView: tableViewController{
        let navController = presentingViewController as! UINavigationController
        return navController.viewControllers.last as! tableViewController
    }
    
    
    
    
    @IBAction func pressEditProfile(_ sender: Any) {
        dismiss(animated: true)
        print("show profile")
        tableView.performSegue(withIdentifier: kshowProfileSegue, sender: tableView)
    }

        

    
    @IBAction func pressShowMyPhotos(_ sender: Any) {
        dismiss(animated: true)
        tableView.isShowingAllPhoto = false
        tableView.startListeningForPhotoBuckets()
    }
    @IBAction func pressAllPhotos(_ sender: Any) {
        dismiss(animated: true)
        tableView.isShowingAllPhoto = true
        tableView.startListeningForPhotoBuckets()
    }
    @IBAction func pressDelete(_ sender: Any) {
        dismiss(animated: true)
        tableView.isEditing = !tableView.isEditing

    }
    @IBAction func pressLogOut(_ sender: Any) {
        dismiss(animated: true)
        AuthManager.shared.signOut()
    }
}
