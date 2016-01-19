//
//  GroupTableController.swift
//  Music Player
//
//  Created by iOS on 15/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
import UIKit

enum DownloadsCellAction: String {
    case Download = "Download"
    case Pause = "Pause"
    case Resume = "Resume"
    case Remove = "Remove"
    case None = "..."
}
class GroupTableController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, IGLDropDownMenuDelegate, DownloadManagerDelegate {

    @IBOutlet weak var myTableView: UITableView!
    var currentAudioIndex:Int!
    var searchBar = UISearchBar()
    var playFromWall = Bool()
    var currentGroupId : NSInteger!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    var loadMore = Bool()
    var dropDownMenu = IGLDropDownMenu()
    var errorTextEmptyTable : String!
   // private var observerlocal: NSObjectProtocol!
    var editMode = Bool()
    var downloadActive : Bool = false
    var downloadManager = DownloadManager()
    @IBAction func searchButtonClicked(sender: AnyObject) {
        /* loadSearch()
        showSearchBar()*/
        if (searchBarButtonItem.title=="Menu"){
            UIView.animateWithDuration(0.45, animations: {
                
                self.setupInit()
                self.view.addSubview(self.dropDownMenu)
                self.dropDownMenu.toggleView()
                
                }, completion: {
                    (value: Bool) in
                    
                    
                    
            })
        }else{
            self.editMode=false
            self.myTableView.backgroundColor=UIColor.whiteColor()
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "favskey")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.myTableView.reloadData()
            self.hideDownloadButton()
            searchBarButtonItem.title="Menu"
        }
        
    }
    var logoImageView   : UIImageView!
    var allDataSource = NSMutableArray(capacity: 0)
    var data = NSDictionary()
    //var myPlayer = VideoPlayerManage.instance()
    var whatToShow = Int()
    var groupOffset = Int()
    
    var dataImage:NSArray = ["sun.png",
        "clouds.png",
        "snow.png",
        "rain.png",
        "windy.png"]
    var dataTitle:NSArray = ["Search",
        "From wall",
        "Library",
        "Download",
        "Windy"]
    
    override func viewDidAppear(animated: Bool) {
        
      
        super.viewDidAppear(animated)
        
        
    }
    func setupInit() {
        
        let dropdownItems:NSMutableArray = NSMutableArray()
        
        for i in 0...(dataTitle.count-1) {
            
            let item = IGLDropDownItem()
            item.iconImage = UIImage(named: "\(dataImage[i])")
            item.text = "\(dataTitle[i])"
            item.tag=i
            dropdownItems.addObject(item)
        }
        dropDownMenu.menuText="Action: "
        dropDownMenu.dropDownItems = dropdownItems as [AnyObject]
        dropDownMenu.paddingLeft = 15
        dropDownMenu.frame = CGRectMake((self.view.frame.size.width/2) - 100, 150, 200, 45)
        dropDownMenu.delegate = self
        dropDownMenu.type = IGLDropDownMenuType.SlidingInFromRight
        dropDownMenu.gutterY = 5
        dropDownMenu.itemAnimationDelay = 0.1
        //dropDownMenu.rotate = IGLDropDownMenuRotate.Random //add rotate value for tilting the
        dropDownMenu.reloadView()
        
        /*var myLabel = UILabel()
        myLabel.text = "SwiftyOS Blog"
        myLabel.textColor = UIColor.whiteColor()
        myLabel.font = UIFont(name: "Helvetica-Neue", size: 17.0)
        myLabel.textAlignment = NSTextAlignment.Center
        myLabel.frame = CGRectMake((self.view.frame.size.width/2) - 100, 75, 200, 25)
        */
       // self.view.addSubview(myLabel)
        
    }
    
    func dropDownMenu(dropDownMenu: IGLDropDownMenu!, selectedItemAtIndex index: Int) {
        
        let item:IGLDropDownItem = dropDownMenu.dropDownItems[index] as! IGLDropDownItem
        print("Selected weather \(item.text)")
        
        
        UIView.animateWithDuration(0.65, animations: {
            dropDownMenu.toggleView()
            dropDownMenu.resetParams()
            
            dropDownMenu.removeFromSuperview()
            }, completion: {
                (value: Bool) in
                
                
                if(index==0){
                    self.loadSearch()
                    self.showSearchBar()
                }else if (index==2){
                    self.loadMusicForGroupFromLibrary(self.currentGroupId)
                }else if (index==1){
                    self.loadMusicForGroup(self.currentGroupId)
                }else if (index==3){
                    
                    if(self.allDataSource.count==0){
                        return
                    }
                    self.editMode = !self.editMode
                    if(self.editMode){
                        self.myTableView.backgroundColor=UIColor.cyanColor()
                    }else{
                        self.myTableView.backgroundColor=UIColor.whiteColor()
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "favskey")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.myTableView.reloadData()
                        self.hideDownloadButton()
                    }
                }
                
                
        })
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.editMode=false
        
        if(self.navigationController!.respondsToSelector(Selector("interactivePopGestureRecognizer"))){
            self.navigationController!.view.removeGestureRecognizer(self.navigationController!.interactivePopGestureRecognizer!)
        }
        
      
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "favskey")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "download")

        NSUserDefaults.standardUserDefaults().synchronize()
            // Or do it manually and return nil.
            //let fileManager = NSFileManager.defaultManager()

            //let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL

       
        let musicNib = UINib(nibName: "MyMusicTableCell", bundle: nil)
        self.myTableView.registerNib(musicNib, forCellReuseIdentifier: "musicCell")
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableCellOnChangeCell:", name:"songChanged", object: nil)
        
      /*  let mainQueue = NSOperationQueue.mainQueue()
        observerlocal = NSNotificationCenter.defaultCenter().addObserverForName("songChanged", object: nil, queue: mainQueue) { (notification) -> Void in
        self.updateTableCellOnChangeCell(notification)
        }*/

        
        
       
        
        if(playFromWall){
            loadMusicForGroup(currentGroupId)

        }else if (!playFromWall){
            loadMusicForGroupFromLibrary(currentGroupId)
        }
     
       
    }
    override func viewDidLayoutSubviews() {
        if let  rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.myTableView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    func loadMoreMusicForGroupWithOffset(offset:NSInteger){
        whatToShow=0
        print("offset \(self.groupOffset)")
        
        let mylocalArray : NSMutableArray = NSMutableArray()
        TAOverlay.showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
        
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
                                
                                //let photo = dictattach.objectForKey("photo") as! NSDictionary
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
                  //  print("local: \(mylocalArray)")

                    self.allDataSource.addObjectsFromArray(mylocalArray as [AnyObject])
                    
                    print("loadMoreMusicForGroupWithOffset: \(self.groupOffset)")
                    
                    self.myTableView.reloadData()
                   
                    
                    
                    for var int = 0; int < mylocalArray.count; int++
                    {
                        var id = NSDictionary()
                        id = mylocalArray.objectAtIndex(int) as! NSDictionary
                        ////self.myPlayer.setUpdatePlayerDataSourceWithURLArray(id)
                        
                    }
                    
                    self.loadMore = true

                   // //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(self.currentGroupId)")
                    self.loadMore = false

                }
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
        })
        
        
        
    }
    
    func loadMusicForGroup(dict:NSInteger){
        whatToShow=0
        self.currentGroupId=dict
        loadMore = true

        self.groupOffset=0
        let mylocalArray : NSMutableArray = NSMutableArray()
        TAOverlay.showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
        
        let audioReq: VKRequest = VKRequest(method: "wall.get", andParameters: [VK_API_OWNER_ID : "-"+String(dict),"extended":"0","count":"10","offset":"0"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                
                let items = audios.objectForKey("items") as! NSArray
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
                                
                                //var photo = dictattach.objectForKey("photo") as! NSDictionary
                                //print("have photo : \(photo)")
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                }

                
                
                
                TAOverlay.hideOverlay()
                if(mylocalArray.count>0){
                    self.allDataSource=mylocalArray
                    self.playFromWall=true
                    print("loadMusicForGroup: \(self.groupOffset)")
                    
                    self.myTableView.reloadData()
                    ////self.myPlayer = nil
                    ////self.myPlayer = VideoPlayerManage.instance()
                    ////self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(dict)")
                    self.playFromWall=false
                    self.errorTextEmptyTable = String("Please try to check audio files from group library.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'Library'.")
                    //Please try to check audio files from group wall.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'From wall'.
                    //Please try to check audio files from group library.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'Library'.
                    self.allDataSource .removeAllObjects()
                    self.myTableView.reloadData()

                }
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
                
        })
        
        
        
    }
    
    func loadMoreMusicForGroupLibraryWithOffset(offset:NSInteger){
        whatToShow=0
        print("offset \(self.groupOffset)")
        let mylocalArray : NSMutableArray = NSMutableArray()

        TAOverlay.showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
        
        let audioReq: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : "-"+String(self.currentGroupId),"count":"50","offset":String(offset)], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                
                let items = audios.objectForKey("items") as! NSArray
                //print("got the \(response.json)")

                for var t = 0 ; t < items.count; t++
                {
                    self.groupOffset++
                    
                    var dict  = NSDictionary()
                    dict =  items.objectAtIndex(t) as! NSDictionary
                    mylocalArray.addObject(dict)
                    
                }
                //print("got the \(mylocalArray)")

                
                TAOverlay.hideOverlay()
                if(mylocalArray.count>0){
                    
                    self.allDataSource.addObjectsFromArray(mylocalArray as [AnyObject])
                    //self.allDataSource.addObjectsFromArray(mylocalArray)
                    
                    print("loadMoreMusicForGroupWithOffset: \(self.groupOffset)")
                    
                    self.myTableView.reloadData()
                   
                    
                    for var int = 0; int < mylocalArray.count; int++
                    {
                        var id = NSDictionary()
                        id = mylocalArray.objectAtIndex(int) as! NSDictionary
                        ////self.myPlayer.setUpdatePlayerDataSourceWithURLArray(id)

                    }
                    
                    self.playFromWall=false
                    self.loadMore=true
                    // //self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(self.currentGroupId)")
                    self.playFromWall=true
                    self.loadMore = false
                
                    
                }
                
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                TAOverlay.hideOverlay()
                
        })
        
        
        
    }
    
    func loadMusicForGroupFromLibrary(dict:NSInteger){
        whatToShow=0
        self.currentGroupId=dict
        let mylocalArray : NSMutableArray = NSMutableArray()
        loadMore = true

        self.groupOffset=0
        TAOverlay.showOverlayWithLabel("Loading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
        
        let audioReq: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : "-"+String(dict),"count":"40","offset":"0"], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("got the \(response.json)")
                let audios =  response.json as! NSDictionary
                
                
                let items = audios.objectForKey("items") as! NSArray
                for var t = 0 ; t < items.count; t++
                {
                    self.groupOffset++
                    var dict  = NSDictionary()
                    dict =  items.objectAtIndex(t) as! NSDictionary
                    mylocalArray.addObject(dict)
                    
                }
                
                
                
                
                TAOverlay.hideOverlay()
                if(items.count>0){
                    self.allDataSource=mylocalArray
                    self.playFromWall=false
                    print("loadMusicForGroup: \(self.groupOffset)")
                    
                    self.myTableView.reloadData()
                    ////self.myPlayer = nil
                    ////self.myPlayer = VideoPlayerManage.instance()
                    ////self.myPlayer.setPlayerDataSourceWithURLArray(self.allDataSource as NSMutableArray as [AnyObject])
                }else{
                    print("local: no audio data for this group: \(dict)")
                    self.playFromWall=true
                    self.errorTextEmptyTable = String("Please try to check audio files from group wall.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'From wall'.")
                    //Please try to check audio files from group wall.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'From wall'.
                    //Please try to check audio files from group library.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'Library'.
                    self.allDataSource .removeAllObjects()
                    self.myTableView.reloadData()
                    
                }
                
            }, errorBlock: {
                (error) -> Void in
                
                let myer : NSError = error
                
                
              //  NSLog("VK library: %@", myer.vkError.apiError.errorCode)
                print("lVK library: \(myer.vkError)")
                if(myer.vkError.errorCode==15){
                    NSLog("error code 15")
                    print("lVK library: \(myer.vkError)")
                    self.errorTextEmptyTable=myer.vkError.errorMessage + "\n Please try to check audio files from group wall.\n1. Click on 'Menu' button.\n2.From drop down menu choose 'From wall'."
                    self.allDataSource .removeAllObjects()
                    self.myTableView.reloadData()
                    
                    
                }
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
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    //MARK DATASOURCE TABLE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.allDataSource.count == 0{
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = errorTextEmptyTable
            emptyLabel.lineBreakMode=NSLineBreakMode.ByWordWrapping
            emptyLabel.numberOfLines=0
            emptyLabel.textAlignment=NSTextAlignment.Center
            
            self.myTableView.backgroundView = emptyLabel
            self.myTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            return self.allDataSource.count
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell : MyMusicTableCell = tableView.dequeueReusableCellWithIdentifier("musicCell", forIndexPath: indexPath) as! MyMusicTableCell
        
                // Configure the cell for this indexPath
                var song = NSDictionary();
                song = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary
                let artist = song.objectForKey("artist") as! String
                let songtitle = song.objectForKey("title") as! String
                
                let artistAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 17.0)! ]
                let titleAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 11.0)! ]
                
                let aAttr = NSMutableAttributedString(string: artist, attributes: artistAttribute )
                let tAttr = NSMutableAttributedString(string:"\n"+songtitle, attributes: titleAttribute )
                aAttr.appendAttributedString(tAttr)
                
                cell.headingLabel.attributedText=aAttr
                let isFav : Bool = self.isFavorite(song)

                
                if isFav {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                  cell.downloadProgress.hidden=false
                 
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                    cell.downloadProgress.hidden=true

                }
        
        
        
        
        //Make sure the constraints have been added to this cell, since it may have just been created from scratch
               
                
                                
                
                return cell
            
       
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            if (indexPath.row == self.allDataSource.count - 1)
            {
                
                if(playFromWall){
                print("add more items from wall")
                    if(loadMore){
                        self.loadMoreMusicForGroupWithOffset(self.groupOffset)

                    }
                }else if(!playFromWall){
                    print("add more items from library")
                    if (loadMore){
                        self.loadMoreMusicForGroupLibraryWithOffset(self.groupOffset)

                    }
                }
            }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: false)
        let mydict = self.allDataSource.objectAtIndex(indexPath.row) as! NSDictionary

        if(editMode){
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
            if cell!.accessoryType == UITableViewCellAccessoryType.None {
                cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
                self.updateFavoriteInUserDefaultsFor(mydict, value: true)
                if(!downloadActive){
                    showDownloadButton()
                }
                
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                self.updateFavoriteInUserDefaultsFor(mydict, value: false)
                if let favs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
                    if(favs.count==0){
                        
                        self.hideDownloadButton()
                        self.searchBarButtonItem.title="Done"
                        self.navigationItem.setHidesBackButton(false, animated: true)
                    }
                    
                }
            }
            
            self.myTableView.deselectRowAtIndexPath(indexPath, animated: false)
            
            
            
            return
        }
        
        let mycell = tableView.cellForRowAtIndexPath(indexPath) as? MyMusicTableCell
            if (mycell != nil){
                showBar("", subtitle: "",dataSource: self.allDataSource, index: indexPath.row)

                
            ////self.myPlayer.playWithIndex(indexPath.row)
            return
        }
        
     
        
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let Downloadbtn = UITableViewRowAction(style: .Normal, title: "Download") { action, index in
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
            
            self.myTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            
            
        }
        Downloadbtn.backgroundColor = UIColor.lightGrayColor()
        
        let Add = UITableViewRowAction(style: .Normal, title: "Add") { action, index in
            print("Add button  tapped row \(index)")
        }
        Add.backgroundColor = UIColor.orangeColor()
        
        let recomended = UITableViewRowAction(style: .Normal, title: "Radio") { action, index in
            print("recomended button  tapped row \(index)")
            var dict = NSDictionary()
            dict = self.allDataSource.objectAtIndex(index.row) as! NSDictionary
            
            //let url = NSURL(string: dict.objectForKey("url") as! String)
            let ownerid = dict.objectForKey("owner_id") as! Int
            let musid = dict.objectForKey("id") as! Int

            print("radio \(dict)")

            
            
            let recnav = self.storyboard?.instantiateViewControllerWithIdentifier("RECOMENDED_CONTROLLER") as! UINavigationController
            
            let recvc = recnav.viewControllers[0] as! RecomendedController
            recvc.trackId = musid
            recvc.currentGroupId = ownerid
            
            self.navigationController?.pushViewController(recvc, animated: true)
            
        }
        recomended.backgroundColor = UIColor.blueColor()
        
        return [recomended, Add, Downloadbtn]
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
     
        
       // showBar(tmp["artist"] as! String, subtitle:  tmp["title"] as! String)
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
    func showBar(title:String,subtitle:String, dataSource:NSMutableArray,index: Int){
        
        if (self.navigationController!.popupContentViewController != nil){
            print("already here \(self.navigationController?.popupContentViewController)")
            let testvc = self.navigationController?.popupContentViewController as! TestPlayerViewController
            testvc.playType = 0
            testvc.addDataSourceToPlayerAndPlayAtIndex(dataSource, index: index)
            self.navigationController!.popupItem.title=title
            self.navigationController!.popupItem.subtitle=subtitle
            return
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        
        let navContrl = mainStoryboard.instantiateViewControllerWithIdentifier("NavTestPlayerViewController") as! UINavigationController
        
        let demoVC   = navContrl.viewControllers.first as! TestPlayerViewController
        demoVC.playType = 0

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

    func updateFavoriteInUserDefaultsFor(index:NSDictionary,value:Bool){
        if  let oldFavs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
            
            var newFavorites : NSMutableArray!
            if (oldFavs.count==0){
                newFavorites = NSMutableArray()
            }else{
                newFavorites = NSMutableArray(array: oldFavs)
            }
            
            
            if (value){
                newFavorites.addObject(index)
            }else{
                newFavorites.removeObject(index)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(newFavorites, forKey: "favskey")
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            let newFavorites : NSMutableArray = NSMutableArray()
            
            
            if (value){
                newFavorites.addObject(index)
            }else{
                newFavorites.removeObject(index)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(newFavorites, forKey: "favskey")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    func updateDownloadInUserDefaultsFor(index:NSDictionary,value:Bool){
        if  let oldFavs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("download") as? NSMutableArray{
            
            var newFavorites : NSMutableArray!
            if (oldFavs.count==0){
                newFavorites = NSMutableArray()
            }else{
                newFavorites = NSMutableArray(array: oldFavs)
            }
            
            
            if (value){
                newFavorites.addObject(index)
            }else{
                newFavorites.removeObject(index)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(newFavorites, forKey: "download")
            NSUserDefaults.standardUserDefaults().synchronize()
        }else{
            let newFavorites : NSMutableArray = NSMutableArray()
            
            
            if (value){
                newFavorites.addObject(index)
            }else{
                newFavorites.removeObject(index)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(newFavorites, forKey: "download")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }

    func isDown(index:NSDictionary)->Bool{
        if let favs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("download") as? NSMutableArray{
            if (favs.count>0){
                return favs.containsObject(index)
            }else{
                return false
            }
            
        }
        return false
    }
    func isFavorite(index:NSDictionary)->Bool{
        if let favs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
            if (favs.count>0){
                return favs.containsObject(index)
            }else{
                return false
            }
            
        }
        return false
    }
    
    func showDownloadButton(){
        
        UIView.animateWithDuration(0.45, animations: {
            let button =  UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(0, 0, 80, 30) as CGRect
            button.setTitleColor(self.view.tintColor, forState: UIControlState.Normal)
            button.setTitle("Download", forState: UIControlState.Normal)
            button.addTarget(self, action: Selector("clickOnButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.navigationItem.titleView = button
            self.downloadActive=true
            
            }, completion: {
                (value: Bool) in
                
                
        })
    }
    func hideDownloadButton(){
        
        UIView.animateWithDuration(0.45, animations: {
            self.navigationItem.titleView = nil
            self.downloadActive=false
            
            }, completion: {
                (value: Bool) in
                
                
        })
    }
    
    func clickOnButton(button: UIButton) {
        print("clicked download")
        button.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        if let favs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
            if (favs.count>0){
                print("download \(favs)")
                self.downloadManager = DownloadManager(delegate: self)
                //TAOverlay.showOverlayWithLabel("Downloading...", options: [TAOverlayOptions.OverlaySizeFullScreen,TAOverlayOptions.OpaqueBackground,TAOverlayOptions.OverlayTypeActivitySquare])
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString

                for var i = 0 ; i < favs.count ; i++ {
                    
                    
                    let dict = favs.objectAtIndex(i) as! NSDictionary
                    let index = self.allDataSource.indexOfObject(dict)
                    
                    let url = NSURL(string: dict.objectForKey("url") as! String)
                    let artist = dict.objectForKey("artist") as! String
                    let sonname = dict.objectForKey("title") as! String
                    let filename = artist+" - "+sonname+".mp3"
                    
                    let destination = documentsPath.stringByAppendingPathComponent(filename)

                    self.downloadManager.addDownloadWithFilename(destination, index: NSIndexPath(forRow: index, inSection: 0), URL: url)
                    let cell = self.myTableView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(index), inSection: 0)) as? MyMusicTableCell
                    if(cell != nil){
                       // self.navigationItem.setHidesBackButton(true, animated: true)

                       // cell?.filename=filename
                       // cell?.urlToDownload=url
                        cell?.downloadProgress.hidden=false
                       // self.myTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: Int(index), inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)

                        
                    }

                    
               /*    HttpDownloader.loadFileAsync(url!,filename: filename,index: Int(index), completion:{(path:String,index: NSInteger, error:NSError!) in
                        print("file downloaded to: \(path)")
                        print("at index: \(index)")
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.updateFavoriteInUserDefaultsFor(dict, value: false)
                            self.myTableView.beginUpdates()
                            self.myTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: Int(index), inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                            self.myTableView.endUpdates()
                            
                            if let favs1 : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
                                if(favs1.count==0){
                                    
                                    self.editMode=false
                                    self.myTableView.backgroundColor=UIColor.whiteColor()
                                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "favskey")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    self.hideDownloadButton()
                                    self.searchBarButtonItem.title="Menu"
                                    TAOverlay.hideOverlay()
                                }
                                
                            }
 
                        })
                        if(error != nil){
                            TAOverlay.hideOverlay()

                        }
                    
                        
                    })*/
                }

            }
        }
    
        
    }
    
    //MARK: update row
    
    func updateProgressViewForIndexPath(index: NSIndexPath,download: Download!){
        let cell = self.myTableView.cellForRowAtIndexPath(download.indexPath) as? MyMusicTableCell
    
        if(cell != nil){
            if(download.expectedContentLength >= 0){
                
                let  downloadProgress = Float(download.progressContentLength) / Float(download.expectedContentLength)
                //print("updateProgressViewForIndexPath \(download.progressContentLength)")
                //print("updateProgressViewForIndexPath \(download.expectedContentLength)")
                //print("indexpath \(download.indexPath) and normal \(index)")

               cell!.downloadProgress.progress = downloadProgress
               
                //cell!.downloadProgress.progress=(Float)(download.progressContentLength / download.expectedContentLength)
                

            }else{
                cell!.downloadProgress.progress = 0

                
                
   

            }
        }
        
    }
    
 

    func downloadManager(downloadManager: DownloadManager!, downloadDidFail download: Download!) {
        print("downloadDidFail \(download.indexPath)")
    }
    func downloadManager(downloadManager: DownloadManager!, downloadDidFinishLoading download: Download!) {
        print("downloadDidFinishLoading \(download.indexPath)")
        let mydict = self.allDataSource.objectAtIndex(download.indexPath.row) as! NSDictionary
        
        self.updateFavoriteInUserDefaultsFor(mydict, value: false)
        if let favs : NSMutableArray = NSUserDefaults.standardUserDefaults().objectForKey("favskey") as? NSMutableArray{
            if(favs.count==0){
                
                self.hideDownloadButton()
                self.searchBarButtonItem.title="Done"
                self.navigationItem.setHidesBackButton(false, animated: true)
            }
            
        }

        let cell = self.myTableView.cellForRowAtIndexPath(download.indexPath) as? MyMusicTableCell
        if(cell != nil){
        if cell!.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell!.accessoryType = UITableViewCellAccessoryType.None

            cell?.downloadProgress.hidden=true

            
        }
    }
        self.myTableView.deselectRowAtIndexPath(download.indexPath, animated: false)

    }
    func downloadManager(downloadManager: DownloadManager!, downloadDidReceiveData download: Download!) {
        
        for var i = 0 ; i < self.downloadManager.downloads.count ; i++ {
            if(download == self.downloadManager.downloads.objectAtIndex(i) as! NSObject){
                self.updateProgressViewForIndexPath(NSIndexPath(forRow: i, inSection: 0), download: download)
                
                break
            }
        }
        
        

    }
}