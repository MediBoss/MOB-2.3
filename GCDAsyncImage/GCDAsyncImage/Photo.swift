//
//  Photo.swift
//  GCDAsyncImage
//
//  Created by Medi Assumani on 6/18/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit


enum PhotoStatus {
    
    case new
    case ready
    case filtered
    case failed
}

class Photo {
    
    let url: URL
    var state: PhotoStatus = .new
    var image = UIImage(named: "placeholder")
    
    init(url: URL) {
        self.url = url
    }
}
