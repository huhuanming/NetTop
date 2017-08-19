//
//  ViewController.swift
//  NetTop
//
//  Created by Huanming Hu  on 2017/8/19.
//  Copyright © 2017年 huhuanming. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateNetWorkData), userInfo: nil, repeats: true)
        RunLoop.current.run()
    }
    
    func updateNetWorkData() {
        let task = Process()
        task.launchPath = "/usr/bin/nettop"
        task.arguments = ["-x", "-k", "state", "-k", "interface", "-k", "rx_dupe", "-k", "rx_ooo", "-k", "re-tx", "-k", "rtt_avg", "-k", "rcvsize", "-k", "tx_win", "-k", "tc_class", "-k", "tc_mgt", "-k", "cc_algo", "-k", "P", "-k", "C", "-k", "R", "-k", "W", "-l", "1", "-t", "wifi", "-t", "wired"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            print(outputString)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

