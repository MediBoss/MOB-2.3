import UIKit
import Foundation

        // ** DISPATCH QUEUE **//
//DispatchQueue.global().async {
//    for i in 1...5 {
//        print("global async 1 : \(i)")
//    }
//}
//
//DispatchQueue.global().async {
//    for i in 10...15 {
//        print("global async 2 : \(i)")
//    }
//}
//

        // ** DISPATCH WORK ITEM ** //

//let dispatchWorkItem = DispatchWorkItem {
//
//    print("start of item")
//    sleep(2)
//    print("end of item")
//
//}
//
//// Runs on the current thread
//dispatchWorkItem.perform()
//
//// Perfrom on the gloabal queue
//DispatchQueue.global().async(execute: dispatchWorkItem)


        //** DISPATCH GROUP **//

let item = DispatchWorkItem {
    print("work item start")
    sleep(1)
    print("work item end")
}

let dispatchGroup = DispatchGroup()
let queue = DispatchQueue(label: "cusrom dq")

queue.async(group: dispatchGroup) {
    print("block start")
    sleep(2)
    print("block end")
}

DispatchQueue.global().async(group: dispatchGroup, execute: item)
dispatchGroup.notify(queue: .global()) {
    print("Dispatch group over")
}
