//
//  WindowController.swift
//  NetTop
//
//  Created by Huanming Hu  on 2017/10/22.
//  Copyright © 2017年 huhuanming. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var netTopWindow: NSWindow!
    override func windowDidLoad() {
        super.windowDidLoad()
        self.netTopWindow.orderOut(self)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
