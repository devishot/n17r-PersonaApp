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

    @IBOutlet weak var personsRoundImageView: UIImageView!

    @IBOutlet weak var numberOfFollowersLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfFollowersLabel.addImage("followers", afterLabel: false)
        // Initialization code
        
        // Creating round image for person
        personsRoundImageView.layer.borderWidth = 1
        personsRoundImageView.layer.masksToBounds = false
        personsRoundImageView.layer.borderColor = UIColor.clearColor().CGColor
        personsRoundImageView.layer.cornerRadius = personsRoundImageView.frame.height/2
        personsRoundImageView.layer.cornerRadius = 15
        personsRoundImageView.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        personsRoundImageView.layer.cornerRadius = personsRoundImageView.frame.width / 2
    }

}
