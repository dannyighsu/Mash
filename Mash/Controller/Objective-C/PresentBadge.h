//
//  PresentBadge.h
//  Mash
//
//  Created by Eeshan Agarwal on 2/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PresentBadge : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@end
