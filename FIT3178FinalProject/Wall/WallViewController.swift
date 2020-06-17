//
//  WallViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/29.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Firebase

class WallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var date: Dateunit! //essensial
    var goal: Goal!     //essensial
    var posts = [Post]()
    var announcement: Post?
    var listener: ListenerRegistration?
    var cachedImages = [URL: UIImage]()
    
    @IBOutlet weak var titlelabel: UILabel!
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var posts_tableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlelabel.text = goal.title
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        posts_tableview.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listener = databaseController?.setUpListener_on_SelectedDailyWall(goalID: self.goal.id, selecteddate: date, add_item_tolist: {
            post in
            self.posts.append(post)
            self.posts_tableview.reloadData()
        }, add_announcement_tolist: {
            announcement in
            self.announcement = announcement
        }, remove_list: {
            self.posts.removeAll()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if announcement != nil{
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if announcement != nil && section == 0{
            return 1
        }
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        var post: Post!
        var isAnnouncement = false
        if announcement != nil && indexPath.section == 0{
            post = announcement!
            isAnnouncement = true
        } else{
            post = posts[indexPath.row]
        }
        
        if let imageurl = post.imageurl{
            cell = posts_tableview.dequeueReusableCell(withIdentifier: "postcell_withimage", for: indexPath)
            if let postcell = cell as? PostWithImageTableViewCell{
                if let content = post.content{
                    postcell.contentlabel.numberOfLines = calculateMaxLines(label: postcell.contentlabel, text: content)
                    postcell.contentlabel.text = content
                    databaseController?.fetch_user(fetch_userid: post.userid, callback:{
                        nickname in
                        postcell.userlabel.text = nickname
                    })
                }
                if let image = cachedImages[URL(string: imageurl)!]{
//                    postcell.imageview.image = image
                    //adjust the size of the image
                    let screenWidth = self.view.frame.width
                    let ratio = screenWidth / image.size.width
                    
                    if postcell.imageview.constraints.count > 0{
                        postcell.imageview.constraints[0].isActive = false
                    }
                    
                    postcell.imageview.frame.size = CGSize(width: ratio * image.size.width, height: ratio * image.size.height)
                    postcell.imageview.image = image
                    postcell.imageview.translatesAutoresizingMaskIntoConstraints = true
                    postcell.imageview.contentMode = .scaleAspectFill
                } else{
                    loadimg(cell: postcell, for: indexPath, url: URL(string: imageurl)!)
                }
                if isAnnouncement{
                    postcell.announcementIcon.isHidden = false
                }
                else{
                    postcell.announcementIcon.isHidden = true
                }
            }
        }else{
            cell = posts_tableview.dequeueReusableCell(withIdentifier: "postcell_withoutimage", for: indexPath)
            if let postcell = cell as? PostWithoutImageTableViewCell{
                if let content = post.content{
                    postcell.contentlabel.numberOfLines = calculateMaxLines(label: postcell.contentlabel, text: content)
                    postcell.contentlabel.text = content
                    databaseController?.fetch_user(fetch_userid: post.userid, callback:{
                        nickname in
                        postcell.userlabel.text = nickname
                    })
                }
                if isAnnouncement{
                    postcell.announcementIcon.isHidden = false
                }
                else{
                    postcell.announcementIcon.isHidden = true
                }
            }
        }
//        if announcement != nil && indexPath.section == 0{
//            cell.backgroundColor = .lightGray
//        }
        return cell
    }
    
    
    func calculateMaxLines(label: UILabel, text: String) -> Int {
        let maxSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
        let charSize = label.font.lineHeight
        let text = text as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func loadimg(cell: PostWithImageTableViewCell, for indexpath: IndexPath, url: URL){
        
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                if let image = UIImage(data: data){
                    self.cachedImages[url] = image
                    self.posts_tableview.beginUpdates()
                    self.posts_tableview.reloadRows(at: [indexpath], with: .fade)
                    self.posts_tableview.endUpdates()
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "createnewpost"){
            if let des = segue.destination as? CreatePostViewController{
                des.goal = self.goal
                des.selecteddate = self.date
            }
        }
    }
    

}
