//
//  PresentBadge.m
//  Mash
//
//  Created by Eeshan Agarwal on 2/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import "PresentBadge.h"
#import "RecordSplashScreenController.h"

@implementation PresentBadge


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    UIView *containerView = [transitionContext containerView];
    
    RecordSplashScreenController *fromViewController = (RecordSplashScreenController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [containerView addSubview:toViewController.view];
    
    UIButton *mikeButton = fromViewController.mikeButton;
    
    UIBezierPath *circleMaskPathInitial = [UIBezierPath bezierPathWithOvalInRect:mikeButton.frame];
    
    CGPoint extremePoint = CGPointMake(mikeButton.center.x - 0, mikeButton.center.y - toViewController.view.bounds.size.height);
    
    CGFloat radium = sqrt(extremePoint.x * extremePoint.x + extremePoint.y * extremePoint.y);
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectInset(mikeButton.frame, -radium, -radium)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = finalPath.CGPath;
    
    toViewController.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (id) circleMaskPathInitial.CGPath;
    maskLayerAnimation.toValue = (id) finalPath.CGPath;
    
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
}

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.transitionContext completeTransition:YES];
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController.view.layer.mask = nil;
}

@end
