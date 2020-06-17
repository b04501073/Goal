//
//  CreateAccountViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/23.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

//Handling signup view
class CreateAccountViewController: UIViewController, UITextFieldDelegate{
    weak var loginDelegate: LoginProtocol?
    
    @IBOutlet weak var emailtextfield: UITextField!
    @IBOutlet weak var passwordtextfield: UITextField!
    @IBOutlet weak var nicknametextfield: UITextField!
    @IBOutlet weak var creatbtn: UIButton!
//    @IBOutlet weak var loadinglabel: UILabel!
//    var nicknameisUniqueue = false
    
    @IBAction func createAccountAction(_ sender: AnyObject) {
        if Checkinputvalue() == true{
            loginDelegate?.CreateNewAccount(nickname: nicknametextfield.text!,email: emailtextfield.text!, password: passwordtextfield.text!, sender: self)
        }
        
    }
    
    let appenterSegue = "enterSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        loginDelegate = appDelegate.firebaseController
//        loadinglabel.text = ""
//        nicknametextfield.addTarget(self, action: #selector(checknickname), for: .editingDidEnd)
        // Do any additional setup after loading the view.
    }
    
    func failed_signup(){
        let controller = UIAlertController(title: "Login Error", message: "Failed to signup, please enter uset information again!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    func successfully_signup(){
        performSegue(withIdentifier: appenterSegue, sender: nil)
    }
    
    func Checkinputvalue() -> Bool{
        if emailtextfield.text == nil{
            let controller = UIAlertController(title: "User input error", message: "Please enter the user email", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
            return false
        }
        else if passwordtextfield.text == nil{
            let controller = UIAlertController(title: "User input error", message: "Please enter the user password", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
            return false
        } else if nicknametextfield.text == nil{
            let controller = UIAlertController(title: "User input error", message: "Please enter the user nickname", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    @objc func checknickname(){
//        print("checking!")
//        nicknameisUniqueue = false
//        if let nickname = nicknametextfield.text{
//            self.loadinglabel.text = "Checking..."
//            loginDelegate?.nicknameIsUnique(nickname: nickname, sender: self)
//        } else{
//            self.loadinglabel.text = "Please enter nickname..."
//        }
//    }
//
//    func nicknameisUnique(isUnique: Bool){
//        nicknameisUniqueue = isUnique
//        if isUnique{
//            self.loadinglabel.text = "Nickname is available!"
//        }else{
//            self.loadinglabel.text = "Nickname is being used! Please enter a new one!"
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
