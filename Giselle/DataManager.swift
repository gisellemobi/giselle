//
//  DataManager.swift
//  Giselle
//
//  Created by Giselle Mobi on 5/12/15.
//  Copyright (c) 2015 Giselle Mobi. All rights reserved.
//

import Foundation

let UberProductURL = "https://api.uber.com/v1/products?latitude=37.775253&longitude=-122.417541&server_token=k1XYGi-SS27R5Higux7lJDgrZwfpNJs-hkQd8kJG"

class DataManager {
    class func getTopUberDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        //1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //2
            let filePath = NSBundle.mainBundle().pathForResource("UberProducts",ofType:"json")
            println("ItemDetailViewControllerDidLoad...Getting uber data from bundle filepath: \(filePath)")
            var readError:NSError?
            if let data = NSData(contentsOfFile:filePath!,
                options: NSDataReadingOptions.DataReadingUncached,
                error:&readError) {
                    success(data: data)
            }
        })
    }
    class func getTopProductFromUberWithSuccess(success: ((uberProductData: NSData!) -> Void)) {
        //1
        println("ItemDetailViewControllerDidLoad...loading products from uber API URL...")
        loadDataFromURL(NSURL(string: UberProductURL)!, completion:{(data, error) -> Void in
            //2
            if let urlData = data {
                //3
                success(uberProductData: urlData)
                println("loaded Products from uber API URL: success: \(urlData)")
            }
        })
    }
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
                println("There seems to be loadDataTask error with uber API URL")
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"bugscout.Giselle", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                    println("There seems to be unexpected http status error with uber API URL")
                } else {
                    completion(data: data, error: nil)
                    println("Uber products from uber API loadDataFromURL completed \(data)")
                }
            }
        })
        
        loadDataTask.resume()
    }
}
