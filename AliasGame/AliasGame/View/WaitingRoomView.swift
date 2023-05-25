//
//  WaitingRoomView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 24.05.2023.
//

import SwiftUI

// Экран присоединения игрока к комнате
struct WaitingRoomView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var user: User?
    @Binding var selectedRoom: Room?
    @Binding var rooms: [Room]
    @State private var difficulty: Int = 2
    @State private var isOpen: Bool = true
    @State private var code: Int? = 0
    @State private var points: Int = 15
    @State private var gameTime: Int = 40
    @State private var teamsCount: Int = 2
    @State private var users: [User] = []
    @State private var isStarted: Bool = false
    @State private var confirmationShown = false
    
    let numFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 20) {
                // Кнопка выхода из комнаты
                if user!.id == selectedRoom!.adminID {
                    Button {
                        rooms = NetworkService.shared.getRooms()
                        dismiss()
                    } label: {
                        Text("Назад")
                            .foregroundColor(.red)
                    }
                } else {
                    Button {
                        rooms = NetworkService.shared.getRooms()
                        user!.teamID = ""
                        Task {
                            NetworkService.shared.deleteRoomPlayer(roomID: selectedRoom!.id, playerID: user!.id)
                            try await NetworkService.shared.editUser(user: user!)
                            dismiss()
                        }
                    } label: {
                        Text("Выйти из комнаты")
                            .foregroundColor(.red)
                    }
                }
                
                Text("Ожидание начала игры")
                    .font(.title)
                    .padding(.vertical, 15)
                
                ScrollView {
                    // Информация о количестве команд и игроков, присоединившихся к командам
                    ForEach(1...selectedRoom!.teamsCount, id: \.self) { i in
                        HStack {
                            Text("Команда \(i)")
                                .font(.title2)
                            
                            Spacer()
                            
                            Button {
                                // Обновление информации о номере команды пользователя
                                user!.teamID = String(i)
                                Task {
                                    try await NetworkService.shared.editUser(user: user!)
                                }
                            } label: {
                                Text("Присоединиться")
                            }
                        }
                        // Отображение игроков - участников команд
                        ForEach(users) { item in
                            if item.teamID == String(i) && selectedRoom!.playersID.contains(item.id) {
                                HStack {
                                    Text(item.username)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        // Удаление и назначение администратором доступно только администратору
                                        if selectedRoom!.adminID == user!.id {
                                            // Кнопка удаления ирока из комнаты
                                            Button {
                                                NetworkService.shared.deleteRoomPlayer(roomID: selectedRoom!.id, playerID: item.id)
                                                let delUser = User(id: item.id, username: item.username, teamID: "0")
                                                Task {
                                                    try await NetworkService.shared.editUser(user: delUser)
                                                }
                                                self.users = NetworkService.shared.getUsers()
                                            } label: {
                                                Text("Удалить")
                                                    .foregroundColor(.red)
                                            }
                                            
                                            // Кнопка назначения игрока администратором
                                            Button {
                                                selectedRoom!.adminID = item.id
                                                Task {
                                                    do {
                                                        try await NetworkService.shared.editRoom(room: selectedRoom!)
                                                    } catch {
                                                        print("Error")
                                                    }
                                                }
                                            } label: {
                                                Text("Сделать администратором")
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                    
                    Text("Количество очков за угаданное слово:")
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    HStack {
                        TextField("Количество очков за угаданное слово:", value: $points, formatter: numFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        // Кнопка изменения количества очкой за угаданной слово
                        Button {
                            selectedRoom!.points = self.points
                            Task {
                                do {
                                    try await NetworkService.shared.editRoom(room: selectedRoom!)
                                } catch {
                                    print("Error")
                                }
                            }
                        } label: {
                            Text("Сохранить")
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(15)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    
                    Text("Время игры: \(selectedRoom!.gameTime) сек.")
                        .foregroundColor(.gray)
                    
                    // Кнопки закрытия (удаления) комнаты и начала игры доступны только администратору
                    if selectedRoom!.adminID == user!.id {
                        VStack {
                            // Кнопка закрытия (удаления) комнаты
                            Button {
                                NetworkService.shared.deleteRoom(roomID: selectedRoom!.id)
                                dismiss()
                            } label: {
                                Text("Закрыть комнату")
                                    .foregroundColor(.red)
                            }
                            
                            // Кнопка начала игры (раунда)
                            Button {
                                selectedRoom!.isGameStarted = true
                                Task {
                                    do {
                                        try await NetworkService.shared.editRoom(room: selectedRoom!)
                                    } catch {
                                        print("Error")
                                    }
                                }
                            } label: {
                                Text("Начать раунд!")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background {
                                        Capsule()
                                            .fill(
                                                .blue
                                            )
                                    }
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(15)
                        }
                    }
                }
            }
            .padding(15)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear() {
            self.users = NetworkService.shared.getUsers()
            self.points = selectedRoom!.points
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

struct WaitingRoomView_: PreviewProvider {
    @State static var user: User? = User(id: "1", username: "Ilya", teamID: "0")
    @State static var room: Room? = Room(name: "123", playersID: [], difficulty: 1, isOpen: true, points: 1, gameTime: 1, teamsCount: 3, isGameStarted: false)
    @State static var rooms: [Room] = []
    
    static var previews: some View {
        WaitingRoomView (user: $user, selectedRoom: $room, rooms: $rooms)
    }
}
