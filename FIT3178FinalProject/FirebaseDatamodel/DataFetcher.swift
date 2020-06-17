//
//  File.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/6/3.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation
import Firebase

protocol Return_obj{
    func setupObj(returnobj: Codable)
}

class DataFetchingHandler{
    var callback: (() -> Void)?
    func fetch_referenc<T: Codable>(reference: DocumentReference, decode_type: T.Type, return_obj: Return_obj){
        reference.getDocument{
            document, error in
            if let document = document, document.exists{
                do{
                    let decoded_obj = try Firestore.Decoder().decode(decode_type, from: document.data()!)
                    return_obj.setupObj(returnobj: decoded_obj)
                    if let callbackfunc = self.callback{
                        callbackfunc()
                    }
                } catch{
                    print("Failed to parse post data in date fetcher!")
                }
                
            }
            
        }
    }
    func setup_callback(newcallback: @escaping () -> Void){
        self.callback = newcallback
    }
}
