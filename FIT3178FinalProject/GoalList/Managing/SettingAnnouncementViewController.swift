//
//  SettingAnnouncementViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/4.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class SettingAnnouncementViewController: UIViewController, AnnouncementPropocol{

    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var contenttextview: UITextView!
    @IBOutlet weak var savebtn: UIButton!
    var goalID: String!
    var dailyWall: DailyWall!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        // Do any additional setup after loading the view.
        contenttextview.text = dailyWall.announcement?.content
    }
    
    @IBAction func saveannouncement(_ sender: Any){
        savebtn.isEnabled = false
        if contenttextview.text != ""{
            //without pictures
            let datearr = dailyWall.date.split(separator: "-")
            let selected_date = Dateunit(year: Int(datearr[0]), month: Int(datearr[1]), date: Int(datearr[2]))
            databaseController?.createPost(selected_date: selected_date, content: contenttextview.text, image: nil, goalID: goalID, isannouncement: true, succesful_callback: {
                self.sucessfullyAdded()
            }, failed_callback: {
                self.failedAdded()
            })
        }
    }
    
    func sucessfullyAdded() {
        navigationController?.popViewController(animated: true)
    }
    
    func failedAdded() {
        savebtn.isEnabled = true
        print("Failed to save!")
    }
    
    func SetAnnouncement(content: String) {
        contenttextview.text = content
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "autofillin"{
            if let destination = segue.destination as? AutoFillinViewController{
                destination.announcementDelegate = self
            }
        }
    }
    

}
