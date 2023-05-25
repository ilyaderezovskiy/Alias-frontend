//
//  AddRoomView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 21.05.2023.
//

import SwiftUI

struct AddRoomView: View {
    var onAdd: (Room) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var user: User?
    @State private var name: String = ""
    @State private var difficulty: Int = 2
    @State private var isOpen: Bool = true
    @State private var code: Int = 0
    @State private var points: Int = 15
    @State private var gameTime: Int = 40
    @State private var teamsCount: Int = 2
    @State private var isGameStarted: Bool = false
    
    let numFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                // Кнопка возвращения на основной экран
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .contentShape(Rectangle())
                }
                
                Text("Создание игровой комнаты")
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
                
                // Кнопка создания новой комнаты
                Button {
                    if teamsCount >= 2 {
                        let room = Room(name: name, adminID: user!.id, playersID: [user!.id], difficulty: difficulty, isOpen: isOpen, code: code, points: points, gameTime: gameTime, teamsCount: teamsCount, isGameStarted: isGameStarted)
                        onAdd(room)
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
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(15)
            }
            .padding(15)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear() {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    @State static var user: User? = User(id: "1", username: "Ilya", teamID: "")
    
    static var previews: some View {
        AddRoomView (onAdd: {
            room in
        }, user: $user)
    }
}

