//
//  loginViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 03.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit


class loginViewController: UIViewController {

    @IBOutlet weak var loginBackgroundImage: UIImageView!

    @IBAction func touchLoginButton(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager();

        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error == nil {
                        print("user: \(user?.displayName)");
                    } else {
                        print(error.debugDescription);
                    }
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // redirect if already logged in
        if FBSDKAccessToken.currentAccessToken() != nil {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
