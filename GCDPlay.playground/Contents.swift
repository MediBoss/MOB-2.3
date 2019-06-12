import UIKit
import Foundation
//
//        // ** DISPATCH QUEUE **//
////DispatchQueue.global().async {
////    for i in 1...5 {
////        print("global async 1 : \(i)")
////    }
////}
////
////DispatchQueue.global().async {
////    for i in 10...15 {
////        print("global async 2 : \(i)")
////    }
////}
////
//
//        // ** DISPATCH WORK ITEM ** //
//
////let dispatchWorkItem = DispatchWorkItem {
////
////    print("start of item")
////    sleep(2)
////    print("end of item")
////
////}
////
////// Runs on the current thread
////dispatchWorkItem.perform()
////
////// Perfrom on the gloabal queue
////DispatchQueue.global().async(execute: dispatchWorkItem)
//
//
//        //** DISPATCH GROUP **//
//
//let item = DispatchWorkItem {
//    print("work item start")
//    sleep(1)
//    print("work item end")
//}
//
//let dispatchGroup = DispatchGroup()
//let queue = DispatchQueue(label: "cusrom dq")
//
//queue.async(group: dispatchGroup) {
//    print("block start")
//    sleep(2)
//    print("block end")
//}
//
//DispatchQueue.global().async(group: dispatchGroup, execute: item)
//dispatchGroup.notify(queue: .global()) {
//    print("Dispatch group over")
//}

//let semaphore = DispatchSemaphore(value: 1)
//DispatchQueue.global().async {
//    print("Person 1 - wait")
//    semaphore.wait()
//    print("Person 1 - wait finished")
//    sleep(1) // Person 1 playing with Switch
//    print("Person 1 - done with Switch")
//    semaphore.signal()
//}
//
//DispatchQueue.global().async {
//    print("Person 2 - wait")
//    semaphore.wait()
//    print("Person 2 - wait finished")
//    sleep(1) // Person 2 playing with Switch
//    print("Person 2 - done with Switch")
//    semaphore.signal()
//}
//
//DispatchQueue.global().async {
//    print("Person 3 - wait")
//    semaphore.wait()
//    print("Person 3 - wait finished")
//    sleep(1) // Person 2 playing with Switch
//    print("Person 3 - done with Switch")
//    semaphore.signal()
//}


func downloadMovies(numberOfMovies: Int) {

    // Create a semaphore
    let sm = DispatchSemaphore(value: 1)
    // Launch 8 tasks
    
    DispatchQueue.global(qos: .background).async {
        for i in 1...8{
            sm.wait()
            sleep(2)
            print("Task \(i) is done")
            sm.signal()
        }
        print("Completed all tasks")
    }
}

downloadMovies(numberOfMovies:2)
