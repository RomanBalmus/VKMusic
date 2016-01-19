//
//  IntroViewController.m
//  VK Music Downloader
//
//  Created by iOS on 27/08/15.
//  Copyright (c) 2015 iOS. All rights reserved.
//

#import "IntroViewController.h"
#import "IntroSegue.h"

@interface IntroViewController (){
     BOOL visible;
}

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
 
        // Here you can initialize your introduction view and present it!
        //INTRO

  
}


-(void)viewDidAppear:(BOOL)animated{
    [self setupScrollView];

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
-(void) setupScrollView {
    //add the scrollview to the view
    //self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height)];
    
    
    
    
    [self.navigationController.navigationBar setHidden:YES];
    [self setHideStatusBar:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    self.theScroll.pagingEnabled = YES;
    [self.theScroll setAlwaysBounceVertical:NO];
    visible=NO;
    //setup internal views
    
    
    
    NSInteger numberOfViews = 3;
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.view.frame.size.width;
        UIImageView *image = [[UIImageView alloc] initWithFrame:
                              CGRectMake(xOrigin, 0,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height)];
        if (i==0) {
            image.image = [UIImage imageNamed:@"intro1"];
        }else if (i==1){
            image.image = [UIImage imageNamed:@"intro2"];
            
        }else if (i==2){
            image.image = [UIImage imageNamed:@"intro3"];
            
        }
        
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.theScroll addSubview:image];
    }
    //set the scroll view content size
    self.theScroll.contentSize = CGSizeMake(self.view.frame.size.width *
                                            numberOfViews,
                                            self.view.frame.size.height);
    
    self.theScroll.bounces = NO;
    
    UIImageView *iv=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"worlintro"]];
    [iv setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.theScroll.contentSize.width, self.view.frame.size.height)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.theScroll addSubview:iv];
    [self.theScroll sendSubviewToBack:iv];
    self.theScroll.delegate=self;
    self.thePager.currentPage=0;
    self.theTitleLabel.text=@"CERTIFICARE";
    self.theLabel.text = @"tulain® permette di certificare l’autenticità di un prodotto, tutelando in tal modo il produttore, il cliente finale e la qualità del prodotto stesso.";
    
    
    
    
    
    // self.theLabel.numberOfLines=0;
    
    //add the scrollview to this view
    //[self.view addSubview:self.scrollView];
    
}
// handle the swipes here
- (void)didSwipeScreen:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            // you can include this case too
            NSLog(@"UISwipeGestureRecognizerDirectionUp");
            break;
        case UISwipeGestureRecognizerDirectionDown:
            // you can include this case too
            NSLog(@"UISwipeGestureRecognizerDirectionDown");
            
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            NSLog(@"UISwipeGestureRecognizerDirectionLeft");
            
            break;
        case UISwipeGestureRecognizerDirectionRight:
            NSLog(@"UISwipeGestureRecognizerDirectionRight");
            
            // disable timer for both left and right swipes.
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    NSLog(@"dddd %ld",(long)page);
    if (previousPage != page) {
        previousPage = page;
        /* Page did change */
        
        self.thePager.currentPage=previousPage;
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3
        ;
        animation.type = kCATransitionFade;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.theLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
        if (previousPage==0) {
            self.theTitleLabel.text=@"CERTIFICARE";
            self.theLabel.text = @"tulain® permette di certificare l’autenticità di un prodotto, tutelando in tal modo il produttore, il cliente finale e la qualità del prodotto stesso.";
            
        }else if (previousPage==1){
            self.theTitleLabel.text=@"TRACCIARE";
            self.theLabel.text = @"tulain® permette di tracciare l’intera filiera distributiva di qualsiasi merce, dall’uscita dallo stabilimento fino al cliente finale, certificando e memorizzando tutte le informazioni riferite alle fasi di produzione, al trasporto, ai passaggi commerciali, al venditore, fino ad arrivare al consumatore.";
            if (visible) {
                
                
                
                
                [UIView animateWithDuration:0.45 animations:^{
                    [self.navigationController.navigationBar setHidden:visible];
                    [self setHideStatusBar:visible];
                    [self setNeedsStatusBarAppearanceUpdate];
                } completion:^(BOOL finished) {
                    visible=NO;
                }];
                
            }
            
        }else if(previousPage==2){
            self.theTitleLabel.text=@"INFORMARE";
            self.theLabel.text = @"tulain® permette di informare in modo innovativo il cliente finale, fornendogli gli strumenti necessari per raggiungere una piena consapevolezza di quello che ha acquistato, rendendolo parte veramente attiva.";
            
            
            
            [UIView animateWithDuration:0.45 animations:^{
                [self setHideStatusBar:visible];
                [self setNeedsStatusBarAppearanceUpdate];
                [self.navigationController.navigationBar setHidden:visible];
                
            } completion:^(BOOL finished) {
                visible=YES;
            }];
            
            
            
            
            
        }
        // Change the text
        
        
        
    }
    
}
- (BOOL)prefersStatusBarHidden {
    return self.isHideStatusBar;
}




- (IBAction)goButtonClicked:(id)sender {
    NSString *currentBundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        
        //[standardUserDefaults setObject:currentBundleVersion forKey:@"PreviousBundleVersion"];
        [standardUserDefaults setObject:@"1" forKey:@"PreviousBundleVersion"];
        
        [standardUserDefaults synchronize];
        
        
        
    }
   // [self performSegueWithIdentifier:@"showMainIntro" sender:self];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    
    
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMainIntro"]) {
        NSLog(@"show main");
       /* CATransition* transition = [CATransition animation];
        transition.duration = 2.5;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];*/
        
         ((IntroSegue *)segue).originatingPoint = self.view.center;
        
    }

}
@end
