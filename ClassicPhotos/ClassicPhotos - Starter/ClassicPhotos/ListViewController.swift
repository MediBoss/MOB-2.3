/// Copyright (c) 2018 Razeware LLC
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

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!

class ListViewController: UITableViewController {
    
    var photos: [PhotoRecord] = []
    var pendingOperations = PendingOperations()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Classic Photos"
    
    fetchPhotoDetails()
  }
  
  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        //1
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2
        let photoDetails = photos[indexPath.row]
        
        //3
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4
        switch (photoDetails.state) {
        case .filtered:
            indicator.stopAnimating()
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .new, .ready:
            indicator.startAnimating()
            startOperations(for: photoDetails, at: indexPath)
        }
        
        return cell
    }
    
    func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        case .ready:
            startFiltration(for: photoRecord, at: indexPath)
        default:
            NSLog("do nothing")
        }
    }

    
    func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        //1 - Check check if there is already a particular operation at the goven index, if so, ignore the request
        guard pendingOperations.donwloadsInProgress[indexPath] == nil else {
            return
        }
        
        //2 - Create an unstance of the ImageDownloader class
        let downloader = ImageDownloader(photoRecord)
        
        //3 - Add completion block that executes when the operatio is completed
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.donwloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        //4 - add the current operation in the list of donwload in progress to keep track
        pendingOperations.donwloadsInProgress[indexPath] = downloader
        
        //5 - Add the operation to the download queue. This actually triggers the start() method
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltration(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
        guard pendingOperations.filterationsInProgress[indexPath] == nil else {
            return
        }
        
        let filterer = ImageFiltration(photoRecord)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.filterationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.filterationsInProgress[indexPath] = filterer
        pendingOperations.filterationQueue.addOperation(filterer)
    }

  
  // MARK: - image processing

  func applySepiaFilter(_ image:UIImage) -> UIImage? {
    let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
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
    
    
    
    func fetchPhotoDetails() {
        let request = URLRequest(url: dataSourceURL)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            
            let alertController = UIAlertController(title: "Oops!",
                                                    message: "There was an error fetching photo details.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            
            if let data = data {
                do {
            
                    let datasourceDictionary =
                        try PropertyListSerialization.propertyList(from: data,
                                                                   options: [],
                                                                   format: nil) as! [String: String]

                    for (name, value) in datasourceDictionary {
                        let url = URL(string: value)
                        if let url = url {
                            let photoRecord = PhotoRecord(name: name, url: url)
                            self.photos.append(photoRecord)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.tableView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            // 6
            if error != nil {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        // 7
        task.resume()
    }

}

