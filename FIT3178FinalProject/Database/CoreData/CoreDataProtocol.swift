//
//  CoreDateProtocol.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/7.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation

protocol CoreDataListener: AnyObject {
    func onTodoListChange(todos: [Todo])
}

protocol CoreDataProtocol: AnyObject {
    func cleanup()
    func addTodoItem(title: String) -> Todo
    func deleteTodoItem(item: Todo)
    func addListener(listener: CoreDataListener)
    func removeListener(listener: CoreDataListener)
}
