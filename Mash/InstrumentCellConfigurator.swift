//
//  InstrumentCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.19.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class InstrumentCellConfigurator : CellConfigurator {
    var instrument: String
    
    init(instrument: String) {
        self.instrument = instrument;
    }
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let instrumentCell = cell as! InstrumentCell
        
        let selection = UIImageView(frame: instrumentCell.frame)
        selection.layer.borderColor = lightGray().CGColor
        instrumentCell.selectedBackgroundView = selection
        instrumentCell.instrumentImage.image = findImage([self.instrument])
        instrumentCell.backgroundColor = offWhite()
        instrumentCell.instrumentLabel.text = self.instrument
    }
    
    func highlightCellSelection(cell: InstrumentCell, isSelected: Bool) {
        cell.layer.borderColor = lightGray().CGColor
        cell.layer.borderWidth = isSelected ? 5.0 : 0.0
    }
}