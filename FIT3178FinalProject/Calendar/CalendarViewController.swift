//
//  CalendarViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/23.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Firebase

private let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var monthsections: [SectionUnit]!
    var current_year: Int!
    var current_month: Int!
    let size_of_buffer = 7
    
    var personalgoals = [Goal]()
    var goals_on_date: [Date: [Goal]] = [:]
    var listener: ListenerRegistration? = nil
    weak var databaseController: DatabaseProtocol?
    var selectedcell: DateCollectionViewCell?
    
//    var updatemonthcell: IndexPath?
    var updatedMonth: Dateunit!
    
    var screenHeight: CGFloat!
    
    //for to_wall segue
    var selected_goal: Goal!
    var selected_date: Dateunit!
    
//    var offset: CGFloat!
    
    @IBOutlet weak var calendar_tableview: UITableView!
    
    var adjusting_offset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        screenHeight = window.frame.height - topPadding - bottomPadding - 100
        uploadDate()
    }
    
    override func viewDidLayoutSubviews() {
        self.calendar_tableview.delegate = self
        calendar_tableview.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: false)
    }
    
    func uploadDate(){
        let date = Date()
        let calendar = Calendar.current
        current_year = calendar.component(.year, from: date)
        current_month = calendar.component(.month, from: date)
        updateSections()
    }
    
    func updateSections(){
        self.monthsections = []
        for i in -3...3{
            monthsections.append(SectionUnit(month: current_month + i, year: current_year))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return size_of_buffer
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("loading \(indexPath.section)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "month_cell", for: indexPath)
        if let month_label = cell.contentView.subviews[0] as? UILabel{
            if monthsections[indexPath.section].month! == 1{
                month_label.text = "\(monthsections[indexPath.section].year!)\n\(months[monthsections[indexPath.section].month! - 1])"
                month_label.numberOfLines = 2
            } else{
                month_label.text = months[monthsections[indexPath.section].month! - 1]
            }
            
        }
        if let month_collectionview = cell.contentView.subviews[1] as? MonthUICollectionView{
            month_collectionview.set_getgoals_callback(callback: {
                dateunit in
                return self.getGoalsonDate(date: dateunit)
            })
            month_collectionview.set_press_goal_callback(callback: {
                date, goal in
                self.toWallSegue(date: date, goal: goal)
            })
            month_collectionview.set_datecell_willExpand_callback(callback: {
                datecell, date in
                self.datecell_WillExpand(datecell: datecell, date: date)
            })
            month_collectionview.set_datecell_didExpand_callback(callback: {
                datecell, date in
                self.datecell_DidExpand(datecell: datecell, date: date)
            })
            month_collectionview.set_datecell_didClose_callback(callback: {
                datecell in
                self.datecell_DidClose(datecell: datecell)
            })
            month_collectionview.dataSource = month_collectionview
            month_collectionview.delegate = month_collectionview
            month_collectionview.month_section_unit = monthsections[indexPath.section]
            month_collectionview.setOffset()//must be called for initializing the parameters
            month_collectionview.reloadData()
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = monthsections[indexPath.section]
        
        let dateComponents = DateComponents(year: section.year, month: section.month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let offset = Calendar.current.component(.weekday, from: date) - 1
        let numDays = range.count + offset
        let row = ceil(Double(numDays) / Double(7))
        
        if updatedMonth != nil && section.month == updatedMonth.month{
            if section.month == 1{
                return CGFloat((row + 1) * 100 + 150) + screenHeight
            }
            return CGFloat((row + 1) * 100 + 90) + screenHeight
        }
        
        if section.month == 1{
            return CGFloat(row * 100 + 150)
        }
        return CGFloat(row * 100 + 90)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //for dectecting the current scrollview in order to update month sections
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if scrollView.contentOffset.y == 0{
            current_year = self.monthsections.first?.year
            current_month = self.monthsections.first?.month
            updateSections()
            calendar_tableview.reloadData()
            calendar_tableview.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: false)
        } else if distanceFromBottom > 0 && distanceFromBottom == height {
            current_year = self.monthsections.last?.year
            current_month = self.monthsections.last?.month
            updateSections()
            calendar_tableview.reloadData()
            calendar_tableview.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
        }
    }
    
    func getGoalsonDate(date: Dateunit) -> [Goal]?{
        var thisdate = DateComponents(year: date.year, month: date.month, day: date.date)
        thisdate.calendar = Calendar.current
        return goals_on_date[thisdate.date!]
    }
    
    func datecell_WillExpand(datecell: UICollectionViewCell, date: Dateunit){
        //Expand the month tableview cell so the month collection view can have enough space to expand
        self.updatedMonth = date
        self.calendar_tableview.isScrollEnabled = false
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
            self.calendar_tableview.beginUpdates()
            self.calendar_tableview.endUpdates()
        })
    }
    
    func datecell_DidExpand(datecell: UICollectionViewCell, date: Dateunit){
        //Expand the month tableview cell so the month collection view can have enough space to expand
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
            self.calendar_tableview.contentOffset.y += (datecell.convert(CGPoint.zero, to: self.calendar_tableview).y - self.calendar_tableview.contentOffset.y)
        })
    }
    
//    func datecell_WillClose(date: MonthUICollectionView){
////        self.updatemonthcell = nil
////        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
////            self.calendar_tableview.beginUpdates()
////            self.calendar_tableview.endUpdates()
////        })
//    }
    
    func datecell_DidClose(datecell: UICollectionViewCell){
        self.updatedMonth = nil
        self.calendar_tableview.isScrollEnabled = true
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
            self.calendar_tableview.beginUpdates()
            self.calendar_tableview.endUpdates()
            
        }, completion:{
            _ in
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, animations: {
//                self.calendar_tableview.contentOffset.y += (datecell.convert(CGPoint.zero, to: self.calendar_tableview).y - self.calendar_tableview.contentOffset.y - self.calendar_tableview.frame.size.height / 2)
//
//            })
        })
    }
    
    func toWallSegue(date: Dateunit, goal: Goal){
        self.selected_goal = goal
        self.selected_date = date
        performSegue(withIdentifier: "to_wall", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_wall"{
            if let des = segue.destination as? WallViewController{
                des.date = self.selected_date
                des.goal = self.selected_goal
            }
        }
        if segue.identifier == "todetails"{
            if let des = segue.destination as? DailyDetailsViewController{
                if let cell = self.selectedcell{
                    des.dateunit = cell.date
                    des.goals = cell.goals ?? [Goal]()
                }
            }
        }
    }
}


struct SectionUnit {
    var month: Int!
    var year: Int!
    init(month: Int, year: Int){
        self.month = month
        self.year = year
        
        if self.month <= 0{
            self.month += 12
            self.year -= 1
        }
        else if self.month > 12{
            self.month -= 12
            self.year += 1
        }
    }
}
