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


// MARK: Global variables
var currentUserFacebookFriendsCount: Int? = nil;



class loginViewController: UIViewController {
    
    @IBOutlet weak var loginBackgroundImage: UIImageView!
    @IBAction func touchLoginButton(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager();

        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                self.completeSignIn()
            }
        }
    }

    var leaderBoard: UIViewController? = nil

    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]


    override func viewDidLoad() {
        super.viewDidLoad()

         self.loginBackgroundImage.image = UIImage(named: "1")
        
        // Do any additional setup after loading the view.

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
        
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

        // update facebook data in user profile on database
        self.fetchFacebookProfileData({(data: [String: AnyObject]) -> Void in

            if let user = FIRAuth.auth()?.currentUser {
                self.ref.child("users").child(user.uid).setValue(data)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func fetchFacebookProfileData(completion: ([String: AnyObject]) -> Void) {
        var completionResult: [String: AnyObject] = [:]

        let graphConnection = FBSDKGraphRequestConnection()

        let friendsCountRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["limit": 0])
        let summaryRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,about,age_range,education,email,birthday"])

        graphConnection.addRequest(friendsCountRequest, completionHandler: { (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if(error != nil){
                print(error)
            }else{
                let dict = result as! [String: AnyObject]
                let summary = dict["summary"] as! [String: AnyObject]
                let friendsCount = summary["total_count"]! as! Int

                // completionHandler runs first
                completionResult["friends_count"] = friendsCount

                // set Global variable
                currentUserFacebookFriendsCount = friendsCount
            }
            })

        graphConnection.addRequest(summaryRequest, completionHandler: { (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if(error != nil){
                print(error)
            }else{
                let dict = result as! [String: AnyObject]

                // completionHandler runs secondly
                for key in dict.keys {
                    completionResult[key] = dict[key]
                }

                // call calback
                completion(completionResult)
            }
            })

        graphConnection.start()
    }

    func signIntoFirebase(completion: () -> Void) {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);

        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            if error == nil {
                print("Firebase login: \(user?.displayName)");
                // callback
                completion()
                
            } else {
                print(error.debugDescription);
            }
        })
    }

    // 1. Sign into Firebase
    // 2. redirect to MainViewController
    func completeSignIn() {
        signIntoFirebase({() -> Void in
            // redirect to LeaderBoard
            self.presentViewController(self.leaderBoard!, animated: true, completion: nil)
        })
    }
}
