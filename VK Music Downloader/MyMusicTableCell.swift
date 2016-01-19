//
//  MyMusicTableCell.swift
//  Music Player
//
//  Created by iOS on 11/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
import ReactiveCocoa
//let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
let documentsUrl : NSURL =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!

class MyMusicTableCell: UITableViewCell {

    var urlToDownload : NSURL!
    var filename : String!
    var parallel : Bool = false
    var data : NSDictionary!
    var downloading: Bool?

    @IBOutlet var downloadProgress: UIProgressView!
    @IBOutlet weak var headingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
   	    

}

