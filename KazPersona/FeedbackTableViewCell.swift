//
//  FeedbackTableViewCell.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 08.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userFollowersNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBAction func offensiveContentButton(sender: UIButton) {
        offensiveContentButtonAction?(self)
    }

    var offensiveContentButtonAction: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
