//
//  ViewController.swift
//  Project9
//
//  Created by Jinwoo Kim on 1/3/21.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        log("This ie me printing a message")
//        runBackgroundCode1()
//        runBackgroundCode2()
//        runBackgroundCode3()
//        runBackgroundCode4()
//        runSynchronousCode()
//        runDelayedCode()
//        runMultiprocessing1()
        runMultiprocessing(useGCD: true)
//        runMultiprocessing(useGCD: false)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func log(_ message: String) {
        print("Printing message: \(message)")
    }
    
    func runBackgroundCode1() {
        performSelector(inBackground: #selector(log(_:)), with: "Hello world 1")
        performSelector(inBackground: Selector("log:"), with: "Hi")
        performSelector(onMainThread: #selector(log(_:)), with: "Hello world 2", waitUntilDone: false)
    }
    
    func runBackgroundCode2() {
        DispatchQueue.global().async { [unowned self] in
            self.log("On background thread")
            DispatchQueue.main.async {
                self.log("On main thread")
            }
        }
    }
    
    func runBackgroundCode3() {
        DispatchQueue.global().async {
            guard let url = URL(string: "https://www.apple.com") else { return }
            guard let str = try? String(contentsOf: url) else { return }
            print(str)
        }
    }
    
    // qos의 순위가 높을 수록 빠르게 처리된다
    func runBackgroundCode4() {
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            self.log("This is high priority")
        }
    }
    
    func runSynchronousCode() {
        // asynchronous!
        DispatchQueue.global().async {
            print("Background thread 1")
        }
        
        print("Main thread 1")
        
        // synchronous
        DispatchQueue.global().sync {
            print("Background thread 2")
            Thread.sleep(forTimeInterval: 3)
        }
        
        print("Main thread 2")
    }
    
    func runDelayedCode() {
        // 둘이 같다
        perform(#selector(log(_:)), with: "Hi, it's with some delay!", afterDelay: 3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
            self.log("Hello world 2")
        }
        
        //
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [unowned self] in
            self.log("Hello world 3")
        }
    }
    
    func runMultiprocessing1() {
        DispatchQueue.concurrentPerform(iterations: 10) {
//            print($0)
//            Thread.sleep(forTimeInterval: 1)
            print("\($0): \(Thread.isMainThread)")
        }
    }
    
    func runMultiprocessing(useGCD: Bool) {
        var array = Array(0..<42)
        let start = CFAbsoluteTimeGetCurrent()
        
        if useGCD {
            DispatchQueue.concurrentPerform(iterations: array.count) {
                array[$0] = fibonacci(of: $0)
            }
            
//            for i in 0..<array.count {
//                DispatchQueue(label: "gcd", attributes: .concurrent).sync {
//                    array[i] = self.fibonacci(of: i)
//                }
//            }
            
//            for i in 0..<array.count {
//                DispatchQueue(label: "gcd", attributes: .concurrent).async {
//                    array[i] = self.fibonacci(of: i)
//                }
//            }
        } else {
            for i in 0..<array.count {
                array[i] = fibonacci(of: array[i])
            }
        }
        
        let end = CFAbsoluteTimeGetCurrent() - start
        print("Took \(end) seconds")
    }
    
    func fibonacci(of num: Int) -> Int {
        if num < 2 {
            return num
        } else {
            return fibonacci(of: num - 1) + fibonacci(of: num - 2)
        }
    }
}

