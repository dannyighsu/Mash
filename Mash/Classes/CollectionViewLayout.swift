//
//  CollecitionViewLayout.swift
//  Mash
//
//  Created by Danny Hsu on 10/26/15.
//  Copyright © 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .Vertical
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}
