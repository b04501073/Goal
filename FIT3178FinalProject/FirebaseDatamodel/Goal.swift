//
//  Goal.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/24.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase

class Goal: NSObject, Codable{
    var id: String!
    var title: String!
    var startDate: Firebase.Timestamp!
    var endDate: Firebase.Timestamp!
    var frequency: String!
    var manager: String!
    var participants: [DocumentReference]!
    
    enum CodingKeys: String, CodingKey{
        case id
        case title
        case startDate
        case endDate
        case frequency
        case manager
//        case category
        case participants
    }
}

