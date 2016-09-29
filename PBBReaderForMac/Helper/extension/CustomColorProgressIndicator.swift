//
//  CustomColorProgressIndicator.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/9/29.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa

@IBDesignable
class CustomColorProgressIndicator: NSProgressIndicator {
    
    @IBInspectable var progressColor:NSColor!
    @IBInspectable var emptyColor:NSColor!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        super.drawRect(dirtyRect)
        self.wantsLayer = true
        
        // Clear background color
        NSColor.clearColor().set()
        NSRectFill(dirtyRect)
        
        // Draw progress line
        var activeRect = dirtyRect
        self.progressColor.set()
        activeRect.size.width = floor(activeRect.size.width * CGFloat(self.doubleValue / self.maxValue))
        NSRectFill(activeRect)
        
        // Draw empty line
        var passiveRect = dirtyRect
        passiveRect.size.width -= activeRect.size.width
        passiveRect.origin.x = activeRect.size.width
        self.emptyColor.set()
        NSRectFill(passiveRect)
    }
    
}
