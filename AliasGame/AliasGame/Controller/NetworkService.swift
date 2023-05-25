//
//  NetworkService.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 20.05.2023.
//

import Foundation

class NetworkService: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var users: [User] = []
    @Published var user: User = User(username: "", teamID: "")
    
    static let shared = NetworkService();
    
    private init() { }
    
    private let localhost = "http://127.0.0.1:8080"
    
    // Авторизация пользователя
    func auth(login: String, password: String) async throws -> User {
        let dto = UserDTO(username: login, teamID: "", password: password)
        
        guard let url = URL(string: "\(localhost)\(APIMethod.auth.rawValue)") else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: userData)
        return user
    }
    
    // Регистрация пользователя
    func signup(id: String?, login: String, password: String) async throws -> User {
        let dto = UserNEW(id: id, username: login, teamID: "", passwordHash: password)
        
        guard let url = URL(string: "\(localhost)\(APIMethod.signup.rawValue)") else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: userData)
        return user
    }
    
    // Изменение данных пользователя
    func editUser(user: User) async throws {
        let dto = User(id: user.id, username: user.username, teamID: user.teamID)
        
        let url = URL(string: "\(localhost)\(APIMethod.signup.rawValue)\(user.id)")
        
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: userData)
    }
    
    // Получение всех игровых комнат
    func getRooms() -> [Room] {
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let rooms = try JSONDecoder().decode([Room].self, from: data)
                self.rooms = rooms
            } catch {
                print("Error decoding organization: \(error)")
                return
            }
        }.resume()
        return self.rooms
    }
    
    // Получение списка всех пользователей
    func getUsers() -> [User] {
        
        let url = URL(string: "\(localhost)\(APIMethod.signup.rawValue)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                self.users = users
            } catch {
                print("Error decoding organization: \(error)")
                return
            }
        }.resume()
        return self.users
    }
    
    // Получение информации о пользователе по id
    func getUser(userID: String) -> User {
        
        let url = URL(string: "\(localhost)\(APIMethod.signup.rawValue)\(userID)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                self.user = user
            } catch {
                print("Error decoding task: \(error)")
                return
            }
        }.resume()
        return user
    }
    
    // Удаление игровой комнаты по id
    func deleteRoom(roomID: String) {
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)\(roomID)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed!!!!!!!")
                return
            }
        }.resume()
    }
    
    // Удаление пользователя по id
    func deleteUser(userID: String) {
        
        let url = URL(string: "\(localhost)\(APIMethod.signup.rawValue)\(userID)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed!!!!!!!")
                return
            }
        }.resume()
    }
    
    // Добавление (создание) новой игровой комнаты
    func addRoom(room: Room) async throws {
        
        let dto = RoomNEW(id: room.id, name: room.name, adminID: room.adminID, playersID: room.playersID, difficulty: room.difficulty, isOpen: room.isOpen, code: room.code, points: room.points, gameTime: room.gameTime, teamsCount: room.teamsCount, isGameStarted: room.isGameStarted)
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)")
        
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(Room.self, from: userData)
    }
    
    // Редактирование информации об игровой комнате
    func editRoom(room: Room) async throws {
        
        let dto = RoomNEW(id: room.id, name: room.name, adminID: room.adminID, playersID: room.playersID, difficulty: room.difficulty, isOpen: room.isOpen, code: room.code, points: room.points, gameTime: room.gameTime, teamsCount: room.teamsCount, isGameStarted: room.isGameStarted)
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)\(room.id)\(APIMethod.update.rawValue)")
        
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(Room.self, from: userData)
    }
    
    // Добавление игрока в открытую комнату
    func addRoomPlayer(roomID: String, playerID: String) async throws {
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)\(roomID)")
        
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(PlayerDTO(playerID: playerID))
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(Room.self, from: userData)
    }
    
    // Добавление игрока в закрытую комнату
    func addClosedRoomPlayer(roomID: String, playerID: String, code: Int) async throws {
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)\(roomID)")
        
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(PlayerClosedDTO(playerID: playerID, code: code))
        request.httpBody = data
        
        let userResponse = try await URLSession.shared.data(for: request)
        let userData = userResponse.0
        let decoder = JSONDecoder()
        let user = try decoder.decode(Room.self, from: userData)
    }
    
    // Удаление игрока из комнаты
    func deleteRoomPlayer(roomID: String, playerID: String) {
        
        let url = URL(string: "\(localhost)\(APIMethod.rooms.rawValue)\(roomID)/\(playerID)")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching task: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed!!!!!!!")
                return
            }
        }.resume()
    }
}

struct UserDTO: Codable {
    let username: String
    let teamID: String
    let password: String
}

struct PlayerDTO: Codable {
    let playerID: String
}

struct PlayerClosedDTO: Codable {
    let playerID: String
    let code: Int
}

struct UserNEW: Codable {
    let id: String?
    let username: String
    let teamID: String
    let passwordHash: String
}

struct RoomNEW: Codable {
    let id: String
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

enum APIMethod: String {
    case auth = "/users/auth"
    case signup = "/users/"
    case rooms = "/rooms/"
    case update = "/updateRoom"
}

enum NetworkError: Error {
    case badURL
}


