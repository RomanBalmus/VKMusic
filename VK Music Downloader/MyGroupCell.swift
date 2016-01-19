//
//  MyGroupCell.swift
//  Music Player
//
//  Created by iOS on 14/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation

class MyGroupCell : UITableViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    var count:String?
    @IBOutlet weak var countLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakefromnib")
        
    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(friend: NSDictionary) {
        print("configure")
        
        
        let firstname=friend.objectForKey("name") as! String
        var lastname=friend.objectForKey("screen_name") as! String
        let friendName = firstname//+" "+lastname
        let friendInfo = friend.objectForKey("id") as! NSInteger
        
        let artistAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 17.0)! ]
        let titleAttribute = [ NSFontAttributeName: UIFont(name: "Didot", size: 11.0)! ]
        
        let aAttr = NSMutableAttributedString(string: friendName, attributes: artistAttribute )
        let tAttr = NSMutableAttributedString(string:"\nVK_ID: "+String(format: "%02d", friendInfo), attributes: titleAttribute )
        aAttr.appendAttributedString(tAttr)
        
        headingLabel.attributedText=aAttr
     
        
        
    }
    func getCounts(userid:String){
        
        let audioReq: VKRequest = VKRequest(method: "audio.get", andParameters: [VK_API_OWNER_ID : "-"+userid], andHttpMethod: "POST")
        audioReq.executeWithResultBlock(
            {
                (response) -> Void in
                // print("awake \(response.json)")
                let audios =  response.json as! NSDictionary
                //print("audios \(audios)")
                let cnt=audios.objectForKey("count") as! Int
                self.count=String(format: "%02d", cnt)
                print("awake count\(self.count)")
                if((self.count) != nil){
                    // self.countLabel.backgroundColor=UIColor.blackColor()
                    self.countLabel.text=self.count
                    
                }
                
                /*let audios =  response.json as! NSArray
                print(audios, appendNewline: true)
                if let count: AnyObject = audios[0].objectForKey("count") {
                print(count, appendNewline: true)
                }
                */
            }, errorBlock: {
                (error) -> Void in
                NSLog("VK error: %@", error)
                
        })
        
    }
}