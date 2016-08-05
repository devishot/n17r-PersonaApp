//
//  MainViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 03.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellLeaderboard", forIndexPath: indexPath) as! LeaderboardTableViewCell
        cell.leaderboardBackgroundImageView.image = UIImage(named: "tableViewBackground")
        return cell
    }
}
