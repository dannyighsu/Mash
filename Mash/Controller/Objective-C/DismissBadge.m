//
//  DismissBadge.m
//  Mash
//
//  Created by Eeshan Agarwal on 2/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import "DismissBadge.h"

@implementation DismissBadge

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *detail = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [UIView animateWithDuration:0.4 animations:^{ // fade-out the card in 0.4 seconds
        detail.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [detail.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}


@end
