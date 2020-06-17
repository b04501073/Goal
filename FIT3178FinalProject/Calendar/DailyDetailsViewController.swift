//
//  DailyDetailsViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/29.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class DailyDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var goalListtableview: UITableView!
    
    var dateunit: Dateunit!
    var goals = [Goal]()
    let goalcellIdentifier = "goalcell"
    var selected_goal: Goal?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        datelabel.text = "\(dateunit.month!)/\(dateunit.date!)"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: goalcellIdentifier, for: indexPath)
        if let titlelabel = cell.contentView.subviews[0] as? UILabel{
            titlelabel.text = goals[indexPath.row].title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_goal = goals[indexPath.row]
        performSegue(withIdentifier: "to_wall", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_wall"{
            if let des = segue.destination as? WallViewController{
                des.goal = selected_goal!
                des.date = self.dateunit
            }
        }
    }
    

}
