//
//  StartView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 20.05.2023.
//

import SwiftUI

struct StartView: View {
    @Binding var user: User?
    @Binding var showStartView: Bool
    @State var showRoomsView: Bool = false
    @State var showAddRoomView: Bool = false
    
    var body: some View {
        VStack {
            // Кнопка создания новой комнаты
            Button {
                showAddRoomView.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Создать новую комнату")
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .frame(maxWidth: 280)
            .foregroundColor(.white)
            .background(.blue, in: Capsule())
            
            // Кнопка присоединения к уже созданной комнате
            Button {
                showRoomsView.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Присоединиться к игре")
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .frame(maxWidth: 280)
            .foregroundColor(.white)
            .background(.blue, in: Capsule())
            
            // Кнопка выхода из аккаунта
            Button {
                UserDefaults.standard.set(false, forKey: "isLogin")
                showStartView = false
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Выйти")
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .frame(maxWidth: 280)
            .foregroundColor(.white)
            .background(.blue, in: Capsule())
            
            // Кнопка удаления аккаунта пользователя
            Button {
                NetworkService.shared.deleteUser(userID: user!.id)
                UserDefaults.standard.set(false, forKey: "isLogin")
                showStartView = false
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                    Text("Удалить аккаунт")
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .frame(maxWidth: 280)
            .foregroundColor(.white)
            .background(.blue, in: Capsule())
        }
        .fullScreenCover(isPresented: $showAddRoomView) {
            AddRoomView (onAdd: { room in
                Task {
                    do {
                        try await NetworkService.shared.addRoom(room: room)
                    } catch {
                        print("Error")
                    }
                }
            }, user: $user)
        }
        .fullScreenCover(isPresented: $showRoomsView) {
            RoomsView(user: $user)
        }
    }
    
    
}

struct StartView_Previews: PreviewProvider {
    @State static var user: User? = User(id: "1", username: "Ilya", teamID: "0")
    @State static var showStartView: Bool = true
    @State static var showRoomsView: Bool = false
    @State static var showAddRoomView: Bool = false
    
    static var previews: some View {
        StartView(user: $user, showStartView: $showStartView, showRoomsView: showRoomsView, showAddRoomView: showAddRoomView)
    }
}
