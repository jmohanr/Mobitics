//
//  ViewController.swift
//  Mobitics
//
//  Created by Jagan on 26/12/19.
//  Copyright © 2019 Jagan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController,GIDSignInDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    var emailId = String()
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    //MARK:- Google Sign in Delegate Methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let _ = error {
                return
            }else{
                if let _ = authResult?.user.email{
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    self.performSegue(withIdentifier: "mainPage", sender: nil)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("error===>\(error)")
            return
        }
    }
    
    //MARK:- Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mainPage") {
            if let _ = segue.destination as? MainPageViewController {
            }
        }
    }
}

