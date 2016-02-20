//
//  ImageCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.20.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import Photos

class ImageCellConfigurator : CellConfigurator {
    var photoAsset: PHAsset
    var cellWidth: CGFloat
    var cellHeight: CGFloat
    
    init(photoAsset : PHAsset, cellWidth : CGFloat, cellHeight : CGFloat) {
        self.photoAsset = photoAsset
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
    }
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let imageCell = cell as! ImageCell
        PHImageManager.defaultManager().requestImageForAsset(self.photoAsset,
            targetSize: CGSize(width: self.cellWidth, height: self.cellHeight),
            contentMode: PHImageContentMode.AspectFit, options: nil) {
                (image, info) in
                imageCell.photoView.image = image
        }
        
    }
}
