//
//  LoginProtocol.swift
//  FIT3178FinalProject
//
//  Created by 李利元 on 2020/5/22.
//  Copyright © 2020 李利元. All rights reserved.
//

import Foundation

protocol LoginProtocol: AnyObject{
    func CreateNewAccount(nickname: String, email: String, password: String, sender: CreateAccountViewController)
    func loginAccount(email: String, password: String, successfully_callback: @escaping () -> Void, failed_callback: @escaping () -> Void)
    func logoutAccount()
}
