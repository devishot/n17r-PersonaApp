//
//  linksTableViewCell.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 01.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class linksTableViewCell: UITableViewCell {

    @IBOutlet weak var linksBlurView: UIVisualEffectView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var linksTitleLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
