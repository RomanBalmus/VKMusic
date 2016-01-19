//
//  AppDelegate.swift
//  VK Music Downloader
//
//  Created by iOS on 17/09/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  /*
        do {
            // Override point for customization after application launch.
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        } */
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

        
        return true
    }
    
 
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
       
       // NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "resumePlayback", userInfo: nil, repeats: false)
    }
    func resumePlayback(){
        if(VideoPlayerManage.instance().queuePlayer.rate == 0){
            VideoPlayerManage.instance().pause()
        }else{
            do {
                // Override point for customization after application launch.
                
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch _ {
            }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ {
            }
            VideoPlayerManage.instance().play()
            
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        // print("remoteControlReceivedWithEvent \(event)")
        if (event!.type == UIEventType.RemoteControl) {
            //   print("UIEventType.RemoteControl \(event.type)")
            
            switch (event!.subtype) {
            case UIEventSubtype.RemoteControlTogglePlayPause:
                //print("UIEventSubtype.RemoteControlTogglePlayPause \(event.subtype)")
                
                //NSLog("queuePlayer.rate = %f", VideoPlayerManage.instance().queuePlayer.rate);
             
                
                if(HysteriaPlayer.sharedInstance().isPlaying()){
                    HysteriaPlayer.sharedInstance().pause()
                }else{
                    HysteriaPlayer.sharedInstance().play()
                }
                break;
                
                
            case UIEventSubtype.RemoteControlPause:
                // print("RemoteControlPause \(event.subtype)")
               
                if(HysteriaPlayer.sharedInstance().isPlaying()){
                    HysteriaPlayer.sharedInstance().pause()
                }
                break;
            case UIEventSubtype.RemoteControlPlay:
                // print("RemoteControlPlay \(event.subtype)")
                if(!HysteriaPlayer.sharedInstance().isPlaying()){
                
                    HysteriaPlayer.sharedInstance().play()
                }
                break;
            case UIEventSubtype.RemoteControlNextTrack:
                if(HysteriaPlayer.sharedInstance().isPlaying()){
                    HysteriaPlayer.sharedInstance().playNext()
                }
                break;
                
            case UIEventSubtype.RemoteControlPreviousTrack:
                if(HysteriaPlayer.sharedInstance().isPlaying()){
                    HysteriaPlayer.sharedInstance().playPrevious()
                }
                break;
                
            default:
                break;
            }
            
        }
    }
    
    func endInterruptionWithFlags(flags:NSInteger){
        VideoPlayerManage.instance().play()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        VKSdk .handleDidBecomeActive()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }
    
    
    
}