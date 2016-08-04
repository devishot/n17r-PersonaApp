//
//  ViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 29.07.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var speakerProfileImageView: UIImageView!
    @IBOutlet weak var speakerNameLable: UILabel!
    @IBOutlet weak var speakerRoleLabel: UILabel!
    
    @IBOutlet weak var listOfBooksLabel: UILabel!
    @IBOutlet weak var booksCollectionView: UICollectionView!
    
    @IBOutlet weak var personDescriptionLabel: UILabel!
    @IBOutlet weak var personDescriptionTextView: UITextView!
    
    @IBOutlet weak var linksTableView: UITableView!
    
    
    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]
    
    let cellIdentifier = "CellIdentifier"
    let userID: String! = "abaitasov"
    
    var booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    var articles: [[String: String]] = []
    
    let logoIconsImageArray = [UIImage(named: "esquire_logo"), UIImage(named: "buro_logo"), UIImage(named: "chronicle_logo"), UIImage(named: "kursiv_logo")]
    let backgroundImagesArray = [UIImage(named:"bacground_link"), UIImage(named:"background_buro"), UIImage(named:"background_chronicle"), UIImage(named:"background_kursiv")]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
    }
    
    override func viewWillAppear(animated: Bool) {
        speakerProfileImageView.image = UIImage(named:("profile_speaker"))

        // [START read_data_once]
        // fetch person full bio
        ref.child("persons").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            let postDict = snapshot.value as! [String : String]
            let full_name = postDict["name"]
            let short_bio = postDict["short_bio"]
            let cover_url = postDict["cover_url"]

            self.speakerNameLable.text = full_name
            self.speakerRoleLabel.text = short_bio

            if let url = NSURL(string: cover_url!), data = NSData(contentsOfURL: url)
            {
                self.speakerProfileImageView.image = UIImage(data: data)
            }

        }) { (error) in
            print(error.localizedDescription)
        }
        // [END read_data_once]
        
        // [START read_data_once]
        // fetch person articles
        ref.child("person_articles").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            let postArray = snapshot.value as! [[String: String]]

            self.articles = postArray

            // LOG
            print(self.articles)

            self.linksTableView.reloadData()

        }) { (error) in
            print(error.localizedDescription)
        }
        // [END read_data_once]
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 7
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! booksCollectionViewCell
            
            cell.imageView.image = self.booksImageArray[indexPath.row]
            return cell
            
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! linksTableViewCell

        // Fetch Article
        let article = self.articles[indexPath.row] as [String: String]

        // Configure Cell
        cell.linksTitleLabel?.text = article["title"]
        cell.logoImageView.image = self.logoIconsImageArray[indexPath.row]
        cell.linksBackgroundImageView.image = self.backgroundImagesArray[indexPath.row]
        return cell
    }


    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Fetch Article
        let article = self.articles[indexPath.row] as [String: String]

        // LOG
        print(indexPath.row, article)
    }
    
}

