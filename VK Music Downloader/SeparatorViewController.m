//
//  SeparatorViewController.m
//  VK Music Downloader
//
//  Created by iOS on 28/08/15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import "SeparatorViewController.h"
#import "IntroSegue.h"
static NSString *const TOKEN_KEY = @"n62Sh0D6eLxyfRactWLZ";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"showMainNoIntro";
static NSArray  * SCOPE = nil;
@interface SeparatorViewController ()

@end

@implementation SeparatorViewController

- (void)viewDidLoad {
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES, VK_PER_GROUPS];

    [super viewDidLoad];
    self.myImageView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    self.myImageView.layer.cornerRadius=150;
    self.myImageView.layer.borderWidth=12.0;
    self.myImageView.layer.masksToBounds = YES;
    self.myImageView.layer.borderColor=[[UIColor orangeColor] CGColor];
  
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [self performSelector:@selector(go) withObject:nil afterDelay:2.0];
}

-(void)go{
    // Do any additional setup after loading the view.
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *previousBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    [VKSdk initializeWithDelegate:self andAppId:@"5048489"];
    
    if (![currentBundleVersion isEqualToString:previousBundleVersion] ) {
        // Here you can initialize your introduction view and present it!
        //INTRO
        [self performSegueWithIdentifier:@"showIntro" sender:self];
        
        
    }else{
        //[self performSegueWithIdentifier:@"showMainNoIntro" sender:self];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"token"]==NULL) {
            [self  authorize:nil];
            return;
        }else{
            if ([VKSdk wakeUpSession])
            {
                
               
                [self startWorking];
            }
        }
        
        
        
    }
}

-(void)startWorking{
    [self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:self];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        NSLog(@"show %@",segue.identifier);
        /* CATransition* transition = [CATransition animation];
         transition.duration = 2.5;
         transition.type = kCATransitionMoveIn;
         transition.subtype = kCATransitionFromRight;
         [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];*/
    
 
    ((IntroSegue *)segue).originatingPoint = self.view.center;

    
    
}


#pragma VKDSDKDELEGATE
/*– vkSdkNeedCaptchaEnter: required method
 – vkSdkTokenHasExpired: required method
 – vkSdkUserDeniedAccess: required method
 – vkSdkShouldPresentViewController: required method
 – vkSdkReceivedNewToken: required method
 – vkSdkAcceptedUserToken:
 – vkSdkRenewedToken:
 – vkSdkAuthorizationAllowFallbackToSafari
 – vkSdkIsBasicAuthorization
 – vkSdkWillDismissViewController:
 – vkSdkDidDismissViewController:*/

-(void)vkSdkAcceptedUserToken:(VKAccessToken *)token{
    NSLog(@"vkSdkAcceptedUserToken: %@",token);
}
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}
-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    NSLog(@"vkSdkTokenHasExpired: %@",expiredToken.accessToken);

}
-(void)vkSdkUserDeniedAccess:(VKError *)authorizationError{
    NSLog(@"vkSdkUserDeniedAccess: %@",authorizationError.errorMessage);
    if (authorizationError.errorMessage ==NULL) {
        
        
    }else{
      UIAlertView*alert=  [[UIAlertView alloc] initWithTitle:nil message:authorizationError.errorMessage  delegate:self cancelButtonTitle:@"Try again" otherButtonTitles:nil] ;
        alert.tag=1;
        [alert show];

    }

}
-(void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    NSLog(@"vkSdkShouldPresentViewController: %@",controller.class);

}
-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
    NSLog(@"vkSdkReceivedNewToken: %@",newToken.accessToken);
    [[NSUserDefaults standardUserDefaults]setObject:newToken.accessToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]==NULL) {
        VKRequest *request = [[VKApi users] get];
        [request executeWithResultBlock: ^(VKResponse *response) {
            NSLog(@"Result owner: %@", response);
            [[NSUserDefaults standardUserDefaults]setObject:[[response.json objectAtIndex:0]objectForKey:@"id"] forKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //[self getMusic:[VKRequest requestWithMethod:@"audio.get" andParameters:@{VK_API_USER_ID : [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"need_user":@"0"} andHttpMethod:@"POST"]];
            [self startWorking];
            
        } errorBlock: ^(NSError *error) {
            NSLog(@"Error owner: %@", error);
            [self startWorking];
            
        }];
    }else{
        [self startWorking];
    }
}
-(void)vkSdkRenewedToken:(VKAccessToken *)newToken{
    NSLog(@"vkSdkRenewedToken: %@",newToken.accessToken);
    
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"token"]isEqualToString:newToken.accessToken]) {
        [VKSdk authorize:SCOPE];

    }
    [[NSUserDefaults standardUserDefaults]setObject:newToken.accessToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self startWorking];

}
-(BOOL)vkSdkAuthorizationAllowFallbackToSafari{
    NSLog(@"vkSdkAuthorizationAllowFallbackToSafari");
    return YES;
}

-(void)vkSdkWillDismissViewController:(UIViewController *)controller{
    NSLog(@"vkSdkWillDismissViewController: %@",controller.class);

}
-(void)vkSdkDidDismissViewController:(UIViewController *)controller{
    NSLog(@"vkSdkDidDismissViewController: %@",controller.class);

}


/*- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authorize:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self startWorking];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}*/
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)authorize:(id)sender {
    [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (IBAction)authorizeForceOAuth:(id)sender {
    [VKSdk authorize:SCOPE revokeAccess:YES forceOAuth:YES];
}

- (IBAction)authorizeForceOAuthInApp:(id)sender {
    [VKSdk authorize:SCOPE revokeAccess:YES forceOAuth:YES inApp:YES display:VK_DISPLAY_MOBILE];
}
- (IBAction)openShareDialog:(id)sender {
    VKShareDialogController * shareDialog = [VKShareDialogController new];
    shareDialog.text         = @"This post created using #vksdk #ios";
    //    shareDialog.vkImages     = @[@"-10889156_348122347",@"7840938_319411365",@"-60479154_333497085"];
    shareDialog.shareLink    = [[VKShareLink alloc] initWithTitle:@"Super puper link, but nobody knows" link:[NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]];
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:shareDialog animated:YES completion:nil];
}


#pragma ALERYVIEWDELEGATE
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex==0) {
            [self authorize:nil];
        }
    }
}
@end
