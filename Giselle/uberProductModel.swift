//
//  uberProductModel.swift
//  Giselle
//
//  Created by Giselle Mobi on 5/12/15.
//  Copyright (c) 2015 Giselle Mobi. All rights reserved.
//

import Foundation

class UberProductModel: NSObject, Printable {
    let uberProductType: String
    let uberProductDescription: String
    
    override var description: String {
        return "Product: \(uberProductType), Description: \(uberProductDescription)\n"
    }
    
    init(uberProductType: String?, uberProductDescription: String?) {
        self.uberProductType = uberProductType ?? ""
        self.uberProductDescription = uberProductDescription ?? ""
    }
}