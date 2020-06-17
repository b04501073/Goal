//
//  TodoViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/2.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController, CoreDataListener, UITableViewDelegate, UITableViewDataSource{
    
    weak var coredataController: CoreDataProtocol?
    @IBOutlet weak var todo_tableview: UITableView!
    var todos: [Todo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        coredataController = appDelegate.coredataController
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coredataController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coredataController?.removeListener(listener: self)
    }

    func onTodoListChange(todos: [Todo]) {
        self.todos = todos
        todo_tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.todos?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (self.todos?.count ?? 0){
            return tableView.dequeueReusableCell(withIdentifier: "additemcell", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "todocell", for: indexPath)
        if let title_label = cell.contentView.subviews[0] as? UILabel{
            title_label.text = self.todos?[indexPath.row].title!
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let deleted_todo = self.todos![indexPath.row]
            coredataController?.deleteTodoItem(item: deleted_todo)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
