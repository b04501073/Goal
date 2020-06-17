//
//  AutoFillinViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/4.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class AutoFillinViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var categorypicker: UIPickerView!
    @IBOutlet weak var plantableview: UITableView!
    var categorylist: [Category]?
    var planlist: [Excercise]?
    var announcementDelegate: AnnouncementPropocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        
        fetchCategories()
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categorylist?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categorylist?[row].name
    }
    
    func fetchCategories(){
        let searchString = "https://wger.de/api/v2/exercisecategory/"
        let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: jsonURL!)
        { (data, response, error) in
            // Regardless of response end the loading icon from the main thread
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let catvolumeData = try decoder.decode(CategoryVolume.self, from: data!)
                
                self.categorylist = catvolumeData.results
                
                DispatchQueue.main.async {
                    self.categorypicker.reloadAllComponents()
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
    @IBAction func searchbtnpressed(){
        searchforplans()
    }
    
    func searchforplans(){
        if let selectedId = categorylist?[categorypicker.selectedRow(inComponent: 0)].id{
            let searchString = "https://wger.de/api/v2/exercise/?language=2&category=\(selectedId)"
            let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let task = URLSession.shared.dataTask(with: jsonURL!)
            { (data, response, error) in
                // Regardless of response end the loading icon from the main thread
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let planvolumeData = try decoder.decode(ExcerciseVolume.self, from: data!)
                    
                    self.planlist = planvolumeData.results
                    DispatchQueue.main.async {
                        self.plantableview.reloadData()
                    }
                    
                    
                } catch let err {
                    print(err)
                }
            }
            task.resume()
        } else{
            print("Failed to extract the selected category!")
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planlist?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plancell", for: indexPath)
        if let plan = planlist?[indexPath.row]{
            if let contentlable = cell.contentView.subviews[0] as? UILabel{
                contentlable.numberOfLines = calculateMaxLines(label: contentlable, text: plan.content)
                contentlable.text = plan.content
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected_plan = planlist?[indexPath.row]{
            announcementDelegate?.SetAnnouncement(content: selected_plan.content)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func calculateMaxLines(label: UILabel, text: String) -> Int {
        let maxSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
        let charSize = label.font.lineHeight
        let text = text as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
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
