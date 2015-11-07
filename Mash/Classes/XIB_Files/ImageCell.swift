//
//  ImageCell.swift
//  Mash
//
//  Created by Danny Hsu on 7/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    var photo: PHAsset? = nil
    
}
