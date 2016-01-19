//
//  SeparatorViewController.h
//  VK Music Downloader
//
//  Created by iOS on 28/08/15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <VKSdk.h>
@interface SeparatorViewController : UIViewController<VKSdkDelegate,UIAlertViewDelegate>{

}
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@end
