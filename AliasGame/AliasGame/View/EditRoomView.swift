//
//  EditRoomView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 21.05.2023.
//

import SwiftUI

struct EditRoomView: View {
    var onEdit: (Room) -> ()
    var onDelete: (Room) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var user: User?
    @Binding var selectedRoom: Room?
    
    @State private var name: String = ""
    @State private var adminID: String?
    @State private var playersID: [String] = []
    @State private var difficulty: Int = 2
    @State private var isOpen: Bool = true
    @State private var code: Int? = 0
    @State private var points: Int = 15
    @State private var gameTime: Int = 40
    @State private var teamsCount: Int = 2
    @State private var isGameStarted: Bool = false
    @State private var confirmationShown = false
    
    let numFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Кнопка возвращения на основной экран
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    // Кнопка удаления комнаты
                    Button (
                        role: .destructive,
                        action: {
                            confirmationShown = true
                        }) {
                            Image(systemName: "trash")
                                .contentShape(Rectangle())
                                .frame(minWidth: 50)
                                .font(.system(size: 25))
                        }
                        .confirmationDialog (
                            "Вы действительно хотите удалить комнату?",
                            isPresented: $confirmationShown,
                            titleVisibility: .visible) {
                                Button("Да") {
                                    withAnimation {
                                        let room = Room(id: selectedRoom!.id, name: name, adminID: adminID, playersID: playersID, difficulty: difficulty, isOpen: isOpen, code: code, points: points, gameTime: gameTime, teamsCount: teamsCount, isGameStarted: isGameStarted)
                                        onDelete(room)
                                        dismiss()
                                    }
                                }
                                Button("Нет", role: .cancel) { }
                            }
                }
            }
            
            Text("Редактирование комнаты")
                .font(.title)
                .padding(.vertical, 15)
            
            Text("Название")
                .foregroundColor(.gray)
            
            TextField("Название комнаты", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 2)
            
            Text("Количество очков за угаданное слово")
                .foregroundColor(.gray)
            
            TextField("Количество очков", value: $points, formatter: numFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 2)
            
            Text("Время игры (сек.)")
                .foregroundColor(.gray)
            
            TextField("Время игры (сек.)", value: $gameTime, formatter: numFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 2)
        }
        .padding(15)
        .frame(maxHeight: .infinity, alignment: .top)
        
        VStack(alignment: .leading, spacing: 10) {
            
            Toggle(isOpen == true ? "Открытая комната" : "Закрытая комната", isOn: $isOpen)
            
            Text("Пароль")
                .foregroundColor(.gray)
            
            TextField("Пароль", value: $code, formatter: numFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 2)
                .disabled(isOpen == true ? true : false)
            
            Text("Количество команд (>= 2)")
                .foregroundColor(.gray)
            
            TextField("Количество команд:", value: $teamsCount, formatter: numFormatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 2)
            
            // Кнопка сохранения информации о комнате
            Button {
                if teamsCount >= 2 {
                    let room = Room(id: selectedRoom!.id, name: name, adminID: user!.id, playersID: [user!.id], difficulty: difficulty, isOpen: isOpen, code: code, points: points, gameTime: gameTime, teamsCount: teamsCount, isGameStarted: isGameStarted)
                    onEdit(room)
                    dismiss()
                }
            } label: {
                Text("Сохранить")
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
            .padding(15)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(15)
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear() {
            name = selectedRoom!.name
            adminID = selectedRoom!.adminID
            playersID = selectedRoom!.playersID
            difficulty = selectedRoom!.difficulty
            isOpen = selectedRoom!.isOpen
            code = selectedRoom!.code
            points = selectedRoom!.points
            gameTime = selectedRoom!.gameTime
            teamsCount = selectedRoom!.teamsCount
            isGameStarted = selectedRoom!.isGameStarted
            
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}


