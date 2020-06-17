//
//  class DateCollectionViewCell: UICollectionViewCell {     @IBOutlet weak var datelabel: UILabel! DateCollectionViewCell.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/23.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var goalsonthatdate: UILabel!
    @IBOutlet weak var goalstableview: DailyDetailsTableview!
    var date: Dateunit?
    var goals: [Goal]?
    
}
