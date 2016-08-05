//
//  LeaderboardTableViewCell.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 04.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var leaderboardBackgroundImageView: UIImageView!
    @IBOutlet weak var leaderboardPersonNameLabel: UILabel!
    @IBOutlet weak var leaderboardPersonsRoleLabel: UILabel!
    @IBOutlet weak var orderInLeaderboardLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var personsRoundImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        // Creating round image for person
        self.personsRoundImageView.layer.cornerRadius = self.personsRoundImageView.frame.size.width/2
        self.personsRoundImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
