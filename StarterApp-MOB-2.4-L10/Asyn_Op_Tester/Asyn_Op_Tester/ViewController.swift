//
//  ViewController.swift
//  Asyn_Op_Tester
//
//  Created by Thomas Vandegriff on 6/26/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func fetchData(completion: @escaping(Result<String, Error>) -> ()){
        
        
        let url = URL(string: "https://apple.com")!

        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, err) in

            //TODO: Make sure we downloaded some data.
            if (data != nil && err == nil) {
                completion(.success("success"))
            } else {
                
                completion(.failure(err!))
            }
        }
        // Start the download task.
        dataTask.resume()

    }

}

