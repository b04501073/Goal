//
//  PostWithImageTableViewCell.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/16.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: UITableViewCell {
    @IBOutlet weak var contentlabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var userlabel: UILabel!
    @IBOutlet weak var announcementIcon: UIButton!
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//    func loadimg(url: URL){
//
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            DispatchQueue.main.async() {
//                if let image = UIImage(data: data){
////                    self.imageView?.contentMode = .scaleAspectFill
//                    let screenWidth = self.frame.size.width
//                    let ratio = screenWidth / image.size.width
//                    self.imageView!.frame.size = CGSize(width: ratio * image.size.width, height: ratio * image.size.height)
//                    self.imageView?.image = image
//                    self.imageView!.contentMode = .scaleAspectFill
//                }
//            }
//        }
//    }

}
