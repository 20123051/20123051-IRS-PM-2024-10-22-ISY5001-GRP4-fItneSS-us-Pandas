//
//  SignUpView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 17/10/24.
//


import SwiftUI

struct SignupResponse: Decodable {
    var message: String
}

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

            Button("Sign Up") {
                signUp()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(message)
                .foregroundColor(.red)
        }
        .padding()
    }

    private func signUp() {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty else {
            message = "Please enter username, email and password"
            return
        }
        let signUpUrl = URL(string: "https://fu.tktonny.top/signup")!
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = "POST"
        //print(request)
        struct Message: Encodable {
            let username: String
            let email: String
            let password: String
        }
        let message = Message(username: username, email: email, password: password)
        let data = try? JSONEncoder().encode(message)
        
        request.httpBody = data
        request.setValue(String(data!.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Sign up error: \(error.localizedDescription)"
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    self.message = "Failed to receive HTTP response"
                    return
                }
                if statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let signupResponse = try decoder.decode(SignupResponse.self, from: data)
                        print("SUCCESS\(signupResponse)")
                    
                        self.message = (signupResponse.message)
                    } catch {
                        print("json error: \(error)")
                    }
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let signupResponse = try decoder.decode(SignupResponse.self, from: data)
                        print("FAILURE\(signupResponse)")
                        self.message = (signupResponse.message)
                    } catch {
                        print("json error: \(error)")
                    }
                    
                }
            }
        }.resume()
        
    }
}

#Preview {SignUpView()}
