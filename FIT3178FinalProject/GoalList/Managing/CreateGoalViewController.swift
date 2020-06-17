//
//  CreateGoalViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/25.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class CreateGoalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let frequency_components = ["Everyday", "Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
    weak var databaseController: DatabaseProtocol?
    private var startDatePicker: UIDatePicker?
    private var endDatePicker: UIDatePicker?
    private var frequencyPicker: UIPickerView?
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startdateTextField: UITextField!
    @IBOutlet weak var enddateTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    
    private var startDate: Date?
    private var endDate: Date?
    
    var frequency_picker_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        
        
        startDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .date
        startdateTextField.inputView = startDatePicker
        startdateTextField.tintColor = .clear
        startDatePicker?.addTarget(self, action: #selector(startDateDidChanged(datePicker:)), for: .valueChanged)
        
        endDatePicker = UIDatePicker()
        endDatePicker?.datePickerMode = .date
        enddateTextField.inputView = endDatePicker
        enddateTextField.tintColor = .clear
        endDatePicker?.addTarget(self, action: #selector(endDateDidChanged(datePicker:)), for: .valueChanged)
        
        frequencyPicker = UIPickerView()
        frequencyTextField.inputView = frequencyPicker
        frequencyTextField.tintColor = .clear
        frequencyPicker?.delegate = self
        frequencyPicker?.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        if startdateTextField.isEditing{
            startDate = startDatePicker?.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            startdateTextField.text = dateFormatter.string(from: startDate!)
            endDatePicker?.minimumDate = startDate
            view.endEditing(true)
        }
        else if enddateTextField.isEditing{
            endDate = endDatePicker?.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            enddateTextField.text = dateFormatter.string(from: endDate!)
            startDatePicker?.maximumDate = endDate
            view.endEditing(true)
        }
        else if frequencyTextField.isEditing{
            frequencyTextField.text = frequency_components[frequency_picker_index]
            view.endEditing(true)
        }
        else if titleTextField.isEditing{
            view.endEditing(true)
        }
    }
    
    @objc func startDateDidChanged(datePicker: UIDatePicker){
        startDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startdateTextField.text = dateFormatter.string(from: startDate!)
    }
    
    @objc func endDateDidChanged(datePicker: UIDatePicker){
        endDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        enddateTextField.text = dateFormatter.string(from: endDate!)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequency_components.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequency_components[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frequency_picker_index = row
        frequencyTextField.text = frequency_components[frequency_picker_index]
    }
    
    @IBAction func createGoal(){
        if titleTextField.text != "", startDate != nil, endDate != nil{
            let title = titleTextField.text!
            let frequency_selected = frequency_components[frequency_picker_index]
            databaseController?.user_create_goal(title: title, startDate: startDate!, endDate: endDate!, frequency: frequency_selected, successfully_callback: {
                self.Goal_Created()
            }, failed_callback: {
                self.Goal_failed_to_Create()
            })
        }
        
    }
    
    func Goal_Created(){
        navigationController?.popViewController(animated: true)
    }
    
    func Goal_failed_to_Create(){
        let controller = UIAlertController(title: "Create Goal error", message: "Please try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
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
