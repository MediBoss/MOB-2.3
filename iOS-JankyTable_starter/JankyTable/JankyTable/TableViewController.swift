//
//  TableViewController.swift
//  JankyTable
//
//  Created by Thomas Vandegriff on 5/28/19.
//  Copyright © 2019 Make School. All rights reserved.
//


/**
 
 Questions :
 1. 6 threads(inclusive of the main thread)
 2. 5 queues
 3. Thread 1
 4.
 5.
 6. Because the images are being loaded serially
 7. Scrolling is slow because everytime we scroll, the cell is being reused, hence calling the cellForRowAt which is perfoming heaving computation on the main thread

 **/

import UIKit

class TableViewController: UITableViewController {

    private var photosDict: [String: String] = [:]
    lazy var photos = NSDictionary(dictionary: photosDict)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Step 1 -  Read and load data from Plist on global queue with a user interactive priority
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            guard let plist = Bundle.main.url(forResource: "PhotosDictionary", withExtension: "plist"),
                let contents = try? Data(contentsOf: plist),
                let serializedPlist = try? PropertyListSerialization.propertyList(from: contents, format: nil),
                let serialUrls = serializedPlist as? [String: String] else {
                    print("error with serializedPlist")
                    return
            }
            self.photosDict = serialUrls
        }
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photosDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        
        var image : UIImage?
        
        // Step 2 - Download data and Filter Images concurently on background thread
        DispatchQueue.global().async {
            guard let imageURL = URL(string:self.photos[rowKey] as! String),
                let imageData = try? Data(contentsOf: imageURL) else { return }
            
            // Simulate a network wait
            Thread.sleep(forTimeInterval: 1)
            print("sleeping 1 sec")
            
            let unfilteredImage = UIImage(data:imageData)
            image = self.applySepiaFilter(unfilteredImage!)
            
            // Step 3 -  Update UI on Main Thread
            DispatchQueue. main.async {
                // Configure the cell...
                cell.textLabel?.text = rowKey
                if image != nil {
                    cell.imageView?.image = image!
                }
            }
            
        }
        return cell
    }
    
    // MARK: - image processing
    
    func applySepiaFilter(_ image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:image.pngData()!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        
        guard let outputImage = filter!.outputImage,
            let outImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
        }
        return UIImage(cgImage: outImage)
    }
}


