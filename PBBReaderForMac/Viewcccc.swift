//
//  Viewcccc.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 24/11/2016.
//  Copyright © 2016 recomend. All rights reserved.
//

import Cocoa
import AppKit

class Viewcccc: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func dfdfdfdf(_ sender: Any) {
        let url = "http://192.168.85.92:8099/HostMonitor/client/log/addLog"
        let model = PBBLogModel.init(.LogTypeFatal,
                                     APPName: .APPNameReader,
                                     description: "ddddd")
        let log = PBBLogAPI.shareInstance.upLoadLog(to: url, logModel: model)
    }
    
}