//
//  ProjectTransitionAnimationController.swift
//  Mash
//
//  Created by Danny Hsu on 1/5/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class ProjectTransitionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originFrame: CGRect = CGRectZero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        
        let startFrame = self.originFrame
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = startFrame
        snapshot.alpha = 0
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        toVC.view.hidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
            /*UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
            })*/
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/2, animations: {
                snapshot.layer.transform = AnimationHelper.yRotation(0.0)
            })
            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2, animations: {
                snapshot.frame = finalFrame
            })
            snapshot.alpha = 1
            }, completion: {
                (finished: Bool) in
                toVC.view.hidden = false
                fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
}

struct AnimationHelper {
    
    static func yRotation(angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func perspectiveTransformForContainerView(containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}
