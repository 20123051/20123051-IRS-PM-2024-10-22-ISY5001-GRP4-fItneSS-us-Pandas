//
//  ProfileView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 21/10/24.
//


import SwiftUI

struct UserBodyInformation: Encodable{
    var gender: String
    var age: Int
    var height: Double // in centimeters
    var current_weight: Double // in kilograms
    var target_weight: Double // in kilograms
    var experience_level: String
}

struct ProfileView: View {
    @State private var userBodyInfo: UserBodyInformation
    
    init() {
        let gender = UserDefaults.standard.string(forKey: "gender") ?? "Unknown"
        let age = Int(UserDefaults.standard.double(forKey: "age"))
        let height = UserDefaults.standard.double(forKey: "height")
        let currentWeight = UserDefaults.standard.double(forKey: "current_weight")
        let targetWeight = UserDefaults.standard.double(forKey: "target_weight")
        let experienceLevel = UserDefaults.standard.string(forKey: "experience_level") ?? "Beginner"
        
        _userBodyInfo = State(initialValue: UserBodyInformation(
            gender: gender,
            age: age,
            height: height,
            current_weight: currentWeight,
            target_weight: targetWeight,
            experience_level: experienceLevel
        ))
    }
    @State private var editing = false
    let genders = ["male", "female"]
    var body: some View {
        List {
            Section(header: Text("User Information")) {
                if editing {
                    Picker("Gender", selection: $userBodyInfo.gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    Stepper("Age: \(userBodyInfo.age)", value: $userBodyInfo.age, in: 18...100)
                    Stepper("Height (cm): \(userBodyInfo.height, specifier: "%.1f")", value: $userBodyInfo.height, in: 100...250, step: 0.5)
                    Stepper("Current Weight (kg): \(userBodyInfo.current_weight, specifier: "%.1f")", value: $userBodyInfo.current_weight, in: 30...200, step: 0.5)
                    Stepper("Target Weight (kg): \(userBodyInfo.target_weight, specifier: "%.1f")", value: $userBodyInfo.target_weight, in: 30...200, step: 0.5)
                    Picker("Experience Level", selection: $userBodyInfo.experience_level) {
                        Text("Beginner").tag("1")
                        Text("Intermediate").tag("2")
                        Text("Advanced").tag("3")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } else {
                    Text("Gender: \(userBodyInfo.gender.uppercased())")
                    Text("Age: \(userBodyInfo.age)")
                    Text("Height: \(userBodyInfo.height, specifier: "%.0f") cm")
                    Text("Current Weight: \(userBodyInfo.current_weight, specifier: "%.1f") kg")
                    Text("Target Weight: \(userBodyInfo.target_weight, specifier: "%.1f") kg")
                    Text("Experience Level: \(userBodyInfo.experience_level)")
                }
                if editing {
                    Button("Save Changes") {
                        submitBodyInfo()
                        editing = false
                    }
                }
            }
            Section(header: Text("Activity")) {
                NavigationLink("My Posts", destination: UserPostsView())
                NavigationLink("Liked Posts", destination: LikedPostsView())
                NavigationLink("Collected Posts", destination: CollectedPostsView())
                NavigationLink("Viewed Posts", destination: ViewedPostsView())
            }
            
            Section(header: Text("Social")) {
                NavigationLink("Followers", destination: FollowersView())
                NavigationLink("Following", destination: FollowingView())
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            Button(editing ? "Done" : "Edit") {
                editing.toggle()
            }
        }
        
    }
    func submitBodyInfo() {
        guard let url = URL(string: "https://fu.tktonny.top/body_info") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "logintoken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print(userBodyInfo)
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(userBodyInfo)
        } catch {
            print("Failed to encode body information")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Submission error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    print("Profile updated successfully.")
                }
            } else {
                print("Failed to update profile.")
            }
        }.resume()
    }
}

// Placeholder Views for Navigation Links
struct UserPostsView: View { var body: some View { Text("User Posts") } }
struct LikedPostsView: View { var body: some View { Text("Liked Posts") } }
struct CollectedPostsView: View { var body: some View { Text("Collected Posts") } }
struct ViewedPostsView: View { var body: some View { Text("viewed Posts") } }
struct FollowingView: View { var body: some View { Text("viewed Posts") } }
struct FollowersView: View { var body: some View { Text("viewed Posts") } }

#Preview {
    ProfileView()
}
