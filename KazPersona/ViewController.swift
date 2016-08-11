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
import Kingfisher


// MARK: global variables and functions
let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
}()

let sourceIconUrlFormat = "https://dl.dropboxusercontent.com/u/33464043/n17r_public_content/source_logos/%@.png"


class ViewController: UIViewController, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var addBackgroundImageView: UIView!
    @IBOutlet weak var mainRoleLabel: UILabel!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var personFollowers: UILabel!
    @IBOutlet weak var personName: UILabel!


    @IBOutlet weak var profileImageCollectionView: UICollectionView!


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


    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]

    let articleLinkCellID = "CellIdentifier"
    let feedbackCellID = "feedbackCell"
    let profilePhotoCellID = "speakerProfileImageCell"

    var personUID: String = "abaitasov"
    var personWithRate: [String: AnyObject] = [:]

    var booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    var articles: [[String: String]] = []
    var feedbacks: [[String: AnyObject]] = []
    var photos: [String] = []

    let logoIconsImageArray = [UIImage(named: "esquire_logo"), UIImage(named: "buro_logo"), UIImage(named: "chronicle_logo"), UIImage(named: "kursiv_logo")]
    let backgroundImagesArray = [UIImage(named:"bacground_link"), UIImage(named:"background_buro"), UIImage(named:"background_chronicle"), UIImage(named:"background_kursiv")]


    override func viewDidLoad() {
        super.viewDidLoad()
        //add borders to labels
        mainRoleLabel.layer.cornerRadius = 10
        
        //add icon inline with label followers
        personFollowers.addImage("followers", afterLabel: true)

        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()

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

        self.profileImageCollectionView.dataSource = self;

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
    }

    override func viewWillAppear(animated: Bool) {
        
        fetchAndDisplayPersonDescription()
        fetchAndDisplayPersonPhotos()
        fetchAndDisplayPersonArticles()
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

            self.photos = snapshot.value as! [String]
            self.profileImageCollectionView.reloadData()

        }) { (error) in
            self.handleFirebaseConnectionError(error)
        }
        // [END read_data_once]
    }

    // MARK: Listen data on Firebase
    func fetchAndListenPersonFeedbacks() -> Void {
        self.ref.child("person_feedbacks").child(personUID).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in

            if let value = snapshot.value as? NSDictionary {
                self.feedbacks = value.allValues as! [[String: AnyObject]]
                self.feedbackTableView.reloadData()
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


    // MARK: Collection View Data Source Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.booksCollectionView {
            return 7
        }
        if collectionView == self.profileImageCollectionView {
            return self.photos.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.booksCollectionView {

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! booksCollectionViewCell
            
            cell.imageView.image = self.booksImageArray[indexPath.row]
            return cell
        }
        if collectionView == self.profileImageCollectionView {

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(profilePhotoCellID, forIndexPath: indexPath) as! SpeakerProfileImageCollectionViewCell

            let url = self.photos[indexPath.row]
            if let photo_url = NSURL(string: url) {
                cell.speakerImageView.kf_setImageWithURL(photo_url)
            }
            return cell
        }
        return UICollectionViewCell()
    }


    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        var tBackground: UIView? = nil
        var tSeparatorStyle = UITableViewCellSeparatorStyle.SingleLine

        if tableView == self.linksTableView {
            if self.articles.count == 0 {
                let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, 90))
                emptyLabel.text = "Нет публикаций или мы не нашли 🙈"
                emptyLabel.font = UIFont.systemFontOfSize(12)
                emptyLabel.textAlignment = NSTextAlignment.Center

                tBackground = emptyLabel
                tSeparatorStyle = UITableViewCellSeparatorStyle.None
            }
            numberOfRows = articles.count
        }
        if tableView == self.feedbackTableView {
            if self.feedbacks.count == 0 {
                let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, 90))
                emptyLabel.text = "Будьте первым! Поделитесь своим мнением 🗣"
                emptyLabel.font = UIFont.systemFontOfSize(12)
                emptyLabel.textAlignment = NSTextAlignment.Center

                tBackground = emptyLabel
                tSeparatorStyle = UITableViewCellSeparatorStyle.None
            }
            numberOfRows = feedbacks.count
        }

        tableView.backgroundView = tBackground
        tableView.separatorStyle = tSeparatorStyle
        return numberOfRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.linksTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(articleLinkCellID, forIndexPath: indexPath) as! linksTableViewCell
            
            // Fetch Article
            let article = self.articles[indexPath.row] as [String: String]
            let aTitle = article["title"]

            // Configure Cell
            cell.linksTitleLabel?.text = aTitle
            if let source = article["source"] {
                let sourceIconUrl = String(format: sourceIconUrlFormat, source)
                cell.logoImageView.kf_setImageWithURL(NSURL(string: sourceIconUrl))
            }
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

