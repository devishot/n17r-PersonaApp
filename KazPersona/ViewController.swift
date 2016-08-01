//
//  ViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 29.07.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {

    @IBOutlet weak var speakerProfileImageView: UIImageView!
    @IBOutlet weak var speakerNameLable: UILabel!
    @IBOutlet weak var speakerRoleLabel: UILabel!
    
    @IBOutlet weak var listOfBooksLabel: UILabel!
    @IBOutlet weak var booksCollectionView: UICollectionView!

    let booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    
    @IBOutlet weak var personDescriptionLabel: UILabel!
    @IBOutlet weak var personDescriptionTextView: UITextView!
    
    let userID: String! = "abaitasov"
    
    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
        
        speakerProfileImageView.image = UIImage(named:("profile_speaker"))

        // self.ref.child("event_persons/tedx_ala").child("3").setValue(["uid": userID!])
        
        // [START fetch_persons_detailed_info]
        ref.child("persons").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            let postDict = snapshot.value as! [String : AnyObject]
            
            let full_name = postDict["name"] as! String
            let short_bio = postDict["short_bio"] as! String
            
            self.speakerNameLable.text = full_name
            self.speakerRoleLabel.text = short_bio
            
        }) { (error) in
            print(error.localizedDescription)
        }
        // [END define_database_reference]
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 7
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! booksCollectionViewCell
            
            cell.imageView.image = self.booksImageArray[indexPath.row]
            return cell
            
        }

}

