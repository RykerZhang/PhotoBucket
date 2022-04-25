//
//  AuthManager.swift
//  PhotoBucket
//
//  Created by Yujie Zhang on 4/23/22.
//
import Foundation
import Firebase
import GoogleSignIn

class AuthManager{
    static let shared = AuthManager()
    private init(){
        
    }
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    var isSignedIn: Bool{
      currentUser != nil
    }
    
    func addLoginObserver(callback:@escaping (()->Void))->AuthStateDidChangeListenerHandle{
        return Auth.auth().addStateDidChangeListener{ auth, user in
            if(user != nil){
                callback()
            }
        }
    }
    
    func addLogoutObserver(callback:@escaping (()->Void))->AuthStateDidChangeListenerHandle{
        return Auth.auth().addStateDidChangeListener{ auth, user in
            if(user == nil){
                callback()
            }
        }
    }
    
    func removeObserver(_ authDidChangeHandle: AuthStateDidChangeListenerHandle?){
//        if authDidChangeHandle != nil{
//            Auth.auth().removeStateDidChangeListener(authDidChangeHandle)
//        }
        
        if let authHandle = authDidChangeHandle{
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    func signInNewEmailPasswordUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password){authResult, error in
            if let error = error{
                print("There was an error during create")
                return
            }
            print("User created")
        }
    }
    
    func loginExistingEmailPasswordUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password){
            authResult, error in
            if let error = error {
                print("Yjere was an error in te creating user:\(error)")
                return
            }
            print("User created")
        }
    }
    
    func signInAnonymously(){
        Auth.auth().signInAnonymously(){authResult, error in
            if let error = error{
                print("There was an error with anonymous sign in:\(error)")
                return
            }
            print("Anonymous sign in")
        }
    }
    
    func signInWithRosefireToken(_ rosefireToken: String){
        Auth.auth().signIn(withCustomToken: rosefireToken){(authResult, error) in
            if let error = error{
                print("Firebase sign in error \(error)")
                return
            }
            print("The ser is now actually signed in using the rosefire token")
        }
    }
    
    func signInWithGoogleCredential(_ googleCredential: AuthCredential){
        Auth.auth().signIn(with: googleCredential)
    }

    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("Sign out failed: \(error)")
        }
    }
}


