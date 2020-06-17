//
//  Calendar_display.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/28.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation

//handling the data communications with firebase controller
extension CalendarViewController{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listener = databaseController?.setUpListener_on_ParticipatingGoals(add_item_tolist: {
            newgoal in
            self.personalgoals.append(newgoal)
            self.convert_to_date(goal: newgoal)
            self.calendar_tableview.reloadData()
        }, remove_list: {
            self.personalgoals.removeAll()
            self.goals_on_date.removeAll()
            self.calendar_tableview.reloadData()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }
    
    
    func whatDayIsIt(_ date: Date) -> Int{
        return Calendar.current.component(.weekday, from: date)
    }
    
    func convert_to_date(goal: Goal){
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        var date = goal.startDate.dateValue()
        let endDate = goal.endDate.dateValue()
        
        var frequency = 0
        
        switch goal.frequency {
        case "Every Monday":
            frequency = 2
        case "Every Tuesday":
            frequency = 3
        case "Every Wednesday":
            frequency = 4
        case "Every Thursday":
            frequency = 5
        case "Every Friday":
            frequency = 6
        case "Every Saturday":
            frequency = 7
        case "Every Sunday":
            frequency = 1
            
        default:
            frequency = 0
        }
        
        while date <= endDate {
            if (frequency == 0 || whatDayIsIt(date) == frequency){
                if let date_key = fmt.date(from: fmt.string(from: date)){
                    if self.goals_on_date[date_key] == nil{
                        goals_on_date[date_key] = []
                        goals_on_date[date_key]!.append(goal)
                    }else{
                        goals_on_date[date_key]!.append(goal)
                    }
                }
                
            }
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
    }
}
