//
//  ActivationSuccessController.swift
//  PBBReaderForMac
//
//  Created by pengyucheng on 16/7/12.
//  Copyright © 2016年 recomend. All rights reserved.
//

import Cocoa
import PBBLogSDK

class ActivationSuccessController: NSViewController
{
    @IBOutlet weak var ibShowInfoLabel: NSTextField!
    
    @IBOutlet weak var qqLabel: NSTextField!
    @IBOutlet weak var phoneLabel: NSTextField!
    @IBOutlet weak var emailLabel: NSTextField!
    
    @IBOutlet weak var ibRemarkLabel: NSTextField!
    @IBOutlet weak var ibMakerLabel: NSTextField!
    @IBOutlet weak var ibSelfTitleLabel: NSTextField!
    
    @IBOutlet weak var ibRetoActivation: NSButton!
    
    var fileId = 0
    var orderId = 0
    
    var qq = ""
    var phone = ""
    var email = ""
    var field1name = ""
    var field2name = ""
    
    var bOpenInCome = 0
    
    var showInfo = ""
    var needShowDiff = 0
    var makerNick = ""
    var needReapply = 0
    var applyId = 0
    var remark = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ibRetoActivation.updateTitleAttribute(ibRetoActivation.title, textColor: NSColor.white)
        // Do view setup here.
        qqLabel.stringValue =  qq
        phoneLabel.stringValue = phone
        emailLabel.stringValue = email
        //    BOOL uu = [qq isEqualToString:""]
        
        if (ToolString.isBlankString(qq))
        {
            qqLabel.stringValue =  "无"
            qq = "无"
        }
        if (ToolString.isBlankString(phone))
        {
            phoneLabel.stringValue = "无"
            phone = "无"
        }
        if (ToolString.isBlankString(email))
        {
            emailLabel.stringValue = "无"
            email = "无"
        }
        if (ToolString.isBlankString(remark))
        {
            remark = ""
        }
        
        if (needReapply == 1)
        {
            ibSelfTitleLabel.stringValue = "激活失败"
            ibRetoActivation.isHidden = false
        }
        else
        {
            ibSelfTitleLabel.stringValue = "申请已提交"
            ibRetoActivation.isHidden = true
        }
        
        
        if (needShowDiff == 0)
        {
            ibShowInfoLabel.textColor = kGreen
        }
        else
        {
            ibShowInfoLabel.textColor = NSColor.orange
        }
        
        ibShowInfoLabel.stringValue = showInfo
        
        //作者
        ibMakerLabel.stringValue = makerNick
        ibRemarkLabel.stringValue = remark
    }
    
    @IBAction func ibaRetoActivation(_ sender: AnyObject)
    {
        self.dismiss(true)
        AppDelegateHelper.shared().getApplyFileInfo(byApplyId: applyId,fileID: fileId)
        PBBLogModel(.INFO, in: .ReaderMac, desc: "重新申请+1").sendTo()
    }
    
    override func dismiss(_ sender: Any?)
    {
        super.dismiss(sender)
        if !(sender is Bool)
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "CancleClosePlayerWindows"), object: nil, userInfo: ["pycFileID":fileId])
            
        }
    }
}
