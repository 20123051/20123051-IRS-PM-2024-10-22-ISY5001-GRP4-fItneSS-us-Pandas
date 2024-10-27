//
//  SessionManager.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 18/10/24.
//



import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var toSurvey = false
}


