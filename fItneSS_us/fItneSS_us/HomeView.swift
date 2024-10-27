//
//  HomeView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 4/10/24.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var gender: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0.0
    @Published var currentWeight: Double = 0.0
    @Published var targetWeight: Double = 0.0
    @Published var experienceLevel: String = ""
    @Published var errorMessage: String = ""
    //@EnvironmentObject var appState: AppState
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func fetchBodyInfo() {
        print("fetchbodyinfo")
        guard let url = URL(string: "https://fu.tktonny.top/body_info") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Ensure the token is retrieved securely, perhaps from Keychain or securely stored
        if let token = UserDefaults.standard.string(forKey: "logintoken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Authentication token not found"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    self.errorMessage = "Failed to receive HTTP response"
                    return
                }
                //print(statusCode)
                if statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        self.gender = json?["gender"] as? String ?? ""
                        self.age = json?["age"] as? Int ?? 0
                        self.height = json?["height"] as? Double ?? 0.0
                        self.currentWeight = json?["current_weight"] as? Double ?? 0.0
                        self.targetWeight = json?["target_weight"] as? Double ?? 0.0
                        self.experienceLevel = json?["experience_level"] as? String ?? ""
                        UserDefaults.standard.set(self.gender, forKey: "gender")
                        UserDefaults.standard.set(self.age, forKey: "age")
                        UserDefaults.standard.set(self.height, forKey: "height")
                        UserDefaults.standard.set(self.currentWeight, forKey: "current_weight")
                        UserDefaults.standard.set(self.targetWeight, forKey: "target_weight" )
                        UserDefaults.standard.set(self.experienceLevel, forKey: "experience_level" )
                        
                        print(self)
                    } catch {
                        self.errorMessage = "JSON decoding error: \(error.localizedDescription)"
                    }
                }
                if statusCode == 404{
                    self.appState.toSurvey = true
                }
                else{
                    print(statusCode)
                    return()
                }
            }
        }.resume()
    }
}

enum NavigationDestinations: Hashable {
    case nextView
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    //@EnvironmentObject var infoState: AppState
    @StateObject var viewModel: ProfileViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(appState: .init()))
    }

    @Environment(\.colorScheme) var colorScheme
    @State private var showingSidebar = false
    @State private var selectedTab = 0  // Default is the 1st（0）  "summary" tab
    // Dynamic background color based on the color scheme
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    // Create a TabBarButton component
    private func createTabButton(imageName: String, title: String, index: Int) -> some View {
        TabBarButton(imageName: imageName, title: title, isSelected: selectedTab == index)
            .onTapGesture { selectedTab = index }
    }

    var body: some View {
        /*Text("Is Logged In: \(appState.isLoggedIn.description)")
                    .onAppear {
                        print("AppState is available here!")
                    }*/
        ZStack {
            VStack {
#if os(iOS)
                NavigationView {
                    content
                        .navigationBarTitle("fItneSS us", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button(action: {
                                withAnimation {
                                    showingSidebar.toggle()
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                            },
                            trailing: NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)  // Profile icon color
                            }
                        )
                }
#else
                content
#endif
                Spacer()

                // Custom Bottom Navigation Bar
                HStack {
                    // Left-side buttons
                    createTabButton(imageName: "waveform.circle", title: "Summary", index: 0)
                    Spacer()
                    createTabButton(imageName: "map", title: "Sites", index: 1)

                    Spacer()  // Central button space

                    // Central Workout button
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "figure.walk")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        )
                        .offset(y: -20)  // Shift the circle slightly up
                        .onTapGesture { selectedTab = 2 }

                    Spacer()  // Central button space

                    // Right-side buttons
                    createTabButton(imageName: "list.bullet", title: "Plans", index: 3)
                    Spacer()
                    createTabButton(imageName: "person.3", title: "Sharing", index: 4)
                }
                .padding(.horizontal, 30)
                .frame(height: 70)
                //.background(Color.white.shadow(radius: 5))
            }
            .edgesIgnoringSafeArea(.all)

            // Sidebar from the left
            if showingSidebar {
                GeometryReader { geometry in
                    HStack {
                        // Sidebar content
                        SidebarView()
                            .environmentObject(appState)
                            .frame(width: geometry.size.width * 0.7)  // Sidebar width is 70% of the screen width
                            .background(self.backgroundColor)
                            .transition(.move(edge: .leading))  // Sliding in from the left

                        Spacer()  // To capture clicks outside the sidebar to dismiss it
                    }
                    .onTapGesture {
                        withAnimation {
                            showingSidebar = false  // Close sidebar when clicking outside
                        }
                    }
                }
                .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))  // Dim the background
            }
        }.onAppear {
            self.viewModel.appState = appState
            viewModel.fetchBodyInfo()
        }
    }

    // Switch views based on selectedTab
    var content: some View {
        Group {
            switch selectedTab {
            case 0:
                SummaryView()
            case 1:
                SitesView()
            case 2:
                WorkoutView()
            case 3:
                PlansView()
            case 4:
                SharingView()
            default:
                SummaryView()
            }
        }
    }
}

// Sidebar content
struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading) {
            Text("Account Settings")
                .font(.title)
                .padding(.bottom, 50) // Adds spacing below the title

            Button(action: {}) {
                Text("Profile")
                    .font(.headline)
            }
            .padding(.bottom, 30) // Adds spacing below each button

            Button(action: {}) {
                Text("Messages")
                    .font(.headline)
            }
            .padding(.bottom, 30)

            Button(action: {}) {
                Text("Notifications")
                    .font(.headline)
            }
            .padding(.bottom, 50)

            Button(action: {}) {
                Text("Help & Support")
                    .font(.headline)
            }
            .padding(.bottom, 10)
            
            Button(action: {}) {
                Text("Settings")
                    .font(.headline)
            }
            .padding(.bottom, 100)

            Spacer() // Pushes everything above up and the log out button down
            
            Button(action: {
                logout()
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.red) // Make the text color red
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func logout() {
        appState.isLoggedIn = false
    }

}


// TabBarButton component
struct TabBarButton: View {
    var imageName: String
    var title: String
    var isSelected: Bool

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .blue : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

// Placeholder views
/*
struct SummaryView: View {
    var body: some View {
        VStack {
            Text("Summary Page")
                .font(.title)
        }
    }
}


struct SitesView: View {
    var body: some View {
        VStack {
            Text("Sites Page")
                .font(.title)
        }
    }
}
 
struct WorkoutView: View {
    var body: some View {
        VStack {
            Text("Workout Page")
                .font(.title)
        }
    }
}

struct PlansView: View {
    var body: some View {
        VStack {
            Text("Plans Page")
                .font(.title)
        }
    }
}

struct SharingView: View {
    var body: some View {
        VStack {
            Text("Sharing Page")
                .font(.title)
        }
    }
}
 */

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppState()) // Create an instance here
    }
}
