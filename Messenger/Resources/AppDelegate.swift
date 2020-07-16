//
//  AppDelegate.swift
//  Messenger
//
//  Created by Yusuke Mitsugi on 2020/06/14.
//  Copyright © 2020 Yusuke Mitsugi. All rights reserved.
//

import Firebase
import UIKit
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain class AppDelegate:UIResponder, UIApplicationDelegate {
    
    
    
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
        
    }
    func application( _ app:UIApplication, open url:URL, options: [UIApplication.OpenURLOptionsKey :Any] = [:] ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        
        return (GIDSignIn.sharedInstance()?.handle(url))!
    }
}

// MARK: - GIDSignInDelegate
extension AppDelegate: GIDSignInDelegate {
    
    // Googleサインイン
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
              if let error = error {
              print("Googleログイン失敗: \(error)")
              }
              return
          }

          
          guard let user = user else {
              return
          }
          
          print("Googleでログインした！: \(user)")
          
          guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
                  return
          }
          UserDefaults.standard.set(email, forKey: "email")
          UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

          
          DatabaseManager.shared.userExists(with: email) { (exists) in
              if !exists {
                  // insert to database
                  let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                  DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                      if success {
                          // upload image
                          if user.profile.hasImage {
                              guard let url = user.profile.imageURL(withDimension: 200) else {
                                  return
                              }
                              URLSession.shared.dataTask(with: url) { (data, _, _) in
                                  guard let data = data else {
                                      return
                                  }
                                  let fileName = chatUser.profilePictureFileName
                                  StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                      switch result {
                                      case .success(let downloadUrl):
                                          UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                          print(downloadUrl)
                                      case .failure(let error):
                                          print("Strong manager error: \(error)")
                                      }
                                  }
                              }.resume()
                              
                          }
                          
                      }
                  })
              }
          }
          guard let authentication = user.authentication else { return }
          print("Googleユーザーの認証がされません")
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                             accessToken: authentication.accessToken)
          Firebase.Auth.auth().signIn(with: credential) { (authResult, error) in
              guard authResult != nil, error == nil else {
                  print("Googleログインに失敗しました")
                  return
              }
              print("googleログインに成功！")
              NotificationCenter.default.post(name: .didLogInNotification, object: nil)
          }
      }
      func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
          print("googleユーザーの接続が切れました")
      }
}

