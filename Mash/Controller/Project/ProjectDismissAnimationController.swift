//
//  ProjectDismissAnimationController.swift
//  Mash
//
//  Created by Danny Hsu on 1/5/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class ProjectDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var destinationFrame: CGRect = CGRectZero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        let startFrame = transitionContext.finalFrameForViewController(toVC)
        let finalFrame = self.destinationFrame
        let snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = startFrame
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        fromVC.view.hidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        //toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/2, animations: {
                snapshot.frame = finalFrame
            })
            /*UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
            })*/
            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2, animations: {
                toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
            })
            snapshot.alpha = 0.0
            }, completion: {
                (finished: Bool) in
                fromVC.view.hidden = false
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
}
