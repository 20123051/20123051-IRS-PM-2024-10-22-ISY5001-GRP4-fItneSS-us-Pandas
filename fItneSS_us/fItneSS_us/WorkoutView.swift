//
//  WorkoutView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var appState: AppState
    @State private var workoutInstructions = [
        "Start with 15 push-ups",
        "Do 3 sets of squats (12 reps each)",
        "Hold a plank for 1 minute",
        "Finish with a 5-minute cooldown stretch"
    ]
    
    @State private var currentStep = 0

    var body: some View {
        VStack {
            // Camera view in the top half
            CameraView()
                .frame(height: UIScreen.main.bounds.height * 0.5)  // Half screen height for camera
                .background(Color.black)

            // Workout instructions in the bottom half
            VStack {
                Text("Workout Instructions")
                    .font(.title)
                    .padding(.top)

                if currentStep < workoutInstructions.count {
                    Text(workoutInstructions[currentStep])
                        .font(.headline)
                        .padding()
                } else {
                    Text("Workout Complete!")
                        .font(.headline)
                        .padding()
                }

                Spacer()

                // Finish and Quit buttons
                HStack {
                    Button(action: {
                        // Quit action
                        // Implement the behavior when the user quits the workout
                    }) {
                        Text("Quit")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Finish the current workout step or end the workout
                        if currentStep < workoutInstructions.count - 1 {
                            currentStep += 1
                        } else {
                            // End workout
                        }
                    }) {
                        Text(currentStep < workoutInstructions.count ? "Next" : "Finish")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height * 0.5)  // Half screen height for instructions
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    WorkoutView()
}
