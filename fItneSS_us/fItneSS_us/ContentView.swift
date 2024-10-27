//
//  ContentView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 7/10/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            HomeView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
