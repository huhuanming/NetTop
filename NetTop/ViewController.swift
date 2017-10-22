//
//  ViewController.swift
//  NetTop
//
//  Created by Huanming Hu  on 2017/8/19.
//  Copyright © 2017年 huhuanming. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBOutlet var statusMenu: NSMenu!
    
    @IBAction func quitClick(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    
    var applicationMap: Dictionary<String, NTApplication> = [:]
    
    var processMap: Dictionary<String, String> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusItem.title = "NetTop"
        statusItem.menu = statusMenu

        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier != nil {
                let bundleIdentifier = app.bundleIdentifier ?? ""
                self.applicationMap[bundleIdentifier] = NTApplication(bundleIdentifier: bundleIdentifier, name: app.localizedName ?? bundleIdentifier, icon: app.icon!, bytesIn: 0, bytesOut: 0)
                self.processMap[String(app.processIdentifier)] = bundleIdentifier
            }
        }
        self.updateTrafficData()
    }
    
    func updateTrafficData() {
        let task = Process()
        task.launchPath = "/usr/bin/nettop"
        task.arguments = ["-t", "wifi", "-t", "wired", "-P", "-L", "1"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            let stringArray = outputString.split(separator: "\n")
            
            if stringArray.count < 2 {
                DispatchQueue.main.async {
                    self.updateTrafficData()
                }
                return
            }
            
            
            self.statusMenu.removeAllItems()
            
            for i in 1...(stringArray.count-1) {
                let string = stringArray[i]
                let infos = string.components(separatedBy: ",")
                let processId = infos[1].components(separatedBy: ".").last!
                let bytesIn = infos[4]
                let bytesOut = infos[5]
                
                if let bundleIdentifier = self.processMap[processId] {
                    if let app = self.applicationMap[bundleIdentifier] {
                        let menuItem = NSMenuItem.init(title: "\(app.name) \(Float(bytesIn)! / 1024 / 1024) Mib \(Float(bytesOut)! / 1024 / 1024) Mib", action: nil, keyEquivalent: "")
                        self.statusMenu.addItem(menuItem)
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.updateTrafficData()
            })
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

