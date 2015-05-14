//
//  ChecklistItem.swift
//  Giselle
//
//  Created by Giselle Mobi on 4/9/15.
//  Copyright (c) 2015 Giselle Mobi. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, NSCoding {
    var text = ""
    var checked = false
    var dueDate = NSDate()
    var shouldRemind = false
    var itemID: Int
    var latitude = ""
    var longitude = ""
    var address = ""
    
    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey("Text") as! String
        checked = aDecoder.decodeBoolForKey("Checked")
        dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        latitude = aDecoder.decodeObjectForKey("Latitude") as! String
        longitude = aDecoder.decodeObjectForKey("Longitude") as! String
        //address = aDecoder.decodeObjectForKey("Address") as! String
        super.init()
    }
    
    override init() {
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    func toggleChecked () {
    checked = !checked
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: "Text")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeObject(dueDate, forKey: "DueDate")
        aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInteger(itemID, forKey: "ItemID")
        aCoder.encodeObject(latitude, forKey: "Latitude")
        aCoder.encodeObject(longitude, forKey: "Longitude")
        //aCoder.encodeObject(address, forKey: "Address")
    }
    
    func scheduleNotification() {
        if shouldRemind && dueDate.compare(NSDate()) != NSComparisonResult.OrderedAscending {
            //add code here
        }
    }

}