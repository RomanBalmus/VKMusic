//
//  HttpDownloader.swift
//  Music Player
//
//  Created by iOS on 14/09/15.
//  Copyright (c) 2015 polat. All rights reserved.
//

import Foundation
import Foundation

class HttpDownloader {
    
    class func loadFileSync(url: NSURL, filename: String,completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl : NSURL =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(filename)
        
        
        
        
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                completion(path: destinationUrl.path!, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }
    
    class func loadFileAsync(url: NSURL,filename: String, index: NSInteger, completion:(path:String,index : NSInteger, error:NSError!) -> Void) {
        let documentsUrl : NSURL =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(filename)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!,index: index, error:nil)
        } else {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl, atomically: true) {
                                print("file saved [\(destinationUrl.path!)]")
                                completion(path: destinationUrl.path!,index: index, error:error)
                            } else {
                                print("error saving file \(error)")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                completion(path: destinationUrl.path!,index: index, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error!.localizedDescription)");
                    completion(path: destinationUrl.path!,index: index, error:error)
                }
            })
            task.resume()
        }
    }
}