//
//  AnimationContainer.swift
//  VK Music Downloader
//
//  Created by iOS on 18/09/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class AnimationContainer: UIViewController {
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var tabBar : UITabBar!
    @IBOutlet weak var miniPlayerView : LineView!
    var animator : ARNTransitionAnimator!
    var modalVC : TestPlayerViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.modalVC = storyboard.instantiateViewControllerWithIdentifier("TestPlayerViewController") as? TestPlayerViewController
        self.modalVC.modalPresentationStyle = .Custom
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self!.animator.interactiveType = .None
        }
        
        self.setupAnimator()
    
    }
    
    
    //MARK: TRANSITIONS
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .Present, fromVC: self.navigationController!, toVC: modalVC)
        self.animator.usingSpringWithDamping = 0.8
        self.animator.gestureTargetView = self.miniPlayerView
        self.animator.interactiveType = .Present
        
        // Present
        
        self.animator.presentationBeforeHandler = { [weak self] (containerView: UIView, transitionContext:
            UIViewControllerContextTransitioning) in
            self!.animator.direction = .Top
            
            self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
            containerView.addSubview(self!.view)
            self!.view.insertSubview(self!.modalVC.view, belowSubview: self!.tabBar)
            
            self!.modalVC.view.layoutIfNeeded()
            
            // miniPlayerView
            let startOriginY = self!.miniPlayerView.frame.origin.y
            let endOriginY = -self!.miniPlayerView.frame.size.height
            let diff = -endOriginY + startOriginY
            // tabBar
            let tabStartOriginY = self!.tabBar.frame.origin.y
            let tabEndOriginY = containerView.frame.size.height
            let tabDiff = tabEndOriginY - tabStartOriginY
            
            self!.animator.presentationCancelAnimationHandler = { (containerView: UIView) in
                self!.miniPlayerView.frame.origin.y = startOriginY
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY
                self!.containerView.alpha = 1.0
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0
                }
            }
            
            self!.animator.presentationAnimationHandler = { [weak self] (containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= 0 ? percentComplete : 0
                self!.miniPlayerView.frame.origin.y = startOriginY - (diff * _percentComplete)
                if self!.miniPlayerView.frame.origin.y < endOriginY {
                    self!.miniPlayerView.frame.origin.y = endOriginY
                }
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY + (tabDiff * _percentComplete)
                
                self!.containerView.alpha = 1.0 - (1.0 * _percentComplete) + 0.5
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0 - (1.0 * percentComplete)
                }
            }
            
            self!.animator.presentationCompletionHandler = {(containerView: UIView, completeTransition: Bool) in
                if completeTransition {
                    self!.view.removeFromSuperview()
                    self!.modalVC.view.removeFromSuperview()
                    containerView.addSubview(self!.modalVC.view)
                    self!.animator.interactiveType = .Dismiss
                    self!.animator.gestureTargetView = self!.modalVC.imageView
                    self!.animator.direction = .Bottom
                } else {
                    UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                }
            }
        }
        
        // Dismiss
        
        self.animator.dismissalBeforeHandler = { [weak self] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            containerView.addSubview(self!.view)
            self!.view.insertSubview(self!.modalVC.view, belowSubview: self!.tabBar)
            
            self!.view.layoutSubviews()
            
            let startOriginY = 0 - CGRectGetHeight(self!.miniPlayerView.bounds)
            let endOriginY = CGRectGetHeight(self!.containerView.bounds) - self!.miniPlayerView.frame.size.height
            let diff = -startOriginY + endOriginY
            let tabStartOriginY = CGRectGetHeight(containerView.bounds)
            let tabEndOriginY = CGRectGetHeight(containerView.bounds) - CGRectGetHeight(self!.tabBar.bounds)
            let tabDiff = tabStartOriginY - tabEndOriginY
            
            self!.tabBar.frame.origin.y = CGRectGetHeight(containerView.bounds)
            
            self!.animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                self!.miniPlayerView.frame.origin.y = startOriginY
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY
                self!.containerView.alpha = 0.0
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 0.0
                }
            }
            
            self!.animator.dismissalAnimationHandler = {(containerView: UIView, percentComplete: CGFloat) in
                let _percentComplete = percentComplete >= -0.05 ? percentComplete : -0.05
                self!.miniPlayerView.frame.origin.y = startOriginY + (diff * _percentComplete)
                self!.modalVC.view.frame.origin.y = self!.miniPlayerView.frame.origin.y + self!.miniPlayerView.frame.size.height
                self!.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  _percentComplete)
                
                self!.containerView.alpha = (1.0 * _percentComplete)
                for subview in self!.miniPlayerView.subviews {
                    subview.alpha = 1.0 * _percentComplete
                }
            }
            
            self!.animator.dismissalCompletionHandler = { (containerView: UIView, completeTransition: Bool) in
                if completeTransition {
                    self!.modalVC.view.removeFromSuperview()
                    self!.animator.gestureTargetView = self!.miniPlayerView
                    self!.animator.interactiveType = .Present
                    UIApplication.sharedApplication().keyWindow!.addSubview(self!.view)
                }
            }
        }
        
        modalVC.transitioningDelegate = self.animator
    }

}