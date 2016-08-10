//
//  ViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 29.07.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase


// MARK: global variables and functions
// here


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var personFollowers: UILabel!
    @IBOutlet weak var personName: UILabel!

    @IBOutlet weak var profileImageCollectionView: UIView!


    @IBOutlet weak var personDescriptionLabel: UILabel!
    @IBOutlet weak var personDescriptionTextView: UITextView!
    
    @IBOutlet weak var listOfBooksLabel: UILabel!
    @IBOutlet weak var booksCollectionView: UICollectionView!

    @IBOutlet weak var linksTableView: UITableView!
    @IBOutlet weak var feedbackTableView: UITableView!
    
    @IBOutlet weak var leaveFeedbackTextView: UITextView!
    
    @IBOutlet weak var enterNameTextView: UITextView!
    
    @IBOutlet weak var sendFeedbackButton: UIButton!

    @IBAction func sendFeedbackButton(sender: UIButton) {
        
        
    }

    @IBOutlet weak var followersIcon: UIImageView!

    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]

    let articleLinkCellID = "CellIdentifier"
    var personUID: String = "abaitasov"
    var personWithRate: [String: AnyObject] = [:]

    var booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    var articles: [[String: String]] = []
    
    let logoIconsImageArray = [UIImage(named: "esquire_logo"), UIImage(named: "buro_logo"), UIImage(named: "chronicle_logo"), UIImage(named: "kursiv_logo")]
    let backgroundImagesArray = [UIImage(named:"bacground_link"), UIImage(named:"background_buro"), UIImage(named:"background_chronicle"), UIImage(named:"background_kursiv")]


    override func viewDidLoad() {
        super.viewDidLoad()
        //add icon inline with label followers
        personFollowers.addImage("followers", afterLabel: true)
    
        self.followersIcon.image = UIImage(named: "followers")
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
       
        
        // changes for button border
        sendFeedbackButton.layer.borderColor = UIColor.blackColor().CGColor
        sendFeedbackButton.layer.cornerRadius = 5
        sendFeedbackButton.layer.borderWidth = 1
        
        leaveFeedbackTextView.layer.borderColor = UIColor.grayColor().CGColor
        leaveFeedbackTextView.layer.cornerRadius = 5
        leaveFeedbackTextView.layer.borderWidth = 1
        
        // changes to auto layout of TextView
        let contentSize = personDescriptionTextView.sizeThatFits(personDescriptionTextView.bounds.size)
        var frame = personDescriptionTextView.frame
        frame.size.height = contentSize.height
        personDescriptionTextView.frame = frame
        
        

        // Do any additional setup after loading the view, typically from a nib.
        
        self.linksTableView.dataSource = self;
        self.linksTableView.delegate = self;

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
    }

    override func viewWillAppear(animated: Bool) {
        fetchAndDisplayPersonDescription()
        // fetchAndDisplayPersonArticles()
        // fetchAndDisplayPersonPhotos()
    }


    // MARK: Fetch data from firebase
    func fetchAndDisplayPersonDescription() -> Void {
        // [START read_data_once]
        ref.child("persons").child(personUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.value is NSNull {
                self.handleFirebaseEmptyDataError()
                return
            }

            let postDict = snapshot.value as! [String : String]
            let full_name = postDict["name"]
            let description = postDict["description"]
            
            let followers = self.personWithRate["followers"] as! Int

            self.personName.text = full_name
            self.personFollowers.text = String(followers)
            self.personDescriptionTextView.text = description

        }) { (error) in
            self.handleFirebaseConnectionError(error)
            return
        }
        // [END read_data_once]
    }

    func fetchAndDisplayPersonArticles() -> Void {
        // [START read_data_once]
        ref.child("person_articles").child(personUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            if snapshot.value is NSNull {
                self.handleFirebaseEmptyDataError()
                return
            }

            let postArray = snapshot.value as! [[String: String]]

            self.articles = postArray
            // update linksTableView
            self.linksTableView.reloadData()

        }) { (error) in
            self.handleFirebaseConnectionError(error)
        }
        // [END read_data_once]
    }

    func fetchAndDisplayPersonPhotos() -> Void {
        // [START read_data_once]
        ref.child("person_photos").child(personUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.value is NSNull {
                self.handleFirebaseEmptyDataError()
                return
            }
            
            let photos = snapshot.value as! [String]

            /*
            if let url = NSURL(string: cover_url!), data = NSData(contentsOfURL: url)
            {
                self.speakerProfileImageView.image = UIImage(data: data)
            }
             */
        }) { (error) in
            self.handleFirebaseConnectionError(error)
        }
        // [END read_data_once]
    }

    // MARK: Collection View of Books
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! booksCollectionViewCell
            
            cell.imageView.image = self.booksImageArray[indexPath.row]
            return cell
            
    }


    // MARK: Table View Data Source Methods of Article links
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(articleLinkCellID, forIndexPath: indexPath) as! linksTableViewCell

        // Fetch Article
        let article = self.articles[indexPath.row] as [String: String]

        // Configure Cell
        cell.linksTitleLabel?.text = article["title"]
        cell.logoImageView.image = self.logoIconsImageArray[indexPath.row]
      //  cell.linksBackgroundImageView.image = self.backgroundImagesArray[indexPath.row]
        return cell
    }


    // MARK: Table View Delegate Methods of Article links
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Fetch Article
        let article = self.articles[indexPath.row] as [String: String]

        // LOG
        print(indexPath.row, article)
    }


    // MARK: error handlers
    func handleFirebaseEmptyDataError() -> Void {
        // [START display_error_modal]
        let alertController = UIAlertController(title: "Извините,", message: "ошибка на сервере", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
        }))

        presentViewController(alertController, animated: true, completion: nil)
        // [END display_error_modal]
    }

    func handleFirebaseConnectionError(error: NSError) -> Void {
        print("firebase.error.handler", error.localizedDescription)

        // [START display_error_modal]
        let alertController = UIAlertController(title: "Попробуйте снова,", message: "проверьте интернет подключение", preferredStyle: UIAlertControllerStyle.Alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
        // [END display_error_modal]
    }
}

