//
//  Exercise.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import Foundation

// Data model for an Exercise
struct ExercisePlan: Identifiable {
    var id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var caloriesBurned: Int
}

// Data model for a Workout Plan on a specific date
struct WorkoutPlan: Identifiable {
    var id = UUID()
    var date: Date
    var exercises: [ExercisePlan]
}
