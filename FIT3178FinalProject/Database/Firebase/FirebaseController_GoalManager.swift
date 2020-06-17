//
//  FirebaseController_GoalManager.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/3.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

extension FirebaseController{
    func setUpListener_on_SelectedWall(goalID: String, setNewWall_callback: @escaping (Wall) -> Void) -> ListenerRegistration?{
        let listener = database.collection("walls").whereField("goalID", isEqualTo: goalID).addSnapshotListener{
            querySnapshot, error in
            if let err = error {
                print("Error getting walls: \(err)")
            } else{
                if let WallSnapshot = querySnapshot?.documents.first{
                    let wallref = WallSnapshot.reference
                    wallref.getDocument{
                        (document, error) in
                        if let document = document, document.exists {
                            do {
                                let decodedWall = try Firestore.Decoder().decode(Wall.self, from: document.data()!)
                                wall_data_fetcher.setup_callback {
                                    setNewWall_callback(decodedWall)
                                }
                                
                            } catch{
                                print("Failed to parse the wall data!")
                            }
                        } else{
                            print("Wall doesn't exist!")
                        }
                    }
                }
            }
        }
        return listener
    }
    
}
