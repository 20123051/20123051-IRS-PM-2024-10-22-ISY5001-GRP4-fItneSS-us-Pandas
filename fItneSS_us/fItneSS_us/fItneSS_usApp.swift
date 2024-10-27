//
//  fItneSS_usApp.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 7/10/24.
//

import SwiftUI
import SwiftData // Ensure this is a valid import for your project

@main
struct fItneSS_usApp: App {
    @StateObject private var appState = AppState() // AppState should be an ObservableObject

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("toSurvey") var toSurvey: Bool = false

    var body: some Scene {
        WindowGroup {
            //appState.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggingIn")
            if appState.isLoggedIn {
                if appState.toSurvey {
                    SurveyView() // Correctly creating an instance of SurveyView
                        .environmentObject(appState) // Correctly applying the environment object
                } else {
                    HomeView() // Instance of HomeView
                        .environmentObject(appState) // Applying the environment object
                }
            } else {
                WelcomeView() // Instance of WelcomeView
                    .environmentObject(appState) // Applying the environment object
            }
        }
    }
}
