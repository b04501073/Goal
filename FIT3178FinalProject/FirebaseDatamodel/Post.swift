//
//  Post.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/29.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase

class Post: NSObject, Codable, Return_obj{
    
    var userid: String!
    var posteddate: Firebase.Timestamp!
    var content: String!
    var imageurl: String?
    
    override init() {
        super.init()
    }
    func setupObj(returnobj: Codable) {
        let post = returnobj as! Post
        self.userid = post.userid
        self.posteddate = post.posteddate
        self.content = post.content
        self.imageurl = post.imageurl
    }
    enum CodingKeys: String, CodingKey{
        case userid
        case posteddate
        case content
        case imageurl
    }
}
