//
//  LoginView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 16/10/24.
//


import SwiftUI
//import KeychainAccess

struct LoginResponse_user: Decodable {
    var email: String
    var id: Int
    var username: String
}

struct LoginResponse_success: Decodable {
    var message: String
    var token: String
    var user: LoginResponse_user
}

struct LoginResponse_fail: Decodable {
    var message: String
}


struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Username or Email", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            Button("Login") {
                    login()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            
            Text(message)
                .foregroundColor(.red)
        }
        .padding()
        .gesture(
            TapGesture()
                .onEnded { _ in
                    hideKeyboard()
                }
        )
    }
    
    private func login() {
        guard !username.isEmpty, !password.isEmpty else {
            message = "Please enter both username and password"
            return
        }
        //print(isLoggingIn)
        //isLoggingIn = true
        //print(isLoggingIn)
        let loginUrl = URL(string: "https://fu.tktonny.top/login")!
        var request = URLRequest(url: loginUrl)
        request.httpMethod = "POST"
        
        struct Message: Encodable {
            let login: String
            let password: String
        }
        let message = Message(login: username, password: password)
        let data = try? JSONEncoder().encode(message)
        
        request.httpBody = data
        request.setValue(String(data!.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Login error: \(error.localizedDescription)"
                    //self.isLoggingIn = false
                    return
                }

                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    self.message = "Failed to receive HTTP response"
                    //self.isLoggingIn = false
                    return
                }

                if statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let loginResponse = try decoder.decode(LoginResponse_success.self, from: data)
                        print("SUCCESS\(loginResponse)")
                        /*
                        let keychain = Keychain(service: "com.yourapp.identifier")
                        try? keychain.set(loginResponse.token, forKey: "logintoken")
                        try? keychain.set(loginResponse.user.email, forKey: "email")
                         */
                        
                        UserDefaults.standard.set(loginResponse.token, forKey: "logintoken")
                        UserDefaults.standard.set(loginResponse.user.email, forKey: "email")
                        UserDefaults.standard.set(loginResponse.user.username, forKey: "username")
                        UserDefaults.standard.set(true, forKey: "isLoggingIn")
                        
                        
                        self.message = (loginResponse.message)
                        appState.isLoggedIn = true
                        //print(isLoggingIn)
                    } catch {
                        print("json error: \(error)")
                        //self.isLoggingIn = false
                    }
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let loginResponse = try decoder.decode(LoginResponse_fail.self, from: data)
                        print("FAILURE\(loginResponse)")
                        self.message = (loginResponse.message)
                        //self.isLoggingIn = false
                        //print(isLoggingIn)
                    } catch {
                        print("json error: \(error)")
                        //self.isLoggingIn = false
                    }
                    
                }

                //self.isLoggingIn = false
                //print(isLoggingIn)
            }
        }.resume()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// For preview and testing
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


