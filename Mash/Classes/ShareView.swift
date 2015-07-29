//
//  ShareView.swift
//  Mash
//
//  Created by Danny Hsu on 7/29/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

protocol SharingDelegate {
    
}

class ShareView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var sharingView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var fileURL: NSURL = NSURL()
    
    class func createView(fileToBeShared: NSURL) -> ShareView {
        let view = NSBundle.mainBundle().loadNibNamed("ShareView", owner: nil, options: nil)
        var shareView = view[0] as! ShareView
        shareView.fileURL = fileToBeShared
        let imagecell = UINib(nibName: "ImageCell", bundle: nil)
        shareView.sharingView.registerNib(imagecell, forCellWithReuseIdentifier: "ImageCell")
        return shareView
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                cell.photoView.image = UIImage(named: "mail")
            } else {
                cell.photoView.image = UIImage(named: "dropbox")
            }
            return cell
        } else {
            return cell
        }
    }
    
}
