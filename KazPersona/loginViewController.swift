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

    var leaderBoard: UIViewController? = nil

    @IBOutlet weak var loginBackgroundImage: UIImageView!
    @IBAction func touchLoginButton(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager();

        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                self.completeSignIn()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

         self.loginBackgroundImage.image = UIImage(named: "1")
        
        // Do any additional setup after loading the view.
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.leaderBoard = mainStoryboard.instantiateViewControllerWithIdentifier("leaderBoard") as UIViewController
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // redirect if already logged in
        if FBSDKAccessToken.currentAccessToken() != nil {

            if let user = FIRAuth.auth()?.currentUser {
                print("Already logged in, user: \(user.displayName)");
                // redirect to LeaderBoard
                self.presentViewController(self.leaderBoard!, animated: true, completion: nil)

            } else {
                print("Warning: not logged in Firebase")
                // sign into Firebae and redirect to LeaderBoard
                self.completeSignIn()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // Sign into Firebase and redirect to MainViewController
    func completeSignIn() {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            if error == nil {
                print("Firebase login: \(user?.displayName)");

                // redirect to LeaderBoard
                self.presentViewController(self.leaderBoard!, animated: true, completion: nil)

            } else {
                print(error.debugDescription);
            }
        })
    }
}
