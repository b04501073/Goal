//
//  Wger_DateModel.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/5.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class CategoryVolume: NSObject, Decodable{
    var results: [Category]
}

class Category: NSObject, Decodable{
    var id: Int!
    var name: String!
}

class ExcerciseVolume: NSObject, Decodable{
    var results: [Excercise]
}

class Excercise: NSObject, Decodable{
    var content: String!
    
    private enum CodingKeys: String, CodingKey {
        case content = "description"
    }
}
