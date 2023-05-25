//
//  RoomsView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 21.05.2023.
//

import SwiftUI

// Экран просмотра созданных комнат
struct RoomsView: View {
    @Binding var user: User?
    @State private var rooms: [Room] = []
    @State var selectedRoom: Room?
    @State private var editRoom: Bool = false
    @State private var waitingRoom: Bool = false
    @State private var code: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    let numFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            // Кнопка возвращения на основной экран
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .padding()
            
            ScrollView {
                // Отображение созданных комнат
                ForEach(rooms) { room in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(room.name)
                            
                            Spacer()
                            
                            // Редактирование информации о комнате доступно только администратору
                            if room.adminID == user?.id {
                                Button {
                                    selectedRoom = room
                                    selectedRoom?.id = room.id
                                    editRoom.toggle()
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 30))
                                        .foregroundColor(.black)
                                        .padding(5)
                                }
                            }
                        }
                        
                        VStack {
                            Button {
                                // Присоединение к закрытой комнате
                                if room.isOpen == false && room.code == code {
                                    Task {
                                        try await NetworkService.shared.addClosedRoomPlayer(roomID: room.id, playerID: user!.id, code: code)
                                    }
                                    selectedRoom = room
                                    selectedRoom?.id = room.id
                                    
                                    waitingRoom.toggle()
                                }
                                
                                // Присоединение к открытой комнате
                                if room.isOpen == true {
                                    Task {
                                        try await NetworkService.shared.addRoomPlayer(roomID: room.id, playerID: user!.id)
                                    }
                                    selectedRoom = room
                                    selectedRoom?.id = room.id
                                    
                                    waitingRoom.toggle()
                                }
                            } label: {
                                Text("Присоединиться")
                            }
                            
                            // Поле ввода пароля
                            if room.isOpen == false {
                                TextField("Пароль:", value: $code, formatter: numFormatter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.top, 2)
                            }
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue
                        .opacity(0.5)
                        .cornerRadius(10)
                    )
                    .padding()
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $editRoom) {
                var roomID: String = ""
                EditRoomView (onEdit: { room in
                    if let id = rooms.firstIndex(where: { $0.id == room.id }) {
                        rooms[id] = room
                        Task {
                            do {
                                // Сохранение изменений в информации о комнате
                                try await NetworkService.shared.editRoom(room: room)
                            } catch {
                                print("Error")
                            }
                        }
                    }
                }, onDelete: {
                    room in
                    if let id = rooms.firstIndex(where: { $0.id == room.id }) {
                        roomID = rooms[id].id
                        rooms.remove(at: id)
                    }
                    // Удаление комнаты
                    NetworkService.shared.deleteRoom(roomID: roomID)
                }, user: $user, selectedRoom: $selectedRoom)
            }
            .fullScreenCover(isPresented: $waitingRoom) {
                WaitingRoomView (user: $user, selectedRoom: $selectedRoom, rooms: $rooms)
            }
        }
        .onAppear() {
            // Загрузка созданных комнат
            rooms = NetworkService.shared.getRooms()
        }
    }
}

struct RoomsView_Previews: PreviewProvider {
    @State static var user: User? = User(id: "1", username: "Ilya", teamID: "0")
    @State static var showStartView: Bool = true
    @State static var showRoomsView: Bool = false
    @State static var showAddRoomView: Bool = false
    
    static var previews: some View {
        RoomsView(user: $user)
    }
}

