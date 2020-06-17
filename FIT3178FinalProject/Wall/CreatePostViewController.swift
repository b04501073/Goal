//
//  CreatePostViewController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/30.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{
    
    var selecteddate: Dateunit!
    var goal: Goal!
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contenttextfield: UITextView!
    @IBOutlet weak var uploadbtn: UIButton!
    @IBOutlet weak var modeselector: UISegmentedControl!
    private var textEdited = true
    private var imgUploaded = false
    
    @IBAction func uploadBtnAction(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "Upload Images", message: "Select the images for uploading", preferredStyle: .actionSheet)
        
        let imageFromLibAction = UIAlertAction(title: "Photo Album", style: .default) { (Void) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "Camera", style: .default) { (Void) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.firebaseController
        
        if goal.manager == databaseController?.getUserID(){
            modeselector.isHidden = false
        } else{
            modeselector.isHidden = true
        }
        
        let newSize = CGSize(width: CGFloat(50), height: CGFloat(50))
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        imageView.image?.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = newImage
        imageView.contentMode = .center
        
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(uploadBtnAction(sender:)))
        self.imageView.addGestureRecognizer(tapImageGesture)
        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if let data = image.jpegData(compressionQuality: 0.2){
            self.imageView.image = UIImage(data: data)
            self.imageView.contentMode = .scaleAspectFit
            imgUploaded = true
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func uploadPost(_ sender: UIButton) {
        uploadbtn.isEnabled = false
        if let content = contenttextfield.text{
            if modeselector.isHidden == false && modeselector.selectedSegmentIndex == 0{
                if !imgUploaded{
                    databaseController?.createPost(selected_date: selecteddate, content: content, image: nil, goalID: goal.id, isannouncement: true, succesful_callback: {
                        self.sucessfullyAdded()
                    }, failed_callback: {
                        self.failedAdded()
                    })
                } else{
                    databaseController?.createPost(selected_date: selecteddate, content: content, image: self.imageView.image, goalID: goal.id, isannouncement: true, succesful_callback: {
                        self.sucessfullyAdded()
                    }, failed_callback: {
                        self.failedAdded()
                    })
                }
                
            }
            else{
                if !imgUploaded{
                    databaseController?.createPost(selected_date: selecteddate, content: content, image: nil, goalID: goal.id, isannouncement: false, succesful_callback: {
                        self.sucessfullyAdded()
                    }, failed_callback: {
                        self.failedAdded()
                    })
                } else{
                    databaseController?.createPost(selected_date: selecteddate, content: content, image: self.imageView.image, goalID: goal.id, isannouncement: false, succesful_callback: {
                        self.sucessfullyAdded()
                    }, failed_callback: {
                        self.failedAdded()
                    })
                }
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Write caption here..."
            textEdited = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textEdited{
            textView.text = ""
            textEdited = false
        }
    }
    
    func sucessfullyAdded() {
        navigationController?.popViewController(animated: true)
    }
    
    func failedAdded() {
        uploadbtn.isEnabled = true
        print("failed to add a post")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
