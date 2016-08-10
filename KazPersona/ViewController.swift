//
//  ViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 29.07.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase
import DateTools


// MARK: global variables and functions
let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
}()


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
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var leaveFeedbackTextView: UITextView!

    @IBAction func sendFeedbackButton(sender: UIButton) {
        if let text = leaveFeedbackTextView.text, let user = FIRAuth.auth()?.currentUser {
            // send
            self.saveFeedback(text, uid: user.uid, facebookFriendsCount: currentUserFacebookFriendsCount!, completion: {() -> Void in
                // clear textarea and hide keyboard
                self.leaveFeedbackTextView.text = ""
                self.leaveFeedbackTextView.resignFirstResponder()
            })
        }
    }

    @IBOutlet weak var followersIcon: UIImageView!

    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]

    let articleLinkCellID = "CellIdentifier"
    let feedbackCellID = "feedbackCell"

    var personUID: String = "abaitasov"
    var personWithRate: [String: AnyObject] = [:]

    var booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    var articles: [[String: String]] = []
    var feedbacks: [[String: AnyObject]] = []

    let logoIconsImageArray = [UIImage(named: "esquire_logo"), UIImage(named: "buro_logo"), UIImage(named: "chronicle_logo"), UIImage(named: "kursiv_logo")]
    let backgroundImagesArray = [UIImage(named:"bacground_link"), UIImage(named:"background_buro"), UIImage(named:"background_chronicle"), UIImage(named:"background_kursiv")]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.followersIcon.image = UIImage(named: "followers")


        // changes for button border
        feedbackButton.layer.borderColor = UIColor.blackColor().CGColor
        feedbackButton.layer.cornerRadius = 5
        feedbackButton.layer.borderWidth = 1
        
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

        self.feedbackTableView.dataSource = self;

        
        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
    }

    override func viewWillAppear(animated: Bool) {
        fetchAndDisplayPersonDescription()
        // fetchAndDisplayPersonArticles()
        // fetchAndDisplayPersonPhotos()
        fetchAndListenPersonFeedbacks()
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

    // MARK: Listen data on Firebase
    func fetchAndListenPersonFeedbacks() -> Void {
        self.ref.child("person_feedbacks").child(personUID).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in

            if let value = snapshot.value {
                let dict = value as! NSDictionary

                self.feedbacks = dict.allValues as! [[String: AnyObject]]
                self.feedbackTableView.reloadData()
            }
            else {
                // TODO: hide table here
            }
        })
    }

    // MARK: Write data to Firebase
    func saveFeedback(message: String, uid: String, facebookFriendsCount: Int, completion: () -> Void) -> Void {
        // get timestamp as string
        let currentDate = NSDate()
        let timestamp = dateFormatter.stringFromDate(currentDate)

        ref.child("person_feedbacks").child(personUID).childByAutoId().setValue([
            "timestamp": timestamp,
            "message": message,
            "uid": uid,
            "friends_count": facebookFriendsCount
            ], withCompletionBlock: {(error, ref) -> Void in
                // call callback
                completion()
        })
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


    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.linksTableView {
            return articles.count
        }
        if tableView == self.feedbackTableView {
            return feedbacks.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.linksTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(articleLinkCellID, forIndexPath: indexPath) as! linksTableViewCell
            
            // Fetch Article
            let article = self.articles[indexPath.row] as [String: String]
            
            // Configure Cell
            cell.linksTitleLabel?.text = article["title"]
            cell.logoImageView.image = self.logoIconsImageArray[indexPath.row]
            //  cell.linksBackgroundImageView.image = self.backgroundImagesArray[indexPath.row]
            return cell
        }
        if tableView == self.feedbackTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(feedbackCellID, forIndexPath: indexPath) as! FeedbackTableViewCell

            // Fetch feedback
            let feedback = self.feedbacks[indexPath.row] as [String: AnyObject]
            
            let message = feedback["message"] as! String
            let followersNumber = feedback["friends_count"] as! Int
            let timestamp = feedback["timestamp"] as! String
            let date = dateFormatter.dateFromString(timestamp)
            let dateAgo = date!.timeAgoSinceNow() as String

            cell.feedbackTextView.text = message
            cell.userFollowersNumberLabel.text = String(followersNumber)
            cell.dateLabel.text = dateAgo
        }
        return UITableViewCell()
    }


    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.linksTableView {
            // Fetch Article
            let article = self.articles[indexPath.row] as [String: String]
            
            // LOG
            print(indexPath.row, article)
        }
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

