//
//  GoalDetailViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/3.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Firebase

class GoalDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var goalforDetails: Goal!
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var duration_label: UILabel!
    @IBOutlet weak var tableview: UITableView!
    weak var databaseController: DatabaseProtocol?
    var wall: Wall?
    var selected_dailywall: DailyWall?
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setup basic information
        title_label.text = goalforDetails.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let startdatestr = dateFormatter.string(from: goalforDetails.startDate.dateValue())
        let enddatestr = dateFormatter.string(from: goalforDetails.endDate.dateValue())
        duration_label.text = "\(startdatestr) - \(enddatestr)"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listener = databaseController?.setUpListener_on_SelectedWall(goalID: goalforDetails.id, setNewWall_callback: {
            fechedWall in
            self.wall = fechedWall
            self.tableview.reloadData()
        })
//        databaseController?.addWallListener(listener: self)
//        databaseController?.fetch_selectedwall(by: goalforDetails.id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
//        databaseController?.removeWallListener(listener: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return wall?.dailywalls.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalcell", for: indexPath)
        if let contentlabel = cell.contentView.subviews[0] as? UILabel{
            contentlabel.text = wall?.dailywalls[indexPath.section].announcement?.content ?? "no value"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return wall?.dailywalls[section].date
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_dailywall = wall?.dailywalls[indexPath.section]
        performSegue(withIdentifier: "announcementsetting", sender: nil)
    }
//    func onWallChange(newWall: Wall) {
//        self.wall = newWall
//        tableview.reloadData()
//    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? SettingAnnouncementViewController{
            destination.dailyWall = self.selected_dailywall
            destination.goalID = self.wall?.goalID
        }
    }
    

}
