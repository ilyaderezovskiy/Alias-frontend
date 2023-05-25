//
//  AuthView.swift
//  AliasGame
//
//  Created by Ilya Derezovskiy on 20.05.2023.
//

import SwiftUI

struct AuthView: View {
    @State var login: String = UserDefaults.standard.string(forKey: "login") ?? ""
    @State var password: String = ""
    @State var showStartView = false
    @State var user: User?
    @State var result: String = ""
    @State var isSecure: Bool = true
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 0)
                .foregroundColor(.blue)
                .opacity(0.3)
            Spacer()
        }
        .onAppear() {
            // Если пользователь уже был авторизован и не выходил из аккаунта, то открывается сразу основной экран
            if UserDefaults.standard.bool(forKey: "isLogin") {
                Task {
                    self.user = try await NetworkService.shared.auth(login: login, password: UserDefaults.standard.string(forKey: "password")!)
                    NetworkService.shared.getRooms()
                    self.showStartView.toggle()
                }
            }
        }
        .ignoresSafeArea()
        .background(Image("bg")
            .resizable()
            .ignoresSafeArea()
            .aspectRatio(contentMode: .fill)
            .opacity(0.7)
        )
        .overlay {
            VStack(spacing: 20) {
                TextField("Введите логин:", text: $login)
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                    .padding(.top, 130)
                
                HStack {
                    Group {
                        if isSecure {
                            SecureField("Введите пароль:", text: $password)
                        } else {
                            TextField("Введите пароль:", text: $password)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSecure)
                    
                    Button(action: {
                        isSecure.toggle()
                    }, label: {
                        Image(systemName: !isSecure ? "eye.slash" : "eye" )
                            .font(.system(size: 20))
                            .foregroundColor(.brown)
                    })
                }
                .padding()
                .background(.white)
                .cornerRadius(15)
                
                Text("\(self.result)")
                    .foregroundColor(.red)
                
                // Кнопка авторизации пользователя
                Button {
                    Task {
                        do {
                            if checkInfo(isRegistration: false) {
                                self.user = try await NetworkService.shared.auth(login: login, password: password)
                                NetworkService.shared.getRooms()
                                UserDefaults.standard.set(login, forKey: "login")
                                UserDefaults.standard.set(password, forKey: "password")
                                UserDefaults.standard.set(true, forKey: "isLogin")
                                self.showStartView.toggle()
                            }
                        } catch {
                            self.result = "Ошибка авторизации - Пользователь с таким логином и паролем не найден"
                        }
                    }
                } label: {
                    Text("Войти")
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background(.brown)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                
                // Кнопка регистрации пользователя
                Button {
                    Task {
                        do {
                            if checkInfo(isRegistration: true) {
                                self.user = try await NetworkService.shared.signup(id: UUID().uuidString, login: login, password: password)
                                NetworkService.shared.getRooms()
                                UserDefaults.standard.set(login, forKey: "login")
                                UserDefaults.standard.set(password, forKey: "password")
                                UserDefaults.standard.set(true, forKey: "isLogin")
                                self.showStartView.toggle()
                            }
                        } catch {
                            self.result = "Ошибка регистрации - Пользователь с таким логином уже существует"
                        }
                    }
                } label: {
                    Text("Зарегистрироваться")
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background(.brown)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                
            }.padding(.horizontal, 40)
        }
        .fullScreenCover(isPresented: $showStartView) {
            StartView(user: $user, showStartView: $showStartView)
        }
    }
    
    // Проверка введённой пользователем информации
    func checkInfo(isRegistration: Bool?) -> Bool {
        self.result = ""
        if self.login == "" || self.password == "" {
            self.result.append("! Поля логина и пароля обязательны для заполнения\n")
            return false
        }
        
        if self.login.contains(" ") || self.login.range(of: ".*[^А-Яа-яA-Za-z0-9].*", options: .regularExpression) != nil {
            self.result.append("! Логин не может содержать специальных символов и пробелов\n")
            return false
        }
        
        if self.password.contains(" ") || self.password.range(of: ".*[^А-Яа-яA-Za-z0-9].*", options: .regularExpression) != nil {
            self.result.append("! Пароль не может содержать специальных символов и пробелов\n")
            return false
        }
        
        if self.password.count < 5 {
            self.result.append("! Пароль должен содержать больше 4 символов\n")
            return false
        }
        
        return true
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
