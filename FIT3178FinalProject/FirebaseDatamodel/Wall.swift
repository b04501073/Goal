//
//  Wall.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/29.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase

class Wall: NSObject, Codable{
    var id: String!
    var goalID: String!
    var dailywalls: [DailyWall]
    
    override init() {
        dailywalls = []
    }
    
    required init(from decoder: Decoder) throws {
        let rootcontainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dailywalls = []
        self.goalID = try? rootcontainer.decode(String.self, forKey: .goalID)
        if let dailywallreferences = try? rootcontainer.decode([DocumentReference].self, forKey: .dailywalls){
            for dailywallref in dailywallreferences{
                let temp_dailywall = DailyWall()
                self.dailywalls.append(temp_dailywall)
                wall_data_fetcher.fetch_referenc(reference: dailywallref, decode_type: DailyWall.self, return_obj: temp_dailywall)
            }
        }
        
    }
    
    enum CodingKeys: String, CodingKey{
        case goalID
        case dailywalls
    }
}

class DailyWall: NSObject, Codable, Return_obj{
    
    var id: String!
    var posts: [Post]
    var announcement: Post?
    var date: String!
    override init() {
        posts = []
    }
    required init(from decoder: Decoder) throws {
        posts = []
        announcement = Post()
        let rootcontainer = try decoder.container(keyedBy: CodingKeys.self)
        
        if let announcementref = try? rootcontainer.decode(DocumentReference.self, forKey: .announcement){
            wall_data_fetcher.fetch_referenc(reference: announcementref, decode_type: Post.self, return_obj: announcement!)
        }
        self.date = try? rootcontainer.decode(String.self, forKey: .date)
        
    }
    
    func setupObj(returnobj: Codable) {
        let newdailywall = returnobj as! DailyWall
        self.id = newdailywall.id
        self.posts = newdailywall.posts
        self.announcement = newdailywall.announcement
        self.date = newdailywall.date
    }
    enum CodingKeys: String, CodingKey{
        case posts
        case announcement
        case date
    }
}
