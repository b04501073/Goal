//
//  LoginViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/21.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

//Handling login view
class LoginViewController: UIViewController {

    @IBOutlet weak var emailtextfield: UITextField!
    @IBOutlet weak var passwordtextfiel: UITextField!
    @IBOutlet weak var hisepasswordbtn: UIButton!
    
    @IBAction func hidepassword(_ sender: AnyObject) {
        ishidePassword = !ishidePassword
        passwordtextfiel.isSecureTextEntry = ishidePassword
        if(ishidePassword){
            hisepasswordbtn.tintColor = .darkGray
        } else{
            hisepasswordbtn.tintColor = .lightGray
        }
    }
    @IBAction func loginAccountAction(_ sender: AnyObject) {
        if Checkinputvalue() == true{
            loginDelegate?.loginAccount(email: emailtextfield.text!, password: passwordtextfiel.text!, successfully_callback: {
                self.successfully_login()
            }, failed_callback: {
                self.failed_login()
            })
        }
        
    }
    
    weak var loginDelegate: LoginProtocol?
    
    let appenterSegue = "enterSegue"
    var ishidePassword = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        loginDelegate = appDelegate.firebaseController
        
        emailtextfield.text = "max860113@gmail.com"
        passwordtextfiel.text = "xu3xu4m06"
        passwordtextfiel.isSecureTextEntry = true
        // Do any additional setup after loading the view.
        loginDelegate?.logoutAccount()
    }
    
    func failed_login(){
        let controller = UIAlertController(title: "Login Error", message: "Failed to login, please enter uset information again!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    func successfully_login(){
        performSegue(withIdentifier: appenterSegue, sender: nil)
    }
    
    func Checkinputvalue() -> Bool{
        if emailtextfield.text == ""{
            let controller = UIAlertController(title: "User input error", message: "Please enter the user email", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
            return false
        }
        else if passwordtextfiel.text == ""{
            let controller = UIAlertController(title: "User input error", message: "Please enter the user password", preferredStyle: .alert)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
