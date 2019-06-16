/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    
    case new
    case downloaded
    case filtered
    case failed
}

/// This class defines a single record of a Photo displayed in the app
class PhotoRecord {
    
    let name: String
    let url: URL
    var state: PhotoRecordState = .new
    var image = UIImage(named: "Placeholder")
    
    init(name: String, url: URL) {
        
        self.name = name
        self.url = url
    }
}

// This class define characteristic of a task that is pending to be executed
class PendingOperations {
    
    lazy var donwloadsInProgress: [IndexPath: Operation] = [:] // container of photos that are downloading
    lazy var filterationsInProgress: [IndexPath: Operation] = [:] // container of photos that are being filtered
    
    // Operation queue to manage all download-related operations
    lazy var downloadQueue: OperationQueue = {
        
        var queue = OperationQueue()
        
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 1 // determines the amount of Operations to run concurently
        
        return queue
    }()
    
    // Operation queue to manage all filter-related operations
    lazy var filterationQueue: OperationQueue = {
       
        let queue = OperationQueue()
        
        queue.name = "Filter Queue"
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
}

// This class Subclasses the Operation class for custom behaviors of downloading an image
class ImageDownloader: Operation {
    
    //1 - Adds reference of the PhotoRecord object related to the operation
    let photoRecord: PhotoRecord
    
    //2 - Designated initializer
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3 - Override the main function of the Operation class
    override func main() {
        //4 - Checks if the operation is already canceled before starting
        if isCancelled {
            return
        }
        
        //5 - Downloads the image data
        guard let imageData = try? Data(contentsOf: photoRecord.url) else { return }
        
        //6 - Check if again if cancelled after downloadind data
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            
            //7 - If there is data, download the image and set the state to downloaded
            photoRecord.image = UIImage(data:imageData)
            photoRecord.state = .downloaded
        } else {
            
            // 8 - If there is no data, set the state to failed and set the image to a failed default thumbnail
            photoRecord.state = .failed
            photoRecord.image = UIImage(named: "Failed")
        }
    }
}

// This class Subclasses the Operation class for custom behaviors of filtering an image
class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if isCancelled {
            return
        }
        
        guard self.photoRecord.state == .downloaded else {
            return
        }
        
        if let image = photoRecord.image,
            let filteredImage = applySepiaFilter(image) {
            photoRecord.image = filteredImage
            photoRecord.state = .filtered
        }
    }
    
    
    func applySepiaFilter(_ image: UIImage) -> UIImage? {
        guard let data = UIImagePNGRepresentation(image) else { return nil }
        let inputImage = CIImage(data: data)
        
        if isCancelled {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        
        if isCancelled {
            return nil
        }
        
        guard
            let outputImage = filter.outputImage,
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return nil
        }
        
        return UIImage(cgImage: outImage)
    }

}
