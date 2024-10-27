//
//  SummaryView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var workoutHistory: [WorkoutSession] = [
        WorkoutSession(date: Date(), workoutType: "Strength Training", duration: 45, exercises: [
            Exercise(name: "Squats", sets: 4, reps: 10),
            Exercise(name: "Bench Press", sets: 3, reps: 12)
        ]),
        WorkoutSession(date: Date().addingTimeInterval(-86400), workoutType: "Cardio", duration: 30, exercises: [
            Exercise(name: "Running", sets: 1, reps: 0)
        ])
    ]

    var body: some View {
        VStack {
            /*Text("Workout History")
                .font(.largeTitle)
                .padding()
            */
            List(workoutHistory) { session in
                NavigationLink(destination: WorkoutDetailView(session: session)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.workoutType)
                                .font(.headline)
                            Text("Duration: \(session.duration) mins")
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(session.date, style: .date)
                    }
                }
            }
        }.navigationBarTitle("Workout History", displayMode: .inline)
        .padding()
    }
}

struct WorkoutDetailView: View {
    var session: WorkoutSession

    var body: some View {
        VStack(alignment: .leading) {
            Text("Workout Type: \(session.workoutType)")
                .font(.title)
                .padding(.bottom)

            Text("Date: \(session.date, style: .date)")
                .font(.headline)
                .padding(.bottom)

            Text("Duration: \(session.duration) mins")
                .font(.subheadline)
                .padding(.bottom)

            Text("Exercises")
                .font(.headline)
                .padding(.bottom)

            ForEach(session.exercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.subheadline)
                    Text("Sets: \(exercise.sets), Reps: \(exercise.reps)")
                        .font(.caption)
                }
                .padding(.bottom)
            }

            Spacer()
        }
        
        .padding()
    }
}

#Preview{SummaryView()}
