//
//  Todo+CoreDataProperties.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/7.
//  Copyright © 2020 李利元. All rights reserved.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var title: String?

}
