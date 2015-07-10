//
//  ImageViewController.swift
//  Mash
//
//  Created by Danny Hsu on 7/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var images: UICollectionView!
    var data: PHFetchResult = PHFetchResult()
    var photoManager: PHImageManager = PHImageManager.defaultManager()
    var cellWidth: CGFloat = 75.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UINib(nibName: "ImageCell", bundle: nil)
        self.images.registerNib(image, forCellWithReuseIdentifier: "ImageCell")
        self.images.delegate = self
        self.images.dataSource = self
        self.cellWidth = self.images.frame.size.width / 3 - 4.0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.images.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let photo = self.data[indexPath.row] as! PHAsset
        self.photoManager.requestImageForAsset(photo, targetSize: CGSize(width: self.cellWidth, height: self.cellWidth), contentMode: PHImageContentMode.AspectFit, options: nil) {
            (image, info) in
            cell.photoView.image = image
            cell.photo = photo
        }
        return cell
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dashboard = getTabBarController("dashboard", self.navigationController!) as! DashboardController
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
        self.navigationController?.popViewControllerAnimated(true)
        dashboard.updateProfilePic(cell.photo!)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
}
