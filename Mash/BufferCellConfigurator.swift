//
//  BufferCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.20.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class BufferCellConfigurator : CellConfigurator {
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let bufferCell = cell as! BufferCell
        bufferCell.backgroundColor = UIColor.clearColor()
    }
}