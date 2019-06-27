//
//  OperationManager.swift
//  GCDAsyncImage
//
//  Created by Medi Assumani on 6/18/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import Foundation
import UIKit

/// This class tracks and manages downloading and filtering operations that are pending or executing
class PendingOperations {
    
    lazy var donwloadsInProgress: [IndexPath: Operation] = [:] // container of photos that are downloading
    lazy var filterationsInProgress: [IndexPath: Operation] = [:] // container of photos that are being filtered
    
    // Operation queue to manage all download-related operations
    lazy var downloadQueue: OperationQueue = {
        
        var queue = OperationQueue()
        queue.qualityOfService = QualityOfService.userInteractive
        queue.maxConcurrentOperationCount = 5
        queue.name = "Download Queue"
    
        return queue
    }()
    
    // Operation queue to manage all filter-related operations
    lazy var filterationQueue: OperationQueue = {
        
        let queue = OperationQueue()
        queue.name = "Filter Queue"
        return queue
    }()
}

class PhotoDownloadOperation: Operation {
    
    var photo: Photo
    
    init(_ photo: Photo) {
        self.photo = photo
    }
    
    override func main() {
        
        // Check if the task is already cancelled
        if isCancelled {
            return
        }
        
        // Grab the image data from the URL
        guard let imageData = try? Data(contentsOf: photo.url) else { return }
        
        if isCancelled {
            return
        }
        
        if (imageData.isEmpty == false) {
            photo.image = UIImage(data: imageData)
            photo.state = .ready
        } else {
            photo.state = .failed
            photo.image = UIImage(named: "error")
        }
    }
}

class PhotoFilterOperation: Operation {
    
    var photo: Photo
    
    init(_ photo: Photo) {
        self.photo = photo
    }
    
    override func main() {
        
        if isCancelled{
            return
        }
        
        guard self.photo.state == .ready else { return }
        
        if let image = self.photo.image {
            let filteredImage = applyFilter(on: image)
            photo.image = filteredImage
            photo.state = .filtered
        }
    }
    
    func applyFilter(on image: UIImage) -> UIImage {
        
        let inputImage = CIImage(data: image.pngData()!)
        let filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: kCIInputIntensityKey)
        let outputCIImage = filter.outputImage
        let imageWithFilter = UIImage(ciImage: outputCIImage!)
        
        return imageWithFilter
    }
}

