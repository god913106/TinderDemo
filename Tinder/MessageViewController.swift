//
//  MessageViewController.swift
//  Tinder
//
//  Created by 洋蔥胖 on 2018/8/2.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import Parse

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var images : [UIImage] = []     //互相感興趣的用戶照片
    var userIds : [String] = []     //用戶id
    var messages : [String] = []    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query() {
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            
            if let acceptedPeeps = PFUser.current()?["accepted"] as? [String] {
                query.whereKey("objectId", containedIn: acceptedPeeps)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    if let users = objects {
                        for user in users {
                            if let theUser = user as? PFUser {
                                if let imageFile = theUser["photo"] as? PFFile {
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        if let imageData = data {
                                            if let image = UIImage(data: imageData) {
                                                
                                                if let objectId = theUser.objectId {
                                                    
                                                    let messagesQuery = PFQuery(className: "Message")
                                                    //去查詢Heroku的message ["recipient"] 接收者
                                                    messagesQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId as Any)
                                                    //去查詢Heroku的message ["sender"] 發送者
                                                    messagesQuery.whereKey("sender", equalTo: theUser.objectId as Any)
                                                    //去查詢Heroku的message ["content"] 對話內容，因為是雙方對話 所以內容不會只有一句 要用array for迴圈
                                                    messagesQuery.findObjectsInBackground(block: { (objects, error) in
                                                        var messagetext = "No message from this user."
                                                        if let objects = objects {
                                                            for message in objects {
                                                                if let content = message["content"] as? String {
                                                                    messagetext = content
                                                                }
                                                            }
                                                        }
                                                        self.messages.append(messagetext)
                                                        self.userIds.append(objectId)
                                                        self.images.append(image)
                                                        self.tableView.reloadData()
                                                    })
                                                    
                                                }
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    // MARK: - tableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MessageTableViewCell{
            
            cell.profileImageView.image = images[indexPath.row]
            cell.recipientObjectId = userIds[indexPath.row]
            
            //記得要做一個判斷式
            cell.messageLabel.text = "You haven't received a message yet"
            
            cell.messageLabel.text = messages[indexPath.row]
            
            return cell
        }
        return UITableViewCell()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
