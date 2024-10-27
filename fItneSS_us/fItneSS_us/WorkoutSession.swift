//
//  WorkoutSession.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//

import Foundation


struct WorkoutSession: Identifiable {
    var id = UUID()  // Unique ID for each workout
    var date: Date
    var workoutType: String
    var duration: Int  // in minutes
    var exercises: [Exercise]
}

struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var sets: Int
    var reps: Int
}
