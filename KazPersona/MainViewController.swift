//
//  MainViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 03.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var leaderboardTableView: UITableView!
    
    // [START define_database_reference]
    var ref: FIRDatabaseReference!
    // [END define_database_reference]

    var personDetailViewSegueID : String = "personDetailViewSegue"
    var personsRate : [[String: AnyObject]] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Helvetica", size: 18)!
        ]
        
 UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Do any additional setup after loading the view.
        
        self.leaderboardTableView.dataSource = self;
        self.leaderboardTableView.delegate = self;

        // [START create_database_reference]
        ref = FIRDatabase.database().reference()
        // [END create_database_reference]
    }

    override func viewWillAppear(animated: Bool) {

        // [START read_data_once]
        // fetch persons by ratings
        ref.child("person_ratings").queryOrderedByChild("followers").observeSingleEventOfType(.Value, withBlock: { (snapshot) in

            self.personsRate = snapshot.value! as! [[String : AnyObject]]

            // LOG
            print("fetched - ", self.personsRate.count)

            // update leaderboardTableView
            self.leaderboardTableView.reloadData()

        }) { (error) in
            print(error.localizedDescription)
        }
        // [END read_data_once]
    }


    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let personsCount = self.personsRate.count
        print("table rows number - ", personsCount)
        return personsCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellLeaderboard", forIndexPath: indexPath) as! LeaderboardTableViewCell

        // set common background
        cell.leaderboardBackgroundImageView.image = UIImage(named: "tableViewBackground")

        // fetch data
        let personWithRate = self.personsRate[indexPath.row]
        let name = personWithRate["name"] as! String
        let biz = personWithRate["biz"] as! String
        let followers = personWithRate["followers"] as! Int

        // set data
        cell.leaderboardPersonNameLabel.text = name
        cell.leaderboardPersonsRoleLabel.text = biz
        cell.orderInLeaderboardLabel.text = String(indexPath.row + 1)
        cell.numberOfFollowersLabel.text = String(followers)
/*      
        if let url = NSURL(string: cover_url!), data = NSData(contentsOfURL: url)
        {
            self.personsRoundImageView.image = UIImage(data: data)
        }
*/

        return cell
    }



    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // fetch data
        let personWithRate = self.personsRate[indexPath.row]
        let uid = personWithRate["uid"]

        // LOG
        print(indexPath.row, uid, personWithRate)

        // redirect to detail view by uid
        performSegueWithIdentifier(personDetailViewSegueID, sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.personDetailViewSegueID {
            let indexPath = self.leaderboardTableView.indexPathForSelectedRow
            let detailViewController = segue.destinationViewController as! ViewController

            // fetch data
            let personWithRate = self.personsRate[indexPath!.row]
            let uid = personWithRate["uid"] as! String

            detailViewController.personUID = uid
            detailViewController.personWithRate = personWithRate
        }
    }

}
