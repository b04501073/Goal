//
//  Monthe_collectionview.swift
//  calendar
//
//  Created by 李利元 on 2020/6/6.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import UIKit

class MonthUICollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource{
    
    var month_section_unit: SectionUnit!    // a unit record the current showing month and year
    var offset: Int!                        // empty datecells before the first day of a month
    var numberofDays: Int!
//    var parent_tableview_cell: UITableViewCell!
    
    var getgoals_callback: ((Dateunit) -> [Goal]?)!
//    var datecell_pressed_callback: ((DateCollectionViewCell) -> Void)!
    var press_goal_callback: ((Dateunit, Goal) -> Void)!
    
    var datecell_willExpand_callback: ((UICollectionViewCell, Dateunit) -> Void)!
    var datecell_didExpand_callback: ((UICollectionViewCell, Dateunit) -> Void)!
//    var datecell_willClose_callback: ((Dateunit) -> Void)!
    var datecell_didClose_callback: ((UICollectionViewCell) -> Void)!
    
    var selected_goals: [Goal]?
    var selected_date: Dateunit?

    
    func setOffset(){
        let dateComponents = DateComponents(year: month_section_unit.year, month: month_section_unit.month)
        let thisdate = Calendar.current.date(from: dateComponents)!
        offset = daysOffset(date: thisdate)
        numberofDays = numberOfDaysInThisMonth(date: thisdate)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offset + numberofDays
    }
    
    func set_getgoals_callback(callback: @escaping (Dateunit) -> [Goal]?){
        self.getgoals_callback = callback
    }
    
//    func set_datecell_pressed_callback(callback: @escaping (DateCollectionViewCell) -> Void){
//        self.datecell_pressed_callback = callback
//    }
    
    func set_press_goal_callback(callback: @escaping (Dateunit, Goal) -> Void){
        self.press_goal_callback = callback
    }
    
    func set_datecell_willExpand_callback(callback: @escaping (UICollectionViewCell, Dateunit) -> Void){
        self.datecell_willExpand_callback = callback
    }
    
    func set_datecell_didExpand_callback(callback: @escaping (UICollectionViewCell, Dateunit) -> Void){
        self.datecell_didExpand_callback = callback
    }
    
//    func set_datecell_willClose_callback(callback: @escaping (Dateunit) -> Void){
//        self.datecell_willClose_callback = callback
//    }
    
    func set_datecell_didClose_callback(callback: @escaping (UICollectionViewCell) -> Void){
        self.datecell_didClose_callback = callback
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath)
        if let date_cell = cell as? DateCollectionViewCell{
            if indexPath.row < offset{ // empty cells
                date_cell.datelabel.text = ""
                date_cell.goalsonthatdate.text = ""
                date_cell.backgroundColor = .none
                date_cell.goalstableview.isHidden = true
                return date_cell
            } else{
                date_cell.date = Dateunit(year: month_section_unit.year, month: month_section_unit.month, date: indexPath.row - offset + 1)
                date_cell.goals = getgoals_callback(date_cell.date!)
                date_cell.datelabel.text = "\(indexPath.row - offset + 1)"
                
                date_cell.datelabel.font = date_cell.datelabel.font.withSize(21)
                date_cell.layer.cornerRadius = 8
                date_cell.backgroundColor = .darkGray
                date_cell.goalstableview.isHidden = true
                
                if let goals = date_cell.goals{
                    //selected datecell fro more details
                    if date_cell.date == selected_date, let goals = self.selected_goals{
                        date_cell.datelabel.font = date_cell.datelabel.font.withSize(50)
                        date_cell.goalsonthatdate.text = ""
                        if let tableview_for_goals = date_cell.goalstableview{
                            tableview_for_goals.goals = goals
                            tableview_for_goals.isHidden = false
                            tableview_for_goals.reloadData()
                        }
                    }
                    else{
                        if goals.count == 1{
                            date_cell.goalsonthatdate.text = "\(date_cell.goals!.count)task"
                        } else{
                            date_cell.goalsonthatdate.text = "\(date_cell.goals!.count)tasks"
                        }
                    }
                }
                else{
                    date_cell.goalsonthatdate.text = ""
                }
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selected_cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell{
            //expand a cell
            if let _ = selected_cell.goals{
                if selected_date == nil{
                    self.selected_goals = selected_cell.goals!
                    self.selected_date = selected_cell.date
                    self.datecell_willExpand_callback(selected_cell, selected_cell.date!)
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, animations: {
                        self.performBatchUpdates({
                            self.reloadItems(at: [indexPath])
                        })
                        
                    }, completion: {
                        _ in
                        if let fetchedCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell{
                            if fetchedCell.date == self.selected_date{
                                self.datecell_didExpand_callback(fetchedCell, self.selected_date!)
                            }
                            // unexpected error would occur if pass the previous fetched collectionview, so additional fetch has to be executed here
                        }
                        
                        
                    })
                }
                //close a cell
                else{
                    self.selected_goals = nil
                    self.selected_date = nil
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
                        self.performBatchUpdates({
                            self.reloadItems(at: [indexPath])
                        })
                    }, completion: {
                        _ in
                        if let fetchedCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell{
                            // unexpected error would occur if pass the previous fetched collectionview, so additional fetch has to be executed here
                            self.datecell_didClose_callback(fetchedCell)
                        }
                        
                    })
                }
            } else if selected_date != nil, selected_cell.date == selected_date!{
                //close a cell
                self.selected_goals = nil
                self.selected_date = nil
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.01, delay: 0, animations: {
                    self.performBatchUpdates({
                        self.reloadItems(at: [indexPath])
                    })
                }, completion: {
                    _ in
                    if let fetchedCell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell{
                        // unexpected error would occur if pass the previous fetched collectionview, so additional fetch has to be executed here
                        self.datecell_didClose_callback(fetchedCell)
                    }
                })
            }
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(collectionView.frame.size.width / 9)
//        if let selected_cell = collectionView.cellForItem(at: indexPath) as? DateCollectionViewCell, let date = self.selected_date{
//            if selected_cell.date == date{
//                let window = UIApplication.shared.windows[0]
//                let topPadding = window.safeAreaInsets.top
//                let bottomPadding = window.safeAreaInsets.bottom
//                let screenHeight = window.frame.height - topPadding - bottomPadding - 100
//                return CGSize(width: collectionView.frame.size.width, height: screenHeight)
//            }
//        } else
        if (indexPath.row - offset + 1) == self.selected_date?.date{
            let window = UIApplication.shared.windows[0]
            let topPadding = window.safeAreaInsets.top
            let bottomPadding = window.safeAreaInsets.bottom
            let screenHeight = window.frame.height - topPadding - bottomPadding - 100
            return CGSize(width: collectionView.frame.size.width, height: screenHeight)
        }
        return CGSize(width: width, height: 90)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selected_goals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "daily_goalcell")
        if let titlelabel = cell!.contentView.subviews[0] as? UILabel{
            titlelabel.text = selected_goals?[indexPath.section].title ?? "error"
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected_goal = selected_goals![indexPath.section]
        self.press_goal_callback(self.selected_date!, selected_goal)
        
    }
    
    
    func whatDayIsIt(_ date: Date) -> Int{
        return Calendar.current.component(.weekday, from: date)
    }
    
    func daysOffset(date: Date) -> Int{
        return whatDayIsIt(date) - 1
    }
    
    func numberOfDaysInThisMonth(date: Date) -> Int{
        let range = Calendar.current.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
}
