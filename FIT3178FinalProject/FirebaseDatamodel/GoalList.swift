//
//  GoalList.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/24.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase

class GoalList: NSObject, Codable{
    var id: String!
    var userid: String!
    var participating_goals = [DocumentReference]()
    var managing_goals = [DocumentReference]()
    
    enum CodingKeys: String, CodingKey{
        case userid
        case participating_goals
        case managing_goals
    }
    
//    required init(from decoder: Decoder) throws {
//        participating_goals = []
//        managing_goals = []
//        let rootcontainer = try decoder.container(keyedBy: CodingKeys.self)
//        
//        userid = try rootcontainer.decode(String, forKey: .userid)
//        participating_goals = try rootcontainer.decode([Goal], forKey: .userid)
//        managing_goals = try rootcontainer.decode([Goal], forKey: .userid)
//    }
//    override init() {
//        participating_goals = []
//        managing_goals = []
//    }
}
