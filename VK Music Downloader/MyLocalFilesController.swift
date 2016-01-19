//
//  MyLocalFilesController.swift
//  Music Player
//
//  Created by iOS on 16/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
import LNPopupController
class MYlocalFilesController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, ENSideMenuDelegate {
    let filemanager:NSFileManager = NSFileManager()
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
    @IBOutlet weak var myTableView: UITableView!
    var currentAudioIndex:Int!
    var searchBar = UISearchBar()
    var allDataSource = NSMutableArray(capacity: 0)
    //var myPlayer = VideoPlayerManage.instance()
    var searchActive : Bool = false
    var filteredData = NSMutableArray(capacity: 0)
   // private var observerlocal: NSObjectProtocol!

    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBAction func searchButtonClicked(sender: AnyObject) {
        loadSearch()
        showSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TAOverlay .showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen, TAOverlayOptions.OpaqueBackground, TAOverlayOptions.OverlayTypeActivitySquare])

        
        let mylocalArray : NSMutableArray = NSMutableArray()

        let musicNib = UINib(nibName: "MyMusicTableCell", bundle: nil)
        self.myTableView.registerNib(musicNib, forCellReuseIdentifier: "musicCell")
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableCellOnChangeCell:", name:"songChanged", object: nil)
      /*  let mainQueue = NSOperationQueue.mainQueue()
        observerlocal = NSNotificationCenter.defaultCenter().addObserverForName("songChanged", object: nil, queue: mainQueue) { (notification) -> Void in
            self.updateTableCellOnChangeCell(notification)
        }
        */
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpProgress:", name:"PopupProgress", object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissPopup:", name:"PopupDismiss", object: nil)


        self.sideMenuController()?.sideMenu?.delegate = self
        let files = filemanager.enumeratorAtPath(documentsPath)
        while let file: AnyObject = files?.nextObject() {
            let localdict = NSMutableDictionary()
            let stringPath = String(documentsPath+"/"+(file as! String))
            //println("string path \(stringPath)")
          //  let url:NSURL = NSURL.fileURLWithPath(stringPath)!
           // println("url path url \(url)")
            let pathPrefix = file.stringByDeletingPathExtension
            let result = pathPrefix.componentsSeparatedByString(" - ")
            localdict.setObject(result[0], forKey: "artist")
            localdict.setObject(result[1], forKey: "title")
            localdict.setObject(stringPath, forKey: "url")
            print("dict local \(localdict)")
            mylocalArray.addObject(localdict)

        }
        
      self.allDataSource=mylocalArray
       self.myTableView.reloadData()
        //self.myPlayer = nil
        ////self.myPlayer = VideoPlayerManage.instance()
        //self.myPlayer.setPlayerDataSourceWithURLArrayFromLocal(self.allDataSource as NSMutableArray as [AnyObject])
        TAOverlay.hideOverlay()

        
    }
    
    func loadalldata(){
        
    }
   
    //MARK searchbar
    func loadSearch(){
        //let logoImage = UIImage(named: "logo")!
        //logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: logoImage.size.width, height: logoImage.size.height))
        //logoImageView.image = logoImage
        // navigationItem.titleView = logoImageView
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.showsCancelButton=true
        searchBarButtonItem = navigationItem.rightBarButtonItem
        // var tapGesture = UITapGestureRecognizer(target: self, action: "showSearchBar")
        //tapGesture.numberOfTapsRequired=1
        // navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        
        /*var subview : UIView!
        
        for subview in searchBar.subviews
        {
            
            if subview.conformsToProtocol(UITextInputTraits)
            {
                let edit : UITextField = subview as! UITextField
                edit.returnKeyType=UIReturnKeyType.Done
            }
            
        }
       */
    }
    
    func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        //navigationItem.setRightBarButtonItem(nil, animated: true)
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })
    }
    
    func hideSearchBar() {
        //navigationItem.setRightBarButtonItem(searchBarButtonItem, animated: true)
        // logoImageView.alpha = 0
        UIView.animateWithDuration(0.3, animations: {
            self.navigationItem.titleView = nil
            //self.logoImageView.alpha = 1
            }, completion: { finished in
                
        })
    }
    
    
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
        searchActive = false;
        searchBar.text=nil
        self.filteredData .removeAllObjects()
        if(self.filteredData.count==0){
            self.myTableView.reloadData()

        }
        print("searchBarCancelButtonClicked")


    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
        print("searchBarTextDidEndEditing")

    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText==""){
            print("textDidChange")
            searchActive = false;
            filterContentForSearchText(searchText)

        }

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
       //self.filterContentForSearchText(searchBar.text)
        print("searchBarSearchButtonClicked")
     
        searchBar.resignFirstResponder()
        // Do the search...
        searchActive = false;
        hideSearchBar()

 
        
    }

    func filterContentForSearchText(searchText: String) {
      
            let searchTextTrimmed = (searchText as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        print("text: \(searchTextTrimmed)")

        
         let predicate = NSPredicate(format: "(SELF.title contains [cd]%@) OR (SELF.artist contains [cd]%@)", searchTextTrimmed,searchTextTrimmed)
            let listItemToBeDisplayed = self.allDataSource.filteredArrayUsingPredicate(predicate)
            print("filtered: \(listItemToBeDisplayed)")
        if(listItemToBeDisplayed.count == 0){
            searchActive = false;
        } else {
            self.filteredData = NSMutableArray(array: listItemToBeDisplayed)
            searchActive = true;
        }
        self.myTableView.reloadData()
        
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //let s = (searchBar.text as NSString).stringByReplacingCharactersInRange(range, withString:text)
        if let swRange = searchBar.text!.rangeFromNSRange(range) {
            let newString = searchBar.text!.stringByReplacingCharactersInRange(swRange, withString: text)
            // ...
            self.filterContentForSearchText(newString)

        }
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
       
            return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredData.count
        }
        if self.allDataSource.count == 0{
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = "No files.\nConnect to VK and download some files."
            emptyLabel.lineBreakMode=NSLineBreakMode.ByWordWrapping
            emptyLabel.numberOfLines=0
            emptyLabel.textAlignment=NSTextAlignment.Center
            
            self.myTableView.backgroundView = emptyLabel
            self.myTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        }
        return self.allDataSource.count
        
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("musicCell", forIndexPath: indexPath) as? MyMusicTableCell
        {
            // Configure the cell for this indexPath
            var song = NSDictionary();
            if(searchActive){
                song = self.filteredData.objectAtIndex(indexPath.row) as! NSDictionary
            } else {
                song = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
            }
            let artist = song.objectForKey("artist") as! String
            let songtitle = song.objectForKey("title") as! String
            
            let artistAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 17.0)! ]
            let titleAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 11.0)! ]
            
            let aAttr = NSMutableAttributedString(string: artist, attributes: artistAttribute )
            let tAttr = NSMutableAttributedString(string:"\n"+songtitle, attributes: titleAttribute )
            aAttr.appendAttributedString(tAttr)
            
            cell.headingLabel.attributedText=aAttr
            // Make sure the constraints have been added to this cell, since it may have just been created from scratch
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            
            return cell
            
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: false)

        showBar("", subtitle: "",dataSource: self.allDataSource, index: indexPath.row)

        if(searchActive){
            var song = NSDictionary();
            song = self.filteredData.objectAtIndex(indexPath.row) as! NSDictionary

            let mycell = tableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
                if(mycell != nil){
                //self.myPlayer.playWithIndex(self.allDataSource.indexOfObject(song))
                return
            }
            
            
            
        } else {
            let mycell = tableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
                if (mycell != nil){
                //self.myPlayer.playWithIndex(indexPath.row)
                return
            }
        }
      
        
        
        
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let Download = UITableViewRowAction(style: .Normal, title: "Download") { action, index in
            print("more button  tapped row \(index)")
            
            var dict = NSDictionary()
            dict = self.allDataSource.objectAtIndex(index.row) as! NSDictionary
            
            let url = NSURL(string: dict.objectForKey("url") as! String)
            let artist = dict.objectForKey("artist") as! String
            let sonname = dict.objectForKey("title") as! String
            let filename = artist+" - "+sonname+".mp3"
            HttpDownloader.loadFileAsync(url!,filename: filename,index: index.row, completion:{(path:String,index: NSInteger, error:NSError!) in
                print("file downloaded to: \(path)")
                print("at index: \(index)")
                
            })
            
        }
        Download.backgroundColor = UIColor.lightGrayColor()
        
        let Delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("Delete button  tapped row \(index)")
            var dict = NSDictionary()
            dict = self.allDataSource.objectAtIndex(index.row) as! NSDictionary
            let error:NSErrorPointer = NSErrorPointer()
            let fileurl = NSURL(fileURLWithPath: dict.objectForKey("url") as! String)
            do {
                try self.filemanager.removeItemAtURL(fileurl)
            } catch let error1 as NSError {
                error.memory = error1
            } catch {
                fatalError()
            }
            if error != nil {
                print("error delete: \(error.debugDescription)")
            }
            dispatch_async(dispatch_get_main_queue(), {
                //self.myPlayer.removeItemAtIndex(index.row)
                self.allDataSource.removeObjectAtIndex(index.row)
                self.myTableView.reloadData()
               
                
                
            })
            
        }
        Delete.backgroundColor = UIColor.orangeColor()
        
        let share = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
            print("share button  tapped row \(index)")
        }
        share.backgroundColor = UIColor.blueColor()
        
        return [share,Delete]
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
        print("commitEditingStyle \(indexPath)")

    }
    
    
    
  
    func updateTableCellOnChangeCell(notification: NSNotification){
        //Take Action on Notification
        // println("updateTableCellOnChangeCell index: \(notification.userInfo)")
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let index : NSInteger = tmp["index"] as! NSInteger
        let indexPath=NSIndexPath(forRow: index, inSection: 0)
       // showBar(tmp["artist"] as! String,subtitle: tmp["title"] as! String)
      
        let frame=self.myTableView.rectForRowAtIndexPath(indexPath) as CGRect
        
        
        
          let cell = self.myTableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
            if (cell != nil){
            self.myTableView .selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            
            
        }
        if(frame.origin.y<self.myTableView.contentOffset.y){// the row is above visible rect
            print("visible index: \(indexPath)")
            UIView.animateWithDuration(0.25, animations: {
                self.myTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                
                
                }, completion: {
                    (value: Bool) in
                    
                    self.myTableView .selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    
                    
            })
            
            
        }else if(frame.origin.y+frame.size.height>self.myTableView.contentOffset.y+self.myTableView.frame.size.height-self.myTableView.contentInset.top-self.myTableView.contentInset.bottom){ // the row is below visible rect
            print("not visible index: \(indexPath)")
            UIView.animateWithDuration(0.25, animations: {
                self.myTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                
                
                }, completion: {
                    (value: Bool) in
                    
                    
                    self.myTableView .selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                    
            })
            
        }
        
        // var index: NSInteger=NSInteger(inte
        
    }
    
   
    func popUpProgress(notification: NSNotification){
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let progress : Float = tmp["progress"] as! Float
        //let durationTime : CGFloat = tmp["durationTime"] as! CGFloat
        self.popupItem.progress += progress
        
        //print("popUpProgress \(progress)")

        
    }
    func dismissPopup(notification: NSNotification){
        self.navigationController?.dismissPopupBarAnimated(true, completion: nil)
    }
    //MARK: menu
    @IBAction func toggleSideMenu(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
        
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
        
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose11")
        
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }


    
    func showBar(title:String,subtitle:String, dataSource:NSMutableArray,index: Int){
        
        if (self.navigationController!.popupContentViewController != nil){
            print("already here \(self.navigationController?.popupContentViewController)")
          let testvc = self.navigationController?.popupContentViewController as! TestPlayerViewController
            testvc.playType = 1
            testvc.addDataSourceToPlayerAndPlayAtIndex(dataSource, index: index)
            self.navigationController!.popupItem.title=title
            self.navigationController!.popupItem.subtitle=subtitle
            return
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("NavTestPlayerViewController") as! UINavigationController
        
        let demoVC   = navContrl.viewControllers.first as! TestPlayerViewController
        demoVC.playType = 1
        //demoVC.playerDataSource = dataSource
       demoVC.addDataSourceToPlayerAndPlayAtIndex(dataSource, index: index)
        /* demoVC.popupItem.title=title
        demoVC.popupItem.subtitle=subtitle
        demoVC.popupItem.progress=0*/
        
        /*if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == .Pad {
        demoVC.popupItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "prev"), style: .Plain, target: nil, action: nil),
        UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: nil, action: nil),
        UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .Plain, target: nil, action: nil)]
        demoVC.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "next-1"), style: .Plain, target: nil, action: nil),
        UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: nil, action: nil)]
        }
        else {*/
        // demoVC.popupItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "action"), style: .Plain, target: nil, action: nil)]
        // }
        self.navigationController!.toolbar.tintColor=UIColor.redColor()
        
        self.navigationController!.presentPopupBarWithContentViewController(demoVC, animated: true, completion: nil)
        
    }
 
    
   /* deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "songChanged", object: nil)
         NSNotificationCenter.defaultCenter().removeObserver(observerlocal)
        print("deinit")
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "songChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(observerlocal)
        print("viewWillDisappear")
        
    }*/
    
}
extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
}
