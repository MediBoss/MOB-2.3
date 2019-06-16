  import Foundation
  
//  let printerOperation = BlockOperation() // 1) create printerOperation as BlockOperation
//
//  // 2) add code blocks to the operation
//  printerOperation.addExecutionBlock { print("I") }
//  printerOperation.addExecutionBlock { print("am") }
//  printerOperation.addExecutionBlock { print("printing") }
//  printerOperation.addExecutionBlock { print("block") }
//  printerOperation.addExecutionBlock { print("operation") }
//  printerOperation.addExecutionBlock { print("Medi") }
//
//  printerOperation.completionBlock = { // 3) set completion block
//    print("I'm done printing")
//    // do something here once all the blocks have complete
//  }
//
//  let operationQueue = OperationQueue() // 4) Create an OperationQueue
//  operationQueue.addOperation(printerOperation) // 5) add operation to queue
//
//
         // TESTING OPERATION BLOCK ORDER OF EXECUTION

  let complexOperation = BlockOperation()
  let complexOperationQueue = OperationQueue()
  
  complexOperationQueue.maxConcurrentOperationCount = 2 // Num of ops to run concurently


  // First block
  complexOperation.addExecutionBlock {
    for i in 1...100{
        // do some heavy shit
    }
    print("block 1 done")
  }

  // second block
  complexOperation.addExecutionBlock {
    for i in 1...50{
        // do some heavy shit
    }
    print("block 2 done")
  }

  // Third block
  complexOperation.addExecutionBlock {
    for i in 1...5{
        // do some heavy shit
    }
    print("block 3 done")
  }

  //OperationQueue.main // To do UI work
  complexOperationQueue.addOperation(complexOperation)
