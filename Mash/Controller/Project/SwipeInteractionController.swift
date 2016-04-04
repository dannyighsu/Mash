//
//  SwipeInteractionController.swift
//  Mash
//
//  Created by Danny Hsu on 1/5/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interacting: Bool = false
    var shouldCompleteTransition: Bool = false
    var viewController: UIViewController? = nil
    
    func addViewController(viewController: UIViewController) {
        self.viewController = viewController
        self.prepareGestureRecognizerInView(viewController.view)
    }
    
    func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SwipeInteractionController.handleGesture(_:)))
        gesture.edges = UIRectEdge.Top
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!.superview)
        var progress = translation.x / 200
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch sender.state {
        case .Began:
            self.interacting = true
            self.viewController!.dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            self.shouldCompleteTransition = progress > 0.5
            updateInteractiveTransition(progress)
        case .Cancelled:
            self.interacting = false
            cancelInteractiveTransition()
        case .Ended:
            self.interacting = false
            if !self.shouldCompleteTransition {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
        default:
            Debug.printl("Unsupported interaction", sender: self)
        }
    }
    
}
