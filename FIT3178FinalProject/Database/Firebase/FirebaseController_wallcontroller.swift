//
//  FirebaseController_wallcontroller.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/29.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

extension FirebaseController{
    
    func createPost(selected_date: Dateunit, content: String, image: UIImage?, goalID: String, isannouncement: Bool, succesful_callback: @escaping () -> Void, failed_callback: @escaping () -> Void){
        let post = Post()
        let date = UInt(Date().timeIntervalSince1970)
        
        let imageRef = storageReference?.child("\(goalID)/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        post.posteddate = Firebase.Timestamp(date: Date())
        post.userid = self.userid
        post.content = content
        
        //upload image
        if let upload_image = image{
            imageRef?.putData(upload_image.jpegData(compressionQuality: 1)!, metadata: metadata) { (meta, error) in
                if error != nil {
                    print("Could not upload image to firebase", "Error")
                } else {
                    imageRef?.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Download URL not found")
                            return
                        }
                        
                        post.imageurl = "\(downloadURL)"
                        //                        self.addPost_to_Walls(post: post, goalID: goalID, sender: sender, date: selected_date, isannouncement: isannouncement)
                        print("Image uploaded to Firebase", "Success")
                        do{
                            let newpostRef = try self.database.collection("posts").addDocument(from: post)
                            self.addPost_to_DailyWall(postRef: newpostRef, goalID: goalID, successful_callback: succesful_callback, failed_callback: failed_callback, date: selected_date, isannouncement: isannouncement)
                        }
                        catch{
                            print("Failed to create a new post/announcement!")
                            failed_callback()
                        }
                    }
                }
            }
        } else{
            do{
                let newpostRef = try database.collection("posts").addDocument(from: post)
                self.addPost_to_DailyWall(postRef: newpostRef, goalID: goalID, successful_callback: succesful_callback, failed_callback: failed_callback, date: selected_date, isannouncement: isannouncement)
            }
            catch{
                print("Failed to create a new post/announcement!")
                failed_callback()
            }
        }
        
        
    }
    
    func addPost_to_DailyWall(postRef: DocumentReference, goalID: String, successful_callback: @escaping () -> Void, failed_callback: @escaping () -> Void, date: Dateunit, isannouncement: Bool){
        
        //add the reference to the dailywall
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.year = date.year
        dateComponents.month = date.month
        dateComponents.day = date.date
        
        let daily_wall_ID = "\(goalID)_\(dateFormatter.string(from: dateComponents.date!))"
        let dailywallRef = database.collection("dailywalls").document(daily_wall_ID)
        if isannouncement{
            dailywallRef.getDocument{
                (document, error) in
                if let dailywalldoc = document, dailywalldoc.exists {
                    if let announcement_ref = dailywalldoc.data()!["announcement"] as? DocumentReference{
                        announcement_ref.getDocument{
                            document, error in
                            if let document = document, document.exists{
                                do{
                                    let announcement = try Firestore.Decoder().decode(Post.self, from: document.data()!)
                                    //delete image
                                    if let url = announcement.imageurl{
                                        self.deleteimage(url: url)
                                    }
                                    //delete the original announcemnt
                                    self.database.collection("posts").document(announcement_ref.documentID).delete()
                                    
                                } catch{
                                    print("Failed to delete image in announcement!")
                                }
                                
                            }
                        }
                        
                    }
                    dailywallRef.updateData(["announcement": postRef])
                    successful_callback()
                    print("successful_callback by announcement")
                }
            }
        } else{
            dailywallRef.updateData(["posts": FieldValue.arrayUnion([postRef])])
            successful_callback()
            print("successful_callback by post")
        }
    }
    
    func createWall(for goal: Goal){
        let newWall = Wall()
        newWall.goalID = goal.id
        
        do {
            let wallRef = try database.collection("walls").addDocument(from: newWall)
            convert_to_dates(to: wallRef, goal: goal)
        } catch{
            print("Failed to serialize goal")
        }
    }
    
    func convert_to_dates(to wall: DocumentReference, goal: Goal){
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        var date = goal.startDate.dateValue()
        let endDate = goal.endDate.dateValue()
        
        var frequency = 0
        
        switch goal.frequency {
        case "Every Monday":
            frequency = 2
        case "Every Tuesday":
            frequency = 3
        case "Every Wednesday":
            frequency = 4
        case "Every Thursday":
            frequency = 5
        case "Every Friday":
            frequency = 6
        case "Every Saturday":
            frequency = 7
        case "Every Sunday":
            frequency = 1
            
        default:
            frequency = 0
        }
        
        while date <= endDate {
            if (frequency == 0 || whatDayIsIt(date) == frequency){
                //initiate a daily wall here
                let newdailywall = DailyWall()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                create_append_daily_wall(add: newdailywall, to: wall, date: dateFormatter.string(from: date), goalID: goal.id)
            }
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
    }
    
    func create_append_daily_wall(add dailywall: DailyWall, to wall: DocumentReference, date: String, goalID: String){
        do{
            let documentID = "\(goalID)_\(date)"
            dailywall.date = date
            try database.collection("dailywalls").document(documentID).setData(from: dailywall)
            
            let newdailywallsRef = database.collection("dailywalls").document(documentID)
            wall.updateData(["dailywalls": FieldValue.arrayUnion([newdailywallsRef])])
        }
        catch {
            print("Failed to create a daily wall!")
        }
    }
    
    func whatDayIsIt(_ date: Date) -> Int{
        return Calendar.current.component(.weekday, from: date)
    }
    
    func deleteWall(for goalID: String, batch: WriteBatch, complete_call_back: @escaping ()->Void){
        database.collection("walls").whereField("goalID", isEqualTo: goalID).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let WallSnapshot = querySnapshot?.documents.first{
                    //remove all the dailywalls
                    if let d_wallreferences = WallSnapshot.data()["dailywalls"] as? [DocumentReference]{
                        for (idx, dwallref) in d_wallreferences.enumerated(){
                            //delete dailywall
                            batch.deleteDocument(dwallref)
                            self.deletePosts_in_dailywall(dailywallref: dwallref, batch: batch, complete_callback: {
                                if idx == d_wallreferences.count - 1{
                                    let wallRef = self.database.collection("walls").document(WallSnapshot.documentID)
                                    batch.deleteDocument(wallRef)
                                    complete_call_back()
                                }
                            })
                        }
                        if d_wallreferences.count == 0{
                            let wallRef = self.database.collection("walls").document(WallSnapshot.documentID)
                            batch.deleteDocument(wallRef)
                            complete_call_back()
                        }
                    } else{
                        let wallRef = self.database.collection("walls").document(WallSnapshot.documentID)
                        print("remove wall")
                        batch.deleteDocument(wallRef)
                        complete_call_back()
                    }
                }
            }
        }
    }
    
    func deletePosts_in_dailywall(dailywallref: DocumentReference, batch: WriteBatch, complete_callback: @escaping () -> Void){
        //delete pictures in each post
        
        dailywallref.getDocument{ (document, error) in
            if let document = document, document.exists {
                if let announcementref = document.data()!["announcement"] as? DocumentReference{
                    //delete announcement
                    batch.deleteDocument(announcementref)
                    print("delete announcement")
                    announcementref.getDocument { (document, error) in
                        if let document = document, document.exists {
                            do{
                                let post = try Firestore.Decoder().decode(Post.self, from: document.data()!)
                                //delete image
                                if let url = post.imageurl{
                                    self.deleteimage(url: url)
                                }
                            } catch{
                                print("decoding announcemnet error!")
                            }
                        } else {
                            print("Announcemnet does not exist")
                        }
                    }
                }
                if let postreferences = document.data()!["posts"] as? [DocumentReference]{
                    for (idx, postref) in postreferences.enumerated(){
                        //delete normal posts
                        batch.deleteDocument(postref)
                        print("delete daily post")
                        postref.getDocument { (document, error) in
                            if let document = document, document.exists {
                                do{
                                    let post = try Firestore.Decoder().decode(Post.self, from: document.data()!)
                                    //delete image
                                    if let url = post.imageurl{
                                        self.deleteimage(url: url)
                                    }
                                    if idx == (postreferences.count - 1){
                                        complete_callback()
                                    }
                                } catch{
                                    print("decoding error!")
                                }
                            } else {
                                print("Post does not exist")
                            }
                        }
                    }
                    if postreferences.count == 0{
                        complete_callback()
                    }
                }
            }
            else{
                print("Failed to fetch dailywall to delete posts!")
            }
                
            
        }
    }
    
    func setUpListener_on_SelectedDailyWall(goalID: String, selecteddate: Dateunit, add_item_tolist: @escaping (Post) -> Void, add_announcement_tolist: @escaping (Post) -> Void , remove_list: @escaping () -> Void) -> ListenerRegistration?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.year = selecteddate.year
        dateComponents.month = selecteddate.month
        dateComponents.day = selecteddate.date
        
        let dailywall_ID = "\(goalID)_\(dateFormatter.string(from: dateComponents.date!))"
        let dailywallref = database.collection("dailywalls").document(dailywall_ID)
        
        let listener = dailywallref.addSnapshotListener{
            documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching dailyWall obj: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("dailyWall data was empty")
                return
            }
            remove_list()
            if let postreferences = data["posts"] as? [DocumentReference]{
                for postref in postreferences{
                    postref.getDocument { (postdoc, error) in
                        if let postdocument = postdoc, postdocument.exists {
                            do{
                                let fetched_post = try Firestore.Decoder().decode(Post.self, from: postdocument.data()!)
                                add_item_tolist(fetched_post)
                            } catch{
                                print("decoding error!")
                            }
                        } else {
                            print("Post does not exist")
                        }
                    }
                }
            }
            if let announcemnet_reference = data["announcement"] as? DocumentReference{
                announcemnet_reference.getDocument{
                    (document, error) in
                    if let announce_doc = document, announce_doc.exists{
                        do{
                            let fetched_announcemnet = try Firestore.Decoder().decode(Post.self, from: announce_doc.data()!)
                            add_announcement_tolist(fetched_announcemnet)
                        } catch{
                            print("decoding error!")
                        }
                    }
                }
            }
        }
        
        return listener
    }
    
    
    func deleteimage(url: String){
        let imageRef = Storage.storage().reference(forURL: url)
        imageRef.delete { (error) in
            if let _ = error {
                print("failed to delete image")
            } else {
                print("Succeeded to delete image")
            }
        }
    }
    
    //used in WallViewController for fetching user info of the post
    func fetch_user(fetch_userid: String, callback: @escaping (_ nickname: String) -> Void){
        database.collection("users").document(fetch_userid).getDocument{
            document, error in
            if let document = document, document.exists{
                do{
                    let user = try Firestore.Decoder().decode(User.self, from: document.data()!)
                    callback(user.nickname)
                } catch{
                    print("Failed to decode user info in fetch_user!")
                }
            }else{
                print("Failed to fetch user document in fetch_user!")
            }
        }
    }
}
