//
//  GoallistViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/24.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Firebase

class GoallistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var tableview: UITableView!
    var selectedcell: IndexPath?
    
    var participating_goals = [Goal]()
    let dateFormatter = DateFormatter()
    var listener: ListenerRegistration? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listener = databaseController?.setUpListener_on_ParticipatingGoals(add_item_tolist: {
            newgoal in
            self.participating_goals.append(newgoal)
            self.tableview.reloadData()
        }, remove_list: {
            self.participating_goals.removeAll()
            self.tableview.reloadData()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return participating_goals.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == participating_goals.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "joinGoal_cell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalcell", for: indexPath)
        let goal = participating_goals[indexPath.section]
        if let title_label = cell.contentView.subviews[0] as? UILabel{
            title_label.text = goal.title
        }
        if let startdate_label = cell.contentView.subviews[1] as? UILabel{
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let startdatestr = dateFormatter.string(from: goal.startDate.dateValue())
            let enddatestr = dateFormatter.string(from: goal.endDate.dateValue())
            startdate_label.text = "\(startdatestr) - \(enddatestr)"
                
        }
        if let frequency_label = cell.contentView.subviews[2] as? UILabel{
            frequency_label.text = goal.frequency
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.remove_participating_goal(goalID: participating_goals[indexPath.section].id)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(2)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == participating_goals.count{
            tableView.cellForRow(at: indexPath)?.selectionStyle = .none
            performSegue(withIdentifier: "joinGoal", sender: nil)
            return
        }
        else if selectedcell != nil{
            tableView.cellForRow(at: indexPath)?.selectionStyle = .none
            if selectedcell == indexPath{
                selectedcell = nil
            }else{
                selectedcell = indexPath
            }
        } else{
            selectedcell = indexPath
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedcell != nil && selectedcell == indexPath{
            return CGFloat(100)
        }
        return CGFloat(43.5)
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
