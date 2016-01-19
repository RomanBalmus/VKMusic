//
//  MyMusicTableController.swift
//  Music Player
//
//  Created by iOS on 14/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
class MyMusciTableController : UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,ENSideMenuDelegate{
    @IBOutlet weak var myTableView: UITableView!
    var currentAudioIndex:Int!
    var searchBar = UISearchBar()
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBAction func searchButtonClicked(sender: AnyObject) {
        loadSearch()
        showSearchBar()
    }
    var filteredData = NSMutableArray(capacity: 0)

    var searchActive : Bool = false

    let taoTypes = TAOverlayOptions( [.OverlaySizeFullScreen, .OpaqueBackground, .OverlayTypeActivitySquare])
    //private var observerlocal: NSObjectProtocol!

    var logoImageView   : UIImageView!
    var allDataSource = NSMutableArray(capacity: 0)
    var data = NSDictionary()
    //var myPlayer = VideoPlayerManage.instance()
    var whatToShow = Int()
    var groupOffset = Int()
    var currentGroupId = NSInteger()
    override func viewDidLoad() {
        super.viewDidLoad()
        // loadSearch()
       // let musicNib = UINib(nibName: "MyMusicTableCell", bundle: nil)
      //  self.myTableView.registerNib(musicNib, forCellReuseIdentifier: "musicCell")
        
        let musicNib = UINib(nibName: "MyMusicTableCell", bundle: nil)
        self.myTableView.registerNib(musicNib, forCellReuseIdentifier: "musicCell")
        let friendNib = UINib(nibName: "MyFriendCell", bundle: nil)
        self.myTableView.registerNib(friendNib, forCellReuseIdentifier: "friendCell")

        let groupNib = UINib(nibName: "MyGroupCell", bundle: nil)
        self.myTableView.registerNib(groupNib, forCellReuseIdentifier: "groupCell")
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableCellOnChangeCell:", name:"songChanged", object: nil)
        self.sideMenuController()?.sideMenu?.delegate = self
        /*let mainQueue = NSOperationQueue.mainQueue()
        observerlocal = NSNotificationCenter.defaultCenter().addObserverForName("songChanged", object: nil, queue: mainQueue) { (notification) -> Void in
            self.updateTableCellOnChangeCell(notification)
        }*/
        //loadMyMusic()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification,
            object: nil)
   
    }
  
    
    func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = self.myTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            frame.size.height -= keyboardSize.height
            self.myTableView.frame = frame
           
            UIView.commitAnimations()
        }
    }
    
    func keyboardWillHide(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            var frame = self.myTableView.frame
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            frame.size.height += keyboardSize.height
            self.myTableView.frame = frame
            UIView.commitAnimations()
        }
    }
    override func viewDidLayoutSubviews() {
        if let  rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.myTableView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    func loadDataGroups(){
       
        whatToShow=2
        TAOverlay .showOverlayWithLabel("Loading...", options: taoTypes)
        
        let friendInfo = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! NSInteger
        
        let audioReq: VKRequest = VKRequest(method: "groups.get", andParameters: [VK_API_OWNER_ID : String(friendInfo),"extended":"1"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                 print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                let count = audios.objectForKey("count") as! NSInteger
                if (count > 0 ){
                    self.allDataSource=audios.objectForKey("items") as! NSMutableArray
                 
                }
              
                TAOverlay.hideOverlay()
                
                self.myTableView.reloadData()
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
                
        })
        
        
    }
    
    
    func loadDataFriendUsers(){
      
        whatToShow=1
        TAOverlay .showOverlayWithLabel("Loading...", options: taoTypes)

        let friendInfo = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! NSInteger

        let audioReq: VKRequest = VKRequest(method: "friends.get", andParameters: [VK_API_OWNER_ID : String(friendInfo),"order":"name","fields":"nickname"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                self.allDataSource=audios.objectForKey("items") as! NSMutableArray
                TAOverlay.hideOverlay()

                self.myTableView.reloadData()
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()

                
        })
        
        
    }
    
    func loadMoreMusicForGroupWithOffset(offset:NSInteger){
        whatToShow=0
         print("offset \(self.groupOffset)")

        let mylocalArray : NSMutableArray = NSMutableArray()
        TAOverlay.showOverlayWithLabel("Loading...", options:taoTypes)
        
        let audioReq: VKRequest = VKRequest(method: "wall.get", andParameters: [VK_API_OWNER_ID : "-"+String(self.currentGroupId),"extended":"0","count":"5","offset":String(offset)], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                
                let items = audios.objectForKey("items") as! NSMutableArray
                
                for var t = 0 ; t < items.count; t++
                {
                    self.groupOffset++

                    var dict  = NSDictionary()
                    dict =  items.objectAtIndex(t) as! NSDictionary
                    if let attachements = dict.objectForKey("attachments") as? NSMutableArray{
                        
                        for var d = 0; d < attachements.count; d++
                        {
                            var dictattach  = NSDictionary()
                            dictattach =  attachements.objectAtIndex(d) as! NSDictionary
                            let type = dictattach.objectForKey("type") as! String
                            
                            // print("dictattach : \(type)")
                            
                            if (type=="audio"){
                                
                                let audio = dictattach.objectForKey("audio") as! NSDictionary
                               // print("have audio : \(audio)")
                                mylocalArray.addObject(audio)
                                
                            }
                            if (type=="photo"){
                                
                                _ = dictattach.objectForKey("photo") as! NSDictionary
                                //print("have photo : \(photo)")
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
                
                /* let attachements : NSMutableArray = items.objectAtIndex(0) as! NSMutableArray
                
                for var i = 0; i < attachements.count; i++
                {
                var item = NSDictionary()
                item = attachements.objectAtIndex(i) as! NSDictionary
                print("attachement : \(item)")
                }
                
                
                self.allDataSource=audios.objectForKey("items") as! NSMutableArray*/
                
                
                
                
                
                TAOverlay.hideOverlay()
                if(mylocalArray.count>0){
                    self.allDataSource.addObjectsFromArray(mylocalArray as [AnyObject])
                    

                    print("loadMoreMusicForGroupWithOffset: \(self.groupOffset)")
                    
                    self.myTableView.reloadData()
                    //self.myPlayer = nil
                   // //self.myPlayer = VideoPlayerManage.instance()
                    //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(self.currentGroupId)")
                    
                }
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
        })
        
        
        
    }
    
    func loadMusicForGroup(dict:NSInteger){
        whatToShow=0
        
        self.groupOffset=0
        let mylocalArray : NSMutableArray = NSMutableArray()
        TAOverlay.showOverlayWithLabel("Loading...", options: taoTypes)
        
        let audioReq: VKRequest = VKRequest(method: "wall.get", andParameters: [VK_API_OWNER_ID : "-"+String(dict),"extended":"0","count":"10","offset":"0"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                
                let items = audios.objectForKey("items") as! NSMutableArray
                for var t = 0 ; t < items.count; t++
                {
                    self.groupOffset++

                    var dict  = NSDictionary()
                    dict =  items.objectAtIndex(t) as! NSDictionary
                    if let attachements = dict.objectForKey("attachments") as? NSMutableArray{
                        

                        for var d = 0; d < attachements.count; d++
                        {
                            var dictattach  = NSDictionary()
                            dictattach =  attachements.objectAtIndex(d) as! NSDictionary
                            let type = dictattach.objectForKey("type") as! String

                           // print("dictattach : \(type)")

                            if (type=="audio"){
                               
                                let audio = dictattach.objectForKey("audio") as! NSDictionary
                              //  print("have audio : \(audio)")
                                mylocalArray.addObject(audio)

                            }
                            if (type=="photo"){
                                
                              //  var photo = dictattach.objectForKey("photo") as! NSDictionary
                                //print("have photo : \(photo)")
                                
                            }
                            

                            
                        }


                    }

                    
                }
                
                
                
               /* let attachements : NSMutableArray = items.objectAtIndex(0) as! NSMutableArray

                for var i = 0; i < attachements.count; i++
                {
                    var item = NSDictionary()
                    item = attachements.objectAtIndex(i) as! NSDictionary
                    print("attachement : \(item)")
                }
               
                
                self.allDataSource=audios.objectForKey("items") as! NSMutableArray*/
                
                
                
                

                
                TAOverlay.hideOverlay()
                if(mylocalArray.count>0){
                    self.allDataSource=mylocalArray

                    print("loadMusicForGroup: \(self.groupOffset)")

                self.myTableView.reloadData()
                //self.myPlayer = nil
               // //self.myPlayer = VideoPlayerManage.instance()
                //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(dict)")

                }
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
        })
        
        
        
    }
    func loadPopularMusic(){
        
        
        whatToShow=0
        TAOverlay .showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
        
        let audioReq: VKRequest = VKRequest(method: "audio.getPopular", andParameters: nil, andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
               // let audios =  response.json as! NSDictionary
                self.allDataSource=response.json as! NSMutableArray
                TAOverlay.hideOverlay()
                
                self.myTableView.reloadData()
                //self.myPlayer = nil
                // //self.myPlayer = VideoPlayerManage.instance()
                //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
        })
        
        
        
    }
    func loadMusicForFriend(dict:NSInteger){
      

        whatToShow=0
        TAOverlay .showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])

        let audioReq: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : String(dict)], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                self.allDataSource=audios.objectForKey("items") as! NSMutableArray
                TAOverlay.hideOverlay()

                self.myTableView.reloadData()
                //self.myPlayer = nil
               // //self.myPlayer = VideoPlayerManage.instance()
                //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])

            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()

        })
        
        
        
    }
    func loadMyMusic(){
      
        whatToShow=0
        TAOverlay .showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])

        let friendInfo = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! NSInteger
        
        
        let audioReq: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : String(friendInfo),"need_user":"0"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                self.allDataSource=audios.objectForKey("items") as! NSMutableArray
                TAOverlay.hideOverlay()
                self.myTableView.reloadData()
                //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()

                
        })
        
        
        
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
            if (whatToShow == 0){
                filterContentForSearchText(searchText)

            } else if( whatToShow == 2){
                print("search group")
              
                filterGroupForText(searchText)
                
            }
            
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //self.filterContentForSearchText(searchBar.text)
        print("searchBarSearchButtonClicked")
        
        //searchBar.resignFirstResponder()
        // Do the search...
       /* searchActive = false;
        hideSearchBar()
        */
       
        
        
    }
    
    
    func filterGroupForText (searchText:String){
        

        let audioReq: VKRequest = VKRequest(method: "groups.search", andParameters: ["q" : searchText,"type":"group", "count":"50"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                print("got the \(response.json)")
          
                let audios =  response.json as! NSDictionary
                //self.allDataSource=audios.objectForKey("items") as! NSMutableArray
                
                let listItemToBeDisplayed = audios.objectForKey("items") as! NSMutableArray
                print("filtered: \(listItemToBeDisplayed)")
                if(listItemToBeDisplayed.count == 0){
                    self.searchActive = false;
                } else {
                    self.filteredData = NSMutableArray(array: listItemToBeDisplayed)
                    self.searchActive = true;
                }
                self.myTableView.reloadData()
                TAOverlay.hideOverlay()
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()


        })
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
            if (whatToShow == 0){
                self.filterContentForSearchText(newString)
                
            } else if( whatToShow == 2) {
                print("search group")
             
                filterGroupForText(newString)

                
            }
            
        }
        return true
    }

    
    //MARK DATASOURCE TABLE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredData.count
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
        
        if(self.whatToShow==0){
            
      
        if let cell = tableView.dequeueReusableCellWithIdentifier("musicCell", forIndexPath: indexPath) as? MyMusicTableCell
        {
            // Configure the cell for this indexPath
            
            
            var song = NSDictionary();
            if(searchActive && self.filteredData.count>0){
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
        }else if(self.whatToShow==1){
            if let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as? MyFriendCell
            {
                // Configure the cell for this indexPath
                var friend = NSDictionary();
                friend = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
                
                cell.configure(friend)
                // Make sure the constraints have been added to this cell, since it may have just been created from scratch
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                
                
                return cell
            }

        }else if(self.whatToShow==2){
            if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as? MyGroupCell
            {
                // Configure the cell for this indexPath
                var friend = NSDictionary();
                if(searchActive && self.filteredData.count>0){
                    friend = self.filteredData.objectAtIndex(indexPath.row) as! NSDictionary
                } else {
                    friend = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
                }
                cell.configure(friend)
                // Make sure the constraints have been added to this cell, since it may have just been created from scratch
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                
                
                return cell
            }
            
        }
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(self.currentGroupId>0){
            if (indexPath.row == self.allDataSource.count - 1)
            {
                print("add more items")
                self.loadMoreMusicForGroupWithOffset(self.groupOffset)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: false)

        self.currentGroupId=0
      
        
    
        
        let cell = self.myTableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
        if(cell != nil){
            
            
            showBar("", subtitle: "")

            
            //self.myPlayer.playWithIndex(indexPath.row)
            return
        }
        
        
         let mycell = tableView.cellForRowAtIndexPath(indexPath) as? MyFriendCell
            if(mycell != nil){
                
            var data = NSDictionary();
            data = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
            let user = data.objectForKey("id") as! NSInteger
            print("show music for this friend: \(String(user))")
            loadMusicForFriend(user)

            return
        }
        
        if let mycell = tableView.cellForRowAtIndexPath(indexPath) as? MyGroupCell{
            if (searchActive){
                var dataac = NSDictionary();
                dataac = self.filteredData.objectAtIndex(indexPath.row) as! NSDictionary
                let userac = dataac.objectForKey("id") as! NSInteger
                print("show music for this group: \(String(userac))")
                /*loadMusicForGroup(user)
                self.currentGroupId=user
                */
                
                performSegueWithIdentifier("showGroupMusic", sender: mycell)
                return
            }
            
            
            
            var data = NSDictionary();

            data = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
            let user = data.objectForKey("id") as! NSInteger
            print("show music for this group: \(String(user))")
            /*loadMusicForGroup(user)
            self.currentGroupId=user
            */
          
            performSegueWithIdentifier("showGroupMusic", sender: mycell)
            return
        }
        
    }
    
    func showBar(title:String,subtitle:String){
        
        if (self.navigationController!.popupContentViewController != nil){
            print("already here")
            self.navigationController!.popupItem.title=title
            self.navigationController!.popupItem.subtitle=subtitle
            return
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("NavTestPlayerViewController") as! UINavigationController
        
        let demoVC   = navContrl.viewControllers.first as! TestPlayerViewController
        /*demoVC.popupItem.title=title
        demoVC.popupItem.subtitle=subtitle
        demoVC.popupItem.progress=0
        */
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
                self.myTableView.reloadData()
                
            })
            
        }
        Download.backgroundColor = UIColor.lightGrayColor()
        
        let Add = UITableViewRowAction(style: .Normal, title: "Add") { action, index in
            print("Add button  tapped row \(index)")
        }
        Add.backgroundColor = UIColor.orangeColor()
        
        let share = UITableViewRowAction(style: .Normal, title: "Remove") { action, index in
            print("Remove button  tapped row \(index)")
            var data = NSDictionary();
            
            data = self.allDataSource.objectAtIndex(index.row) as! NSDictionary
            
            let user = data.objectForKey("id") as! NSInteger
            let audioReq: VKRequest = VKRequest(method: "groups.leave", andParameters: ["group_id" : user], andHttpMethod: "POST")
            audioReq.executeWithResultBlock(
                {
                    (response) -> Void in
                    print("got the \(response.json)")
                    
                    
                }, errorBlock: {
                    (error) -> Void in
                    NSLog("VK error: %@", error)
                    
                    
            })

        }
        share.backgroundColor = UIColor.blueColor()
        
        let Addgroup = UITableViewRowAction(style: .Normal, title: "Add") { action, index in
            print("Addgroup button  tapped row \(index)")
            var data = NSDictionary();
            
                data = self.filteredData.objectAtIndex(index.row) as! NSDictionary
   
            let user = data.objectForKey("id") as! NSInteger
            let audioReq: VKRequest = VKRequest(method: "groups.join", andParameters: ["group_id" : user], andHttpMethod: "POST")
            audioReq.executeWithResultBlock(
                {
                    (response) -> Void in
                    print("got the \(response.json)")
                    
                    
                    self.loadDataGroups()
                }, errorBlock: {
                    (error) -> Void in
                    NSLog("VK error: %@", error)
                    
                    
            })
            
        }
        Addgroup.backgroundColor = UIColor.orangeColor()
        
        if(searchActive && whatToShow==2){
            
            return  [Addgroup]

        }
        return [share, Add, Download]
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    func updateTableCellOnChangeCell(notification: NSNotification){
        //Take Action on Notification
        // print("updateTableCellOnChangeCell index: \(notification.userInfo)")
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let index : NSInteger = tmp["index"] as! NSInteger
        let indexPath=NSIndexPath(forRow: index, inSection: 0)
        
        let frame=self.myTableView.rectForRowAtIndexPath(indexPath) as CGRect
        
    
        
          let cell = self.myTableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
        if(cell != nil){
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
    //MARK menu
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
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    //MARK status bar
    /*override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? MyGroupCell {
            let i = self.myTableView.indexPathForCell(cell)!.row
            if segue.identifier == "showGroupMusic" {
                
                var data = NSDictionary();
                data = self.allDataSource.objectAtIndex(i) as! NSDictionary
                
                
                if (searchActive){
                    data = self.filteredData.objectAtIndex(i) as! NSDictionary
                  
                }
                
                
                let user = data.objectForKey("id") as! NSInteger
                
                let vc = segue.destinationViewController as! GroupTableController
                
                //let vc = navVC.viewControllers.first as! GroupTableController
                vc.currentGroupId=user
                vc.playFromWall=false
                //vc .loadMusicForGroup(user)
            }
        }

    }
  /*  override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableCellOnChangeCell:", name:"songChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "songChanged", object: nil)
        
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "songChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(observerlocal)
        print("deinit")
        
    }*/

}