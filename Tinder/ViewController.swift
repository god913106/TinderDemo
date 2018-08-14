//
//  ViewController.swift
//  Tinder
//
//  Created by 洋蔥胖 on 2018/7/30.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var displayUserID = ""
    //@IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var matchImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Gesture(手勢)Recognizer(識別)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        
        matchImageView.addGestureRecognizer(gesture)
        
        updateImage()
        
        //此時就會想tinder可以新增功能，例如：相遇日期、使用者自身範圍內的其他用戶
        //取得當前使用者的經緯度並存進後台
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let point = geoPoint {
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    //action後面用@selector時 就要有個method是@objc開頭
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer){
        
        let labelPoint = gestureRecognizer.translation(in: view)
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height  / 2 + labelPoint.y)
        
        //當手勢識別進行中 往左右滑 圖將會旋轉縮小
        
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200) //旋轉
        
        let scale = min(100 / abs(xFromCenter), 1) //比例
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        matchImageView.transform = scaledAndRotated
        
        //當手勢結束觸摸，在運行循環的下一個週期發送動作消息
        if gestureRecognizer.state == .ended {
            var acceptedOrRejected = ""
            //往左滑
            if matchImageView.center.x < (view.bounds.width / 2 - 100) {
                print("沒興趣")
                acceptedOrRejected = "rejected"
            }
            //往右滑
            if matchImageView.center.x > (view.bounds.width / 2 + 100) {
                print("有興趣")
                acceptedOrRejected = "accepted"
            }
            //當你決定有無興趣後 將會acceptedOrRejected的"rejected"和"accepted" 更新到heroku
            if acceptedOrRejected != "" && displayUserID != "" {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            
            //當上面檢查完有無興趣後，讓view 回到中間
            
            rotation = CGAffineTransform(rotationAngle: 0) //rotationAngle 旋轉角度:0 不轉了 回到原本樣面
            
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1) // 比例 1:1
            
            matchImageView.transform = scaledAndRotated
            
            matchImageView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
        
    }
    
    func updateImage() {
        if let query = PFUser.query(){  //從heroku找資料
            //因為資料是一定找的到的 所以不能可選option
            if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] {
                
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
            }
            
            if let isFemale = PFUser.current()?["isFemale"] {
                
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
            }
            //當你選完是否有興趣後 就加進 ignoredUsers 下一位
            var ignoredUsers : [String] = []
            //有興趣
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {
                ignoredUsers += acceptedUsers
            }
            //沒興趣
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }
            //繼續搜尋還沒決定有無興趣的
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            
            //加入一個新邏輯，在使用者經緯度正負1的範圍內的用戶們
            if let geoPoint = PFUser.current()?["location"] as? PFGeoPoint {
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1, longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1, longitude: geoPoint.longitude + 1))
            }
            
            query.limit = 1 //一次只顯示一位
            
            query.findObjectsInBackground { (objects, error) in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                imageFile.getDataInBackground(block: { (data, error) in
                                    if let imageData = data {
                                        self.matchImageView.image = UIImage(data: imageData)
                                        if let objectID = object.objectId {
                                            self.displayUserID = objectID
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
    }
    
}



