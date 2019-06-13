import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

let calculation = {
    for i in 0...100 {
        print(i)
    }
}

let thread: Thread = Thread {

    print("On thread: \(Thread.current) doing work")
    calculation()
    //TODO: What must the thread do here to match the expected output listed below?
}

print("On thread: \(Thread.current) doing nothing")
//TODO: Give new thread its proper name, as in expected output...
thread.name = "Background Thread"

thread.qualityOfService = .userInitiated

thread.start()

/* EXPECTED OUTPUT:
 On thread: <NSThread: 0x6000022d28c0>{number = 1, name = main} doing nothing
 On thread: <NSThread: 0x6000022fba00>{number = 3, name = Background Thread} doing work
 0
 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 11
 ...
 100
 */
             // 1 - Semaphore for Priority Tasks

// Define two queues with different prioritie
let highPriorityQueue = DispatchQueue.global(qos: .userInitiated)
let lowerPriorityQueue = DispatchQueue.global(qos: .utility)

// Define semaphore to keep track of threads to print at a time
let semaphore = DispatchSemaphore(value: 1)


func asynxPrint(queue: DispatchQueue, symbole: String) {

    queue.async {

        print("\(symbole) waiting...")
        semaphore.wait()

        for i in 0...10 {
            print(symbole, i)
        }

        print("\(symbole) done...")
        semaphore.signal()
    }
}

asynxPrint(queue: highPriorityQueue, symbole: "👚")
asynxPrint(queue: lowerPriorityQueue, symbole: "👕")

             // 2 - Semaphores for Deadlocks


let highPriorityQueue = DispatchQueue.global(qos: .userInitiated)
let lowerPriorityQueue = DispatchQueue.global(qos: .utility)

let semaphoreA = DispatchSemaphore(value: 1)
let semaphoreB = DispatchSemaphore(value: 1)


func asyncPrint(queue: DispatchQueue,
                symbol: String,
                resourceOne: String,
                resourceTwo: String,
                semOne: DispatchSemaphore,
                semTwo: DispatchSemaphore) {
    
    func requestResource(_ resource: String, with semaphore: DispatchSemaphore) {
        print("\(symbol) waiting for resource : \(resource)")
        semaphore.wait()
    }
    
    queue.async {
        
        requestResource(resourceOne, with: semOne)
        for i in 0...10 {
            if i == 5 {
                requestResource(resourceTwo, with: semTwo)
            }
            
            print(symbol, i)
        }
        
        print("\(symbol) releasing resources")
        semOne.signal()
        semTwo.signal()
    }
}

asyncPrint(queue: highPriorityQueue, symbol: "🔴", resourceOne: "DATA_A", resourceTwo: "DATA_B", semOne: semaphoreA, semTwo: semaphoreB)


asyncPrint(queue: lowerPriorityQueue, symbol: "🔵", resourceOne: "DATA_A", resourceTwo: "DATA_B", semOne: semaphoreA, semTwo: semaphoreB)
