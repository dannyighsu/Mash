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
    var imageCellConfigurators: [ImageCellConfigurator] = []
    var type: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UINib(nibName: "ImageCell", bundle: nil)
        self.images.registerNib(image, forCellWithReuseIdentifier: "ImageCell")
        self.images.delegate = self
        self.images.dataSource = self
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.images.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let configurator = self.imageCellConfigurators[indexPath.row]
        configurator.configure(cell, viewController: self)
        return cell
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCellConfigurators.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dashboard = getTabBarController("dashboard", navcontroller: self.navigationController!) as! DashboardController
        let configurator = self.imageCellConfigurators[indexPath.item]
        self.navigationController?.popViewControllerAnimated(true)
        if self.type == "profile" {
            dashboard.updateProfilePic(configurator.photoAsset)
        } else {
            dashboard.updateBanner(configurator.photoAsset)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let configurator = self.imageCellConfigurators[indexPath.item]
        return CGSize(width: configurator.cellWidth, height: configurator.cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
}
