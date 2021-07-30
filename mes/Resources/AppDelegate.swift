//
//  AppDelegate.swift
//  mes
//
//  Created by Chun Hei Law on 7/19/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
      return extensionPointIdentifier != .keyboard
    }
    

}

extension AppDelegate: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else{
            if let error = error{
                print("failed to sign in with Google \(error)")
            }
            return
        }
        guard let user = user else{
            return
        }
        print("signed in with Google \(user)")
        
        guard let email = user.profile.email, let firstname = user.profile.givenName,
              let lastname = user.profile.familyName else{
            return
        }
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstname) \(lastname)", forKey: "name")
        
        databaseset.shared.vaildateuser(with: email, completion: {exists in
            if !exists {
                let chatuser = chatuser(firstname: firstname, lastname: lastname, email: email)
                databaseset.shared.insert(with: chatuser, completion: { success in
                    if success{
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url, completionHandler: {data,_,_ in
                                guard let data = data else{
                                    return
                                }
                                let filename = chatuser.profilePic
                                StorageSet.shared.uploadProfilePic(with: data, fileName: filename, completion: { result in
                                    switch result{
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    }
                })
            }
        })
        
        guard let authenticate = user.authentication else {
            print("missing auth object of google account")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authenticate.idToken, accessToken: authenticate.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: {authResult, error in
            guard authResult != nil, error == nil else{
                print("failed to login with Google credential")
                return
            }
            print("Login with Google credential successfully")
            NotificationCenter.default.post(name: .didloginin, object: nil)
        })
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google account is disconnected")
    }
}
