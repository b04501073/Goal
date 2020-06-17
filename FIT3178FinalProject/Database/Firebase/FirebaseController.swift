//
//  FirebaseController.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/22.
//  Copyright © 2020 李利元. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

var wall_data_fetcher = DataFetchingHandler()

class FirebaseController: NSObject, LoginProtocol, DatabaseProtocol{
    
    var database: Firestore
    var user_goalsRef: CollectionReference?
    var goalRef: CollectionReference?
    var usersReference: CollectionReference?
    var storageReference: StorageReference?
    
    var userid: String!
    var user_goal_id: String!
    
    //buffer parameters
    var posts_to_show = [Post]()        //for posts of the selected wall of a date
    var announcement_to_show: Post?     //for announcemnet post of the selected wall of a date
    var images_buffer = [UIImage]()
    
    
    override init() {
        
        // We call auth and firestore to get access to these frameworks
        FirebaseApp.configure()
        database = Firestore.firestore()
        super.init()
    }
    
    func getUserID() -> String{
        return self.userid
    }
    func CreateNewAccount(nickname: String, email: String, password: String, sender: CreateAccountViewController) {
        Auth.auth().createUser(withEmail: email, password: password) {
            authResult, error in
            
            if authResult == nil{
                sender.failed_signup()
            } else{
                self.userid = authResult?.user.uid
                self.create_user_goal()
                self.create_user(nickname: nickname)
                self.setUp_references(successfully_callback: {
                    //todo
                })
                sender.successfully_signup()
            }
        }
    }
    
    func loginAccount(email: String, password: String, successfully_callback: @escaping () -> Void, failed_callback: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {
            authResult, error in
            
            if authResult == nil{
                failed_callback()
            } else{
                self.userid = authResult?.user.uid
                self.setUp_references(successfully_callback: {
                    successfully_callback()
                })
            }
        }
    }
    
    func logoutAccount(){
        if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Log out error: \(error.localizedDescription)")
            }
        }
    }
    
    func create_user_goal(){
        let new_user_goal = GoalList()
        new_user_goal.userid = self.userid
        if (try? database.collection("user_goals").addDocument(from: new_user_goal)) != nil{} else{
            print("Error writing user_goals to Firestore")
        }
    }
    
    func create_user(nickname: String){
        let user = User()
        user.nickname = nickname
        
        do{
            if let userID = Auth.auth().currentUser?.uid{
                let _ = try database.collection("users").document(userID).setData(from: user)
            }else{
                print("Can't get userid in func createUser!!")
            }
        }catch{
            print("Failed to serialize a new user!")
        }
        
    }
    
    func setUp_references(successfully_callback: @escaping () -> Void){
        goalRef = database.collection("goals")
        user_goalsRef = database.collection("user_goals")
        usersReference = Firestore.firestore().collection("users")
        storageReference =  Storage.storage().reference()
        user_goalsRef?.whereField("userid", isEqualTo: self.userid!).getDocuments{
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot,
                let user_goalsSnapshot = querySnapshot.documents.first else {
                    print("Error fetching user_goal binding object: \(error!)")
                    return
            }
            self.user_goal_id = user_goalsSnapshot.documentID
            successfully_callback()
        }
    }
    
    func setUpListener_on_ManagingGoals(add_item_tolist: @escaping (Goal) -> Void, remove_list: @escaping () -> Void) -> ListenerRegistration?{
        let listener = user_goalsRef!.document(user_goal_id).addSnapshotListener {
            documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching user_goal by user_goal_id: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("User_goal data was empty")
                return
            }
            if let goalReferences = data["managing_goals"] as? [DocumentReference] {
                remove_list()
                
                for reference in goalReferences{
                    let docRef = self.goalRef!.document(reference.documentID)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            do{
                                let decoded_goal = try Firestore.Decoder().decode(Goal.self, from: document.data()!)
                                decoded_goal.id = document.documentID
                                add_item_tolist(decoded_goal)
                            } catch{
                                fatalError("decoding error!")
                            }
                        } else {
                            fatalError("Managing goal does not exist")
                        }
                    }
                }
            }
        }
        return listener
    }
    
    func setUpListener_on_ParticipatingGoals(add_item_tolist: @escaping (Goal) -> Void, remove_list: @escaping () -> Void) -> ListenerRegistration?{
        let listener = user_goalsRef!.document(user_goal_id).addSnapshotListener {
            documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching user_goal by user_goal_id: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("User_goal data was empty")
                return
            }
            if let goalReferences = data["participating_goals"] as? [DocumentReference] {
                remove_list()
                
                for reference in goalReferences{
                    let docRef = self.goalRef!.document(reference.documentID)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            do{
                                let decoded_goal = try Firestore.Decoder().decode(Goal.self, from: document.data()!)
                                decoded_goal.id = document.documentID
                                add_item_tolist(decoded_goal)
                            } catch{
                                fatalError("decoding participating goal error!")
                            }
                        } else {
                            self.remove_participating_goal(goalID: document!.documentID)
                            print("Participating goal does not exist")
                        }
                    }
                }
            }
        }
        return listener
    }
    
    
    func user_add_participating_goal(goalID: String, complete_callback: @escaping () -> Void, failed_callback: @escaping () -> Void){
        let newGoalRef = database.collection("goals").document(goalID)
        newGoalRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //add goal reference in user's participating list
                self.user_goalsRef?.document(self.user_goal_id).updateData(
                    ["participating_goals" : FieldValue.arrayUnion([newGoalRef])]
                )
                //add current user in goal's participants list
                newGoalRef.updateData(
                    ["participants" : FieldValue.arrayUnion([self.database.collection("users").document(self.userid)])]
                )
                complete_callback()
            } else {
                failed_callback()
            }
        }
    }
    
    func user_create_goal(title: String, startDate: Date, endDate: Date, frequency: String, successfully_callback: @escaping () -> Void, failed_callback: @escaping () -> Void){
        let goal = Goal()
        goal.title = title
        goal.startDate = Firebase.Timestamp(date: startDate)
        goal.endDate = Firebase.Timestamp(date: endDate)
        goal.frequency = frequency
        goal.manager = self.userid
        
        do{
            if let new_goalRef = try goalRef?.addDocument(from: goal){
                goal.id = new_goalRef.documentID
                //add the goal reference to the manager's managing goal list and participating goal list
                user_goalsRef?.document(self.user_goal_id).updateData(
                    ["participating_goals" : FieldValue.arrayUnion([new_goalRef]),
                    "managing_goals" : FieldValue.arrayUnion([new_goalRef])]
                )
                new_goalRef.updateData(
                    ["participants" : FieldValue.arrayUnion([database.collection("users").document(self.userid)])]
                )
                successfully_callback()
                //create the wall of the new goal
                createWall(for: goal)
            }
            
        } catch{
            failed_callback()
            print("Failed to Create a new goal in user_create_goal")
        }
    }
    
    func addGoalToParticapating_GoalList(goalID: String) -> Bool {
        if let newGoalRef = goalRef?.document(goalID) {
            user_goalsRef?.document(self.user_goal_id).updateData(
                ["participating_goals" : FieldValue.arrayUnion([newGoalRef])]
            )
        }
        return true
    }
    
    
    func remove_participating_goal(goalID: String){
        if let removedRef = goalRef?.document(goalID){
            if self.user_goal_id != nil{
                self.user_goalsRef?.document(self.user_goal_id).updateData(
                    ["participating_goals": FieldValue.arrayRemove([removedRef])]
                )
                let userRef = database.collection("users").document(self.userid)
                removedRef.updateData(
                    ["participants" : FieldValue.arrayRemove([userRef])]
                )
            }
        }
    }
    
    func remove_managing_goal(goalID: String){
        let batch = database.batch()
        if let removedRef = goalRef?.document(goalID) {
            batch.updateData(["managing_goals": FieldValue.arrayRemove([removedRef])], forDocument: (self.user_goalsRef?.document(self.user_goal_id))!)
        }
        let deleted_goalRef = database.collection("goals").document(goalID)
        batch.deleteDocument(deleted_goalRef)
        deleteWall(for: goalID, batch: batch, complete_call_back: {
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch in transaction of deleting managing goal \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
        })
    }
    func search_goal(by goalName: String, complete_callback: @escaping ([Goal]) -> Void){
        self.database.collection("goals").whereField("title", isGreaterThanOrEqualTo: goalName).getDocuments(){
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var searched_goals = [Goal]()
                for document in querySnapshot!.documents {
                    do{
                        let decoded_goal = try Firestore.Decoder().decode(Goal.self, from: document.data())
                        decoded_goal.id = document.documentID
                        searched_goals.append(decoded_goal)
                    } catch{
                        print("Failed to decode a searched goal")
                    }
                }
                complete_callback(searched_goals)
            }
        }
    }
    
}
