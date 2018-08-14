//
//  ProfileViewController.swift
//  Tinder
//
//  Created by 洋蔥胖 on 2018/8/1.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userGenderSwitch: UISwitch!
    @IBOutlet weak var interestedGenderSwitch: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            userGenderSwitch.setOn(isFemale, animated: false)
        }
        
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData){
                        self.profileImageView.image = image
                    }
                }
            }
        }
        
        createWomen() //幫紅色懶覺人建幾個辛普森妹子
        
    }
    
    func createWomen() {
        let imageUrls = ["https://upload.wikimedia.org/wikipedia/en/7/76/Edna_Krabappel.png","https://static.comicvine.com/uploads/scale_small/0/40/235856-101359-ruth-powers.png","http://vignette3.wikia.nocookie.net/simpsons/images/f/fb/Serious-sam--cover.jpg/revision/latest?cb=20131109214146","https://s-media-cache-ak0.pinimg.com/736x/e4/42/5a/e4425aad73f01d36ace4c86c3156dcdc.jpg","http://www.simpsoncrazy.com/content/pictures/onetimers/LurleenLumpkin.gif","https://vignette2.wikia.nocookie.net/simpsons/images/b/bc/Becky.gif/revision/latest?cb=20071213001352","http://vignette3.wikia.nocookie.net/simpsons/images/b/b0/Woman_resembling_Homer.png/revision/latest?cb=20141026204206"]
        
        var counter = 0
        
        for imageUrl in imageUrls {
            counter += 1
            if let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url) {
                    let imageFile = PFFile(name: "photo.png", data: data)
                    
                    let user = PFUser()
                    user["photo"] = imageFile
                    user.username = String(counter)
                    user.password = "abc123"
                    user["isFemale"] = true
                    user["isInterestedInWomen"] = false
                    
                    user.signUpInBackground(block: { (success, error) in
                        if success {
                            print("Women User created!")
                        }
                    })
                }
            }
        }
    }
    
    //更新個人大頭照功能
    @IBAction func updateImageTapped(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //挑選照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    

    //更新個人資料(自己性向是男/女 和感興趣的性向是男/女)
    @IBAction func updateTapped(_ sender: Any) {
        
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn //在heroku上建一個["isFemale"]檔案來代表userGenderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestedGenderSwitch.isOn
                          
        //上面更新大頭照只是選照片 這裡才是把選完的照片上傳更新到heroku
        if let image = profileImageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData)
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if error != nil {
                        var errorMessage = "上傳Heroku更新失敗 - 再試一次"
                        
                        if let newError = error as NSError? {
                            if let detailError = newError.userInfo["error"] as? String {
                                errorMessage = detailError
                            }
                        }
                        
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = errorMessage
                        
                    } else {
                        print("上傳Heroku更新成功")
                    }
                })
            }
        }
    }
    
    
    
}
