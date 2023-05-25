//
//  Room.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 21.05.2023.
//

import Foundation

struct Room: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var adminID: String?
    var playersID: [String]
    var difficulty: Int // 1 - high complexity, 2 - average difficulty, 3 - low difficulty
    var isOpen: Bool
    var code: Int?
    var points: Int
    var gameTime: Int
    var teamsCount: Int
    var isGameStarted: Bool
}
