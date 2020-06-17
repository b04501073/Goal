//
//  DateDelegate.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/23.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation

struct Dateunit: Equatable{
    var year: Int!
    var month: Int!
    var date: Int!
    static func == (lhs: Dateunit, rhs: Dateunit) -> Bool {
        return
            lhs.year == rhs.year &&
            lhs.month == rhs.month &&
            lhs.date == rhs.date
    }
}

protocol DateDelegate {
    func getDate() -> Dateunit
}
