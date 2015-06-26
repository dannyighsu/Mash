//
//  RecordSplashScreenController.m
//  Mash
//
//  Created by Eeshan Agarwal on 3/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import "RecordSplashScreenController.h"
#import "PresentBadge.h"
#import "DismissBadge.h"
#import "RecordViewController.h"
#import "Mash_iOS-Swift.h"

@interface RecordSplashScreenController () <UIViewControllerTransitioningDelegate>

@end

@implementation RecordSplashScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpInitialScreen];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = self.mikeButton;
    [button addTarget:self action:@selector(beginRecord) forControlEvents:UIControlEventTouchUpInside];
    
    Metronome *metronome = [Metronome createView];
    self.metronomeView = metronome;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setUpInitialScreen
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction  animations:^{
        self.mikeButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {

    }];
}

/* - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"PushSegue"]) {
        UIViewController* controller = (UIViewController*)segue.destinationViewController;
        controller.transitioningDelegate = self; // 1
        controller.modalPresentationStyle = UIModalPresentationCustom; // 2
        controller.modalPresentationCapturesStatusBarAppearance = YES; // 3
    }
}*/

- (void)beginRecord
{
    UIStoryboard *storyboard = self.storyboard;
    RecordViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    [self.navigationController pushViewController:svc animated:YES];
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[PresentBadge alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DismissBadge alloc] init];
    
}


@end
