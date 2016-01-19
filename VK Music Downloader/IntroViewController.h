//
//  IntroViewController.h
//  VK Music Downloader
//
//  Created by iOS on 27/08/15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *thePager;
@property (weak, nonatomic) IBOutlet UILabel *theLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *theScroll;

@property (nonatomic, strong) NSArray *imgs;
@property (nonatomic, getter=isHideStatusBar) BOOL hideStatusBar; // Give this a default value early
@property (weak, nonatomic) IBOutlet UILabel *theTitleLabel;
- (IBAction)goButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemAvanti;

@end
