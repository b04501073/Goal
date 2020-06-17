//
//  AddTodoViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/7.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Foundation

class AddTodoViewController: UIViewController {
    weak var coredataController: CoreDataProtocol?
    
    @IBOutlet weak var todo_textfield: UITextField!
    
    @IBAction func savebtn_pressed(){
        if let content = todo_textfield.text{
            let _ = coredataController?.addTodoItem(title: content)
            navigationController?.popViewController(animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        coredataController = appDelegate.coredataController
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
