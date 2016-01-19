//
//  TestPlayerViewController.swift
//  Music Player
//
//  Created by iOS on 14/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
class TestPlayerViewController: UIViewController, HysteriaPlayerDelegate,HysteriaPlayerDataSource{
   // var myPlayer = VideoPlayerManage.instance()
    var playerDataSource : NSMutableArray = NSMutableArray()
    var currentDuration : Double!
    var itemsCount : Int = 0
    var playType : Int = 0
    var dictionary = NSDictionary()

    @IBAction func addToLibrary(sender: AnyObject) {
        
       
        
        let url = NSURL(string: dictionary.objectForKey("url") as! String)
        let artist = dictionary.objectForKey("artist") as! String
        let sonname = dictionary.objectForKey("title") as! String
        let filename = artist+" - "+sonname+".mp3"
        
        HttpDownloader.loadFileAsync(url!,filename: filename,index: 1, completion:{(path:String,index: NSInteger, error:NSError!) in
            print("file downloaded to: \(path)")
            print("at index: \(index)")
            
        })
    }
    @IBOutlet weak var addToLibrary: UIButton!
    @IBOutlet weak var imageView : UIImageView!
    lazy var hysteriaPlayer = HysteriaPlayer.sharedInstance()
var _timeObserver:AnyObject?
    var tapCloseButtonActionHandler : (Void -> Void)?
    @IBAction func tapCloseButton() {
        self.tapCloseButtonActionHandler?()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func repetTapped(sender: AnyObject) {
    }
    @IBAction func fasvTapped(sender: AnyObject) {
    }
    @IBAction func previousTapped(sender: AnyObject) {
        ////self.myPlayer.playPrevious()
        hysteriaPlayer.playPrevious()
    }
    @IBAction func playTapped(sender: AnyObject) {
       /* if (//self.myPlayer.queuePlayer.rate>0)
        {
           //self.myPlayer.pause()
        }else{
            //self.myPlayer.play()
        }*/
        
        if (hysteriaPlayer.isPlaying())
        {
            hysteriaPlayer.pausePlayerForcibly(true)
            hysteriaPlayer.pause()
            let b = UIBarButtonItem(image: UIImage(named: "play-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
          
        }else{
            hysteriaPlayer.pausePlayerForcibly(false)
            hysteriaPlayer.play()
            let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
    }
    @IBAction func shuffleTapped(sender: AnyObject) {
    }
    @IBAction func listTapped(sender: AnyObject) {
    }
    @IBAction func nextTapped(sender: AnyObject) {
       // //self.myPlayer.playNext()
        hysteriaPlayer.playNext()

    }
    @IBAction func progressSliderChanged(sender: UISlider) {
        //print("progressSliderChanged \(sender.value)")
        let timeinseconds = Float(sender.value)
       // timeinseconds *= 1000
       // print("timeinseconds \(timeinseconds)")
        hysteriaPlayer.seekToTime(Double(timeinseconds))
        //let seekTime = CMTimeMake(Int64(timeinseconds), 1000)
       // print("seektime \(seekTime)")
      // hysteriaPlayer.seekToTime(timeinseconds)
        //hysteriaPlayer.seekToTime(seekTime)
        
    }
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var favsButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var totalLengthLabel: UILabel!
    @IBOutlet weak var currentProgressLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded player")
       /* self.artistNameLabel.text=self.popupItem.title
        self.songNameLabel.text=self.popupItem.subtitle
        //self.myPlayer.delegate=self*/

        let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "pausePlay:")
        self.popupItem.leftBarButtonItems = [b]
        self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
      
       self.artistNameLabel.text=self.popupItem.title
       self.songNameLabel.text=self.popupItem.subtitle
        self.hysteriaPlayer.delegate = self
    }
   /* func vmanager(vmanager: VideoPlayerManage!, updateProgress param: CGFloat, currentTime: CGFloat) {
        //let durationTime : CGFloat = tmp["durationTime"] as! CGFloat
        self.popupItem.progress = Float(param)
        self.progressSlider.value=self.popupItem.progress
       // print("popUpProgress \(param)")
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(currentTime))
        self.currentProgressLabel.text=String(format:"%02d:%02d:%02d", h , m, s)
      
    }
   
    func vmanager(vmanager: VideoPlayerManage!, playOrPause: Bool) {
        if(playOrPause){
            print("play")
            let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "pausePlay:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }else{
            let b = UIBarButtonItem(image: UIImage(named: "play-1"), style: .Plain, target: self, action: "startPlay:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)

            print("pause")

        }
    }
  
    
    func vmanager(vmanager: VideoPlayerManage!, playerItem: AVPlayerItem!, andInfo info: [NSObject : AnyObject]!) {
        let data = info as NSDictionary
        print(data)
        self.popupItem.title = data.objectForKey("artist") as? String
        self.popupItem.subtitle = data.objectForKey("title") as? String
        self.popupItem.progress=0.0
        self.progressSlider.value=0.0
        self.artistNameLabel.text=self.popupItem.title
        self.songNameLabel.text=self.popupItem.subtitle
        if(data.objectForKey("duration") != nil){
            currentDuration = data.objectForKey("duration") as! Double

        }else{
            currentDuration = CMTimeGetSeconds( playerItem.duration)
        }
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(currentDuration))
        self.totalLengthLabel.text=String(format:"%02d:%02d:%02d", h , m, s)
        


    }*/
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func startPlay(sender: UIBarButtonItem) {
        print("play")
       // //self.myPlayer.play()
        if (hysteriaPlayer.isPlaying())
        {
            hysteriaPlayer.pausePlayerForcibly(true)
            hysteriaPlayer.pause()
            let b = UIBarButtonItem(image: UIImage(named: "play-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            
        }else{
            hysteriaPlayer.pausePlayerForcibly(false)
            hysteriaPlayer.play()
            let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
    }
    func pausePlay(sender: UIBarButtonItem) {
        print("pause")
       // //self.myPlayer.pause()
        if (hysteriaPlayer.isPlaying())
        {
            hysteriaPlayer.pausePlayerForcibly(true)
            hysteriaPlayer.pause()
            let b = UIBarButtonItem(image: UIImage(named: "play-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            
        }else{
            hysteriaPlayer.pausePlayerForcibly(false)
            hysteriaPlayer.play()
            let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
    }
   
    func hysteriaPlayerReadyToPlay(identifier: HysteriaPlayerReadyToPlay) {
        switch(identifier) {
        case .CurrentItem:
            hysteriaPlayer.play()
            print("ready to play CurrentItem")
            let dict = hysteriaPlayer.getPlayingItemDurationTime()
            let (h,m,s) = self.secondsToHoursMinutesSeconds(Int(dict))
            self.totalLengthLabel.text=String(format:"%02d:%02d:%02d", h , m, s)
           
            self.progressSlider.maximumValue = dict
            
            break
        case .Player:
            print("ready to play Player")

            hysteriaPlayer.play()
            if (_timeObserver == nil) {
                _timeObserver = hysteriaPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(100, 1000), queue: dispatch_get_main_queue(),
                    usingBlock: { (time: CMTime) -> Void in
                        let totalSeconds: Float64 = CMTimeGetSeconds(time)
                        

                        if (!isnan(totalSeconds) && !isinf(totalSeconds)) {
                           // print("total seconds \(totalSeconds)")
                            let (h,m,s) = self.secondsToHoursMinutesSeconds(Int(totalSeconds))
                            self.currentProgressLabel.text=String(format:"%02d:%02d:%02d", h , m, s)
                            self.progressSlider.setValue(self.hysteriaPlayer.getPlayingItemCurrentTime(), animated: true)
                            
                        }
                })
            }
            
            break
       
        }
    }
    
    func recheckbuttons(){
        if (!hysteriaPlayer.isPlaying())
        {
            let b = UIBarButtonItem(image: UIImage(named: "play-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            
        }else{
            
            let b = UIBarButtonItem(image: UIImage(named: "pause-1"), style: .Plain, target: self, action: "playTapped:")
            self.popupItem.leftBarButtonItems = [b]
            self.playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }
    }
    
    func hysteriaPlayerWillChangedAtIndex(index: Int) {
        dictionary = self.playerDataSource.objectAtIndex(index) as! NSDictionary
        print("hysteriaPlayerWillChangedAtIndex ")
        self.popupItem.title = dictionary.objectForKey("artist") as? String
        self.popupItem.subtitle = dictionary.objectForKey("title") as? String
      
        if((self.artistNameLabel != nil) && (self.songNameLabel != nil)){
            self.artistNameLabel.text=self.popupItem.title
            self.songNameLabel.text=self.popupItem.subtitle
            self.progressSlider.setValue(0.0, animated: true)
        }
       
        let instanceOfCustomObject: VideoPlayerManage = VideoPlayerManage()
        instanceOfCustomObject.setNowPlayingInfoDictionary(dictionary as [NSObject : AnyObject])

    }
    func hysteriaPlayerNumberOfItems() -> Int {
        return self.itemsCount
    }
    /*func hysteriaPlayerURLForItemAtIndex(index: Int, preBuffer: Bool) -> NSURL! {
       
        var url = NSURL()
        
       //let url = NSURL(string: "https://cs6-4v4.vk-cdn.net/p2/ea8b423427e71d.mp3?extra=_QyA_8LcMBz29k3l_Z2O8Xf_vAdaA7JrDJPusJBLyhxLILQWT6zNc3c7xMAPSptNwIE7PU_fxnbYLHbC4RmHGqVKaCJEtlO5")!
        print("hysteriaPlayerURLForItemAtIndex \(url)")

        return url

    }*/
    func hysteriaPlayerURLForItemAtIndex(index: Int, preBuffer: Bool) -> NSURL! {
        var url: NSURL
        switch self.playType {
        case 0:
            url = NSURL(string: self.playerDataSource.objectAtIndex(index).objectForKey("url") as! String)!;
            print("play url")

            break
        case 1:
            url = NSURL(fileURLWithPath: self.playerDataSource.objectAtIndex(index).objectForKey("url") as! String);
            print("play local")

            break
     
        default:
            url = NSURL()
            break
        }
       // print("hysteriaPlayerURLForItemAtIndex \(url)")

        return url;
    }
   /* func hysteriaPlayerAsyncSetUrlForItemAtIndex(index: Int, preBuffer: Bool) {
        // using async source getter, should call this method after you get the source.
        let url : NSURL = NSURL(string: self.playerDataSource.objectAtIndex(index).objectForKey("url") as! String)!
        print("hysteriaPlayerAsyncSetUrlForItemAtIndex \(url)")
        hysteriaPlayer.setupPlayerItemWithUrl(url, index: index)
    }*/
    
    func addDataSourceToPlayerAndPlayAtIndex(dataSource:NSMutableArray,index:Int){
        self.playerDataSource =  dataSource;
        self.itemsCount = self .playerDataSource.count
        //print("addDataSourceToPlayerAndPlayAtIndex \(self.playerDataSource)")
        
        hysteriaPlayer.removeAllItems()
        hysteriaPlayer.delegate = self
        hysteriaPlayer.datasource = self
        hysteriaPlayer.enableMemoryCached(true)
        hysteriaPlayer.setPlayerRepeatMode(HysteriaPlayerRepeatMode.On)
        hysteriaPlayer.fetchAndPlayPlayerItem(index)
        
        
    }
    
    func playerInteruptionListener(type: UnsafeMutablePointer<Int>) {
        self.recheckbuttons()
    }
    
    func playPauseListener(playPause: Bool) {
        print("playPauseListener")
        self.recheckbuttons()
    }
    }