//
//  User.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 20.05.2023.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    let username: String
    var teamID: String
}
