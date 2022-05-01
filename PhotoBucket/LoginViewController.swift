//
//  LoginViewController.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/23/22.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController{

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var rosefireName: String?
    var loginHandle : AuthStateDidChangeListenerHandle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.placeholder = "Email"
        passwordText.placeholder = "Password"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginHandle = AuthManager.shared.addLoginObserver {
            print("TODO: Fire the showlist segue! there is already someone signed in ")
            self.performSegue(withIdentifier: kshowListSegue, sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AuthManager.shared.removeObserver(loginHandle)
    }
    
    @IBAction func PressedCreateNew(_ sender: Any) {
        let email = emailText.text!
        let password = passwordText.text!
        print("Create user")
        AuthManager.shared.signInNewEmailPasswordUser(email: email, password: password)
    }
    @IBAction func PressedLogin(_ sender: Any) {
        let email = emailText.text!
        let password = passwordText.text!
        print("login user")
        AuthManager.shared.loginExistingEmailPasswordUser(email: email, password: password)
//        loginHandle = AuthManager.shared.addLoginObserver {
//            print("TODO: Fire the showlist segue! there is already someone signed in ")
//            self.performSegue(withIdentifier: kshowListSegue, sender: self)
//        }
    }
    @IBAction func PressedRoseFire(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(registryToken: kRosefireRegToken){(err, result) in
            if let err = err{
                print("Rosefire sign in error \(err)")
                return
            }
           // print("Result \(result!.token!)")
           // print("Result \(result!.username!)")
            print("Result: \(result!.name!)")
           // print("Result \(result!.email!)")
           // print("Result \(result!.group!)")
            
            AuthManager.shared.signInWithRosefireToken(result!.token)
        }
    }
    
    @IBAction func pressedGoogleLogIn(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) {user, error in
            if let error = error {
              print("Error with google sign in \(error)")
              return
            }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            print("Google Sign in Worked! Now use the credential to do the real fIREBASE SIGN IN")
            
            AuthManager.shared.signInWithGoogleCredential(credential)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue identifier \(segue.identifier)")
        if segue.identifier == kshowListSegue{
            print("NAME = \(rosefireName ?? AuthManager.shared.currentUser!.displayName)")
            print("photourl = \(AuthManager.shared.currentUser!.photoURL)")
            UserManager.shared.addNewUserMaybe(uid: AuthManager.shared.currentUser!.uid, name: rosefireName ?? AuthManager.shared.currentUser!.displayName, photoUrl: AuthManager.shared.currentUser!.photoURL?.absoluteString)
        }
    }
}
