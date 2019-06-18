//
//  ViewController.swift
//  GCDAsyncImage
//
//  Created by Chase Wang on 2/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    let numberOfCells = 20_000
    var photos: [Photo] = []
    var pendingOperations = PendingOperations()
    
    let imageURLArray8 = Unsplash.defaultImageURLs
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
        
        let photo = photos[indexPath.row]
        
        cell.imageView?.image = photo.image
        
        switch (photo.state) {
        case .filtered:
            break
            
        case .failed:
            print("failed")
        
        case .new, .ready:
            startOperations(for: photo, at: indexPath)

        }

        return cell
    }
    
    func startOperations(for photoRecord: Photo, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        case .ready:
            fallthrough
            //startFiltration(for: photoRecord, at: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownload(for photo: Photo, at indexPath: IndexPath) {
        
        guard pendingOperations.donwloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = PhotoDownloadOperation(photo)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.tableview.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        //5 - Add the operation to the download queue. This actually triggers the start() method
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltration(for photo: Photo, at indexPath: IndexPath) {
        
        guard pendingOperations.filterationsInProgress[indexPath] == nil else {
            return
        }
        
        let filterer = PhotoFilterOperation(photo)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.filterationsInProgress.removeValue(forKey: indexPath)
                self.tableview.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        pendingOperations.filterationsInProgress[indexPath] = filterer
        pendingOperations.filterationQueue.addOperation(filterer)
    }
    
    func fetchPhotos() {
        
        imageURLArray8.forEach { (url) in
            
            let photo = Photo(url: url)
            self.photos.append(photo)
        }
        
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
}

