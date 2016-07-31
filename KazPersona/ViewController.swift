//
//  ViewController.swift
//  KazPersona
//
//  Created by Aigerim'sMac on 29.07.16.
//  Copyright © 2016 n17r. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var speakerProfileImageView: UIImageView!
    @IBOutlet weak var speakerNameLable: UILabel!
    @IBOutlet weak var speakerRoleLabel: UILabel!
    
    @IBOutlet weak var listOfBooksLabel: UILabel!
    @IBOutlet weak var booksCollectionView: UICollectionView!

    let booksImageArray = [UIImage(named: "book1"), UIImage(named: "book2"), UIImage(named: "book3"),  UIImage(named: "book4"), UIImage(named: "book5"),  UIImage(named: "book6"), UIImage(named: "book7")]
    
    @IBOutlet weak var personDescriptionLabel: UILabel!
    @IBOutlet weak var personDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        speakerProfileImageView.image = UIImage(named:("profile_speaker"))
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 7
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! booksCollectionViewCell
            
            cell.imageView.image = self.booksImageArray[indexPath.row]
            return cell
            
        }

}

