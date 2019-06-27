import UIKit

class TiltShiftTableViewController: UITableViewController {
  private let context = CIContext()
  private var urls: [URL] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let plist = Bundle.main.url(forResource: "Photos",
                                      withExtension: "plist"),
      let contents = try? Data(contentsOf: plist),
      let serial = try? PropertyListSerialization.propertyList(
        from: contents,
        format: nil),
      let serialUrls = serial as? [String] else {
        print("Something went horribly wrong!")
        return
    }
    urls = serialUrls.compactMap(URL.init)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return urls.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
    let queue = OperationQueue()
    let downloadOp = NetworkImageOperation(url: urls[indexPath.row])
    
    let tiltShiftOp = TiltShiftOperation()
    tiltShiftOp.addDependency(downloadOp)
    
    
    let op = NetworkImageOperation(url: urls[indexPath.row])
    tiltShiftOp.completionBlock = {
      DispatchQueue.main.async {
        guard let cell = tableView.cellForRow(at: indexPath)
          as? PhotoCell else { return }
        cell.isLoading = false
        cell.display(image: tiltShiftOp.outputImage)
      }
    }
    queue.addOperation(downloadOp)
    queue.addOperation(tiltShiftOp)
    
    return cell
  }
}
