//
//  User.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/5.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation

class User: NSObject, Codable{
    var nickname: String!
    enum CodingKeys: String, CodingKey{
        case nickname
    }
}
