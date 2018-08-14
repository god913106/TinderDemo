//
//  LogInViewController.swift
//  Tinder
//
//  Created by 洋蔥胖 on 2018/7/31.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var changeLogInSignUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var signUpMode = false // 註冊模式

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true
        
    }

    //真正處理註冊/登錄事件的按鍵
    @IBAction func LogInSignUpTapped(_ sender: Any) {
        
        if signUpMode {
            //註冊模式
            let user = PFUser()
            
            user.username = userNameTextField.text
            user.password = passWordTextField.text
            
            //帳密檢查機制
            user.signUpInBackground { (success, error) in
                if error != nil {
                    var errorMessage = "註冊失敗 - 請再試一次"
                    
                    if let newError = error as NSError? {
                        if let detailError = newError.userInfo["error"] as? String {
                            errorMessage = detailError
                        }
                    }
                    //顯示錯誤文字 提醒使用者錯在哪了
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                }else {
                    print("註冊成功")
                    self.performSegue(withIdentifier: "profileSegue", sender: nil)
                }
            }
            
        }else {
            //登錄模式
            if let userName = userNameTextField.text {
                if let passWord = passWordTextField.text {
                    PFUser.logInWithUsername(inBackground: userName, password: passWord) { (user, error) in
                        if error != nil {
                            
                            var errorMessage = "登錄失敗 - 再試一次"
                            
                            if let newError = error as NSError? {
                                if let detailError = newError.userInfo["error"] as? String {
                                    errorMessage = detailError
                                }
                            }
                            
                            //顯示錯誤文字 提醒使用者錯在哪了
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                            
                        }else {
                            print("登錄成功")
                            //self.performSegue(withIdentifier: "profileSegue", sender: nil)
                            //當登錄成功後 檢查是否用戶["isFemale"]為nil 分別導向各自頁面
                            if PFUser.current() != nil {
                                
                                if user?["isFemale"] != nil {
                                    self.performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)
                                }else{
                                    self.performSegue(withIdentifier: "profileSegue", sender: nil)
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            
            if PFUser.current()?["isFemale"] != nil {
                self.performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)
            }else{
                self.performSegue(withIdentifier: "profileSegue", sender: nil)
            }
            
        }
    }
    
    //當點這個按鍵就會轉換成註冊/登錄模式
    @IBAction func changeLogInSignUpTapped(_ sender: Any) {
        
        if signUpMode {
            
            logInSignUpButton.setTitle("登錄", for: .normal)
            changeLogInSignUpButton.setTitle("註冊", for: .normal)
            signUpMode = false
            
        }else {
            
            logInSignUpButton.setTitle("註冊", for: .normal)
            changeLogInSignUpButton.setTitle("登錄", for: .normal)
            signUpMode = true
            
        }
        
    }
    

}
