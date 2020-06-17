//
//  SearchGoalViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/25.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class SearchGoalViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{

    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var tableView: UITableView!
    var indicator = UIActivityIndicatorView()
    var searchResult_goals = [Goal]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for cocktail"
        navigationItem.searchController = searchController
        // Make sure search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Create a loading animation
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResult_goals.removeAll()
        self.tableView.reloadData()
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.clear
        
        databaseController?.search_goal(by: searchText, complete_callback: {
            searchingResults in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            self.searchResult_goals = searchingResults
            self.tableView.reloadData()
        })
    }
    func found_add_goal(){
        navigationController?.popViewController(animated: true)
    }
    func failed_to_find(){
        let controller = UIAlertController(title: "Search Error", message: "Failed to join the goal, please try it again!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResult_goals.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell", for: indexPath)
        let current_goal = searchResult_goals[indexPath.section]
        if let title_label = cell.contentView.subviews[0] as? UILabel{
            title_label.text = current_goal.title
        }
        if let participants_label = cell.contentView.subviews[1] as? UILabel{
            participants_label.text = "\(current_goal.participants.count) participant(s)!"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected_goal = searchResult_goals[indexPath.section]
        let controller = UIAlertController(title: "Participate a new goal", message: "Please confirm to join this goal!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            _ in
            self.databaseController?.user_add_participating_goal(goalID: selected_goal.id, complete_callback: {
                self.found_add_goal()
            }, failed_callback: {
                self.failed_to_find()
            })
        })
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
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
