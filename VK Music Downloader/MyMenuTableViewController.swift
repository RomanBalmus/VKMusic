//
//  MyMenuTableViewController.swift
//  Music Player
//
//  Created by iOS on 14/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
import UIKit

class MyMenuTableViewController: UITableViewController {
    var selectedMenuItem : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        if(indexPath.row==0){
            cell!.textLabel?.text = "My Music"

        }else if(indexPath.row==1){
            cell!.textLabel?.text = "Popular"

        }else if(indexPath.row==2){
            cell!.textLabel?.text = "My Groups"

            
        }else if(indexPath.row==3){
            cell!.textLabel?.text = "My Friends"

        }else if(indexPath.row==4){
            cell!.textLabel?.text = "My Local Music"
            
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("Selected row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            //return
        }
        
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
       // let destViewController : UIViewController
        switch (indexPath.row) {
        case 0:
            let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("LISTTABLE_VIEW") as! UINavigationController
            
            let mymusic   = navContrl.viewControllers.first as! MyMusciTableController
            sideMenuController()?.setContentViewController(mymusic)
            mymusic.loadMyMusic()
            
            return
        case 1:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController2")
            let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("LISTTABLE_VIEW") as! UINavigationController
            
            let mymusic   = navContrl.viewControllers.first as! MyMusciTableController
            sideMenuController()?.setContentViewController(mymusic)
            mymusic.loadPopularMusic()
            return
   
        case 2:
            let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("LISTTABLE_VIEW") as! UINavigationController
            
            let mymusic   = navContrl.viewControllers.first as! MyMusciTableController
            sideMenuController()?.setContentViewController(mymusic)
            mymusic.loadDataGroups()
            return
        case 3:
            let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("LISTTABLE_VIEW") as! UINavigationController
            
            let mymusic   = navContrl.viewControllers.first as! MyMusciTableController
            sideMenuController()?.setContentViewController(mymusic)
            mymusic.loadDataFriendUsers()
            
            return
        case 4:
            let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("MY_LOCAL_FILES") as! UINavigationController
            
            let mymusic   = navContrl.viewControllers.first as! MYlocalFilesController
            sideMenuController()?.setContentViewController(mymusic)
            // mymusic.loadDataFriendUsers()
            
            
           /* let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("TEST_MY_LOCAL_FILES_ANIMATION") as! AnimationContainer
            
            sideMenuController()?.setContentViewController(navContrl)*/
            
            return
            
        default:
            return
        }
        
    }
    
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}