//
//  MessageTableViewCell.swift
//  Tinder
//
//  Created by 洋蔥胖 on 2018/8/2.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import Parse

class MessageTableViewCell: UITableViewCell {
    
    var recipientObjectId = ""
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //當send按下去後 會在heroku新建一個message的object
    @IBAction func sendTapped(_ sender: Any) {
        let message = PFObject(className: "Message")
        
        message["sender"] = PFUser.current()?.objectId //message的屬性有當前使用者的id
        message["recipient"] = recipientObjectId       //接收者的id 從cell的userIds[indexPath.row] 來的
        message["content"] = messageTextField.text     //使用者 收送訊息給 接收者
        
        message.saveInBackground() 
    }
    
    
}
