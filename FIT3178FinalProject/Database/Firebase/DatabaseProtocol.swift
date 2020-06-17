//
//  DatabaseProtocol.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/24.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import UIKit
import Firebase


protocol DatabaseProtocol: AnyObject {
    
    func setUpListener_on_ParticipatingGoals(add_item_tolist: @escaping (Goal) -> Void, remove_list: @escaping () -> Void) -> ListenerRegistration?
    func setUpListener_on_ManagingGoals(add_item_tolist: @escaping (Goal) -> Void, remove_list: @escaping () -> Void) -> ListenerRegistration?
    func setUpListener_on_SelectedDailyWall(goalID: String, selecteddate: Dateunit, add_item_tolist: @escaping (Post) -> Void, add_announcement_tolist: @escaping (Post) -> Void , remove_list: @escaping () -> Void) -> ListenerRegistration?
    
    func user_create_goal(title: String, startDate: Date, endDate: Date, frequency: String, successfully_callback: @escaping () -> Void, failed_callback: @escaping () -> Void)
    
    func user_add_participating_goal(goalID: String, complete_callback: @escaping () -> Void, failed_callback: @escaping () -> Void)
    
    func remove_participating_goal(goalID: String)
    func remove_managing_goal(goalID: String)
    
    func createPost(selected_date: Dateunit, content: String, image: UIImage?, goalID: String, isannouncement: Bool, succesful_callback: @escaping () -> Void, failed_callback: @escaping () -> Void)
    func setUpListener_on_SelectedWall(goalID: String, setNewWall_callback: @escaping (Wall) -> Void) -> ListenerRegistration?
    
    func fetch_user(fetch_userid: String, callback: @escaping (_ nickname: String) -> Void)
    
    func getUserID() -> String
    
    func search_goal(by goalName: String, complete_callback: @escaping ([Goal]) -> Void)
}
