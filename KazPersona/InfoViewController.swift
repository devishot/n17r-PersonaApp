//
//  InfoViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 09.08.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    
    @IBOutlet weak var infoBackgroundImageView: UIImageView!
    
    @IBOutlet weak var logoInfoImageView: UIImageView!
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoBackgroundImageView.image = UIImage(named: "infobackground_n17r")
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        self.logoInfoImageView.image = UIImage(named: "Logo-Light")


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
