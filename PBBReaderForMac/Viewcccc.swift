//
//  Viewcccc.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

import Cocoa
import AppKit
import PBBLogSDK

class Viewcccc: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func dfdfdfdf(_ sender: Any) {
        let url = "http://192.168.85.92:8099/HostMonitor/client/log/addLog"
        let model = PBBLogModel.init(.LogTypeFatal, in: .APPNameReader, desc: "ddddd")
        let log = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)
//        PBBLogAPI.shareInstance.upLoadLog.(<#T##String#>, <#T##PBBLogModel#>)
    }
    
}
