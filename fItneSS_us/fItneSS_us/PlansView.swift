//
//  PlansView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI

struct PlansView: View {
    @EnvironmentObject var appState: AppState
    @State private var showDetailedButtons = false
    @State var errorMessage: String = ""
    @State private var message: String = ""

    @State private var workoutPlans: [WorkoutPlan] = [
        WorkoutPlan(date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 10))!,
                    exercises: [
                        ExercisePlan(name: "Push-ups", sets: 3, reps: 15, caloriesBurned: 150),
                        ExercisePlan(name: "Squats", sets: 4, reps: 12, caloriesBurned: 200)
                    ]),
        WorkoutPlan(date: Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 11))!,
                    exercises: [
                        ExercisePlan(name: "Running", sets: 1, reps: 0, caloriesBurned: 400)
                    ])
    ]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingMonthlyView = false

    var body: some View {
        VStack {
            // Month Navigation
            HStack {
                Button(action: {
                    // Go to previous month
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Text("< Previous")
                                .frame(minWidth: 80, alignment: .leading)
                                .padding()
                }

                Spacer()

                Text(formattedMonth(date: currentMonth))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)  // Ensures the text is always centered


                Spacer()

                Button(action: {
                    // Go to next month
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Text("Next >")
                                .frame(minWidth: 80, alignment: .trailing)
                                .padding()
                }
                
            }
            .padding(.horizontal)

            // Calendar Grid
            let daysInMonth = numberOfDaysInMonth(date: currentMonth)
            let firstDayOfMonth = firstDayOfMonth(date: currentMonth)
            let totalDays = daysInMonth + firstDayOfMonth
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7) // 7 days a week

            LazyVGrid(columns: columns) {
                // Days of the Week Header
                ForEach(0..<7, id: \.self) { index in
                    Text(weekDays[index])
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                
                // Empty Spaces for the start of the month
                ForEach(0..<firstDayOfMonth, id: \.self) { _ in
                    Text("") // Empty cell
                        .frame(maxWidth: .infinity)
                }

                // Days of the Month
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonthDate())!
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text("\(day)")
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            .padding(.bottom)
                            .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.5) : Color.clear)
                            .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding()

            // Workout Plans for the selected date
            if let plan = workoutPlans.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                VStack(alignment: .leading) {
                    Text("Workout Plan for \(formattedDate(date: selectedDate))")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.headline)
                    ForEach(plan.exercises) { exercise in
                        VStack(alignment: .leading) {
                            Text("\(exercise.name)")
                            Text("Sets: \(exercise.sets), Reps: \(exercise.reps), Calories: \(exercise.caloriesBurned)")
                                .font(.subheadline)
                                //.frame(maxWidth: .infinity)
                        }
                        .padding(2)
                    }
                }
                .padding() // Adjust the padding to change the internal spacing
                .frame(maxWidth: .infinity) // Makes the VStack take the full width available
                //.background(Color.white) // Keeping the background color
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal) // Reduces horizontal padding to allow more width for content
                NavigationLink(destination: PlanedView().onAppear {
                }) {
                    Text("All Workout Plans")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                        .padding(.horizontal,100)
                }
            } else {
                Text("No workout plan for \(formattedDate(date: selectedDate))")
                    .padding()
                if showDetailedButtons {
                    VStack {
                        NavigationLink(destination: LWView().onAppear {
                        }) {
                            Text("Lose Weight")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 5)
                                .padding(.horizontal,100)
                        }
                        NavigationLink(destination: JWView().onAppear {
                        }) {
                            Text("Just Workout")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal,100)
                        }
                    }
                    .padding(.vertical, 5)
                    .transition(.scale)
                }else{
                    Button("Get Workout Plan") {
                        withAnimation {
                            showDetailedButtons.toggle()  // Toggle the state to show detailed buttons
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 100)
                }
                NavigationLink(destination: PlanedView().onAppear {
                }) {
                    Text("All Workout Plans")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                        .padding(.horizontal,100)
                }
            }

            Spacer()
            
        }
        .navigationBarTitle("Workout Plans", displayMode: .inline)
    }
    
    func numberOfDaysInMonth(date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }

    func firstDayOfMonth(date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDay = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: firstDay) - 1 // Adjust for 0 index
    }

    func firstDayOfMonthDate() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        return Calendar.current.date(from: components)!
    }

    func formattedMonth(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    // Days of the week
    private var weekDays: [String] {
        return Calendar.current.shortWeekdaySymbols.map { $0.prefix(1).uppercased() }
    }
}

import Foundation

struct WorkoutRecommendationResponse1: Codable, Identifiable, Hashable {
    let id = UUID()
    var message: String
    var input_params: InputParams
    var single_plan: SinglePlan
    var mixed_plan: MixedPlan
    
    struct SinglePlan: Codable, Hashable {
        var description: String
        var activities: [Activities]
        
        struct Activities: Codable, Hashable {
            var name: String
            var heart_rate: Int
            var total_days: Int
            var stages: [Stage]
            var initial_calories: Double
            
            struct Stage: Codable, Hashable {
                var weight: Double
                var minutes: Int
                var start_day: Int
                var days: Int
            }
        }
    }
    
    struct InputParams: Codable, Hashable {
        var gender: String
        var age: Int
        var height: Double
        var current_weight: Double
        var target_weight: Double
    }
    struct MixedPlan: Codable, Hashable {
        var description: String
        var plan: [Plan]
        
        struct Plan: Codable, Hashable {
            var name: String
            var total_days: Int
            var stages: [Stage]
            var initial_calories: Calories
            var plan: Plan
            var heart_rates: HeartRates
            
            struct Stage: Codable, Hashable {
                var weight: Double
                var minutes: Int
                var start_day: Int
                var days: Int
            }
            struct Calories: Codable, Hashable {
                var Jumping_Jacks: Double
                var Jogging: Double
                var Swimming: Double
                var Walking: Double
                var Sit_ups: Double
            }
            struct Plan: Codable, Hashable {
                var Jumping_Jacks: Int
                var Jogging: Int
                var Swimming: Int
                var Walking: Int
                var Sit_ups: Int
            }
            struct HeartRates: Codable, Hashable {
                var Jumping_Jacks: Int
                var Jogging: Int
                var Swimming: Int
                var Walking: Int
                var Sit_ups: Int
            }
        }
    }
}

struct WorkoutRecommendationResponse2: Codable, Identifiable, Hashable {
    let id = UUID()
    var user_info: UserInfo
    var recommendations: Recommendations

    struct UserInfo: Codable, Hashable {
        var age: Int
        var gender: String
        var weight: Double
        var height: Double
        var experience_level: Int
    }

    struct Recommendations: Codable, Hashable {
        var workouts: [WorkoutDetail]
    }

    struct WorkoutDetail: Codable, Hashable {
        var workout: String
        var avg_bpm: Int
        var frequency: Int
        var duration: Double
        var water_intake: Double
        var exercises: [String]
    }
}

struct getPlanResponse: Decodable, Hashable {
    let message: String
}
func loadWorkoutPlansJW() -> [WorkoutRecommendationResponse2] {
    if let data = UserDefaults.standard.data(forKey: "workoutPlansJW") {
        let decoder = JSONDecoder()
        do {
            let plans = try decoder.decode([WorkoutRecommendationResponse2].self, from: data)
            return plans
        } catch {
            print("Unable to Decode Array of Workout Plans for Just Workout(\(error))")
        }
    }
    return []
}
func loadWorkoutPlansLW() -> [WorkoutRecommendationResponse1] {
    if let data = UserDefaults.standard.data(forKey: "workoutPlansLW") {
        let decoder = JSONDecoder()
        do {
            let plans = try decoder.decode([WorkoutRecommendationResponse1].self, from: data)
            return plans
        } catch {
            print("Unable to Decode Array of Workout Plans for Lose Weight(\(error))")
        }
    }
    return []
}

struct PlanedView: View {
    @EnvironmentObject var appState: AppState
    @State private var planLW: [WorkoutRecommendationResponse1] = []
    @State private var planJW: [WorkoutRecommendationResponse2] = []
    @State private var selectedPlanType = "Lose Weight Plans"
    var planTypes = ["Lose Weight Plans", "Just Workout Plans"]


    var body: some View {
        VStack {
            Picker("Select Plan Type", selection: $selectedPlanType) {
                ForEach(planTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ScrollView {
                
                if selectedPlanType == "Lose Weight Plans" {
                    VStack{
                        ForEach(planLW, id: \.self) { plan in
                            Text("\(plan.message)(current:\(plan.input_params.current_weight), goal:\(plan.input_params.target_weight))")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                //.padding(.horizontal)
                            ForEach(plan.mixed_plan.plan, id: \.self) { workout in
                                Text("Duration * \(workout.plan.Jumping_Jacks)/week:\(workout.total_days)days")
                                Text("Jumping Jacks:\nBPM:\(workout.heart_rates.Jumping_Jacks), Calories:\(workout.initial_calories.Jumping_Jacks*2)Kcal/h")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                Text("Jogging: * \(workout.plan.Jogging)/week\nBPM:\(workout.heart_rates.Jogging), Calories:\(workout.initial_calories.Jogging*2)Kcal/h")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                Text("JSwimming * \(workout.plan.Swimming)/week:\nBPM:\(workout.heart_rates.Swimming), Calories:\(workout.initial_calories.Swimming*2)Kcal/h")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                Text("Walking: * \(workout.plan.Walking)/week\nBPM:\(workout.heart_rates.Walking), Calories:\(workout.initial_calories.Walking*2)Kcal/h")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                Text("Sit ups: * \(workout.plan.Sit_ups)/week\nBPM:\(workout.heart_rates.Sit_ups), Calories:\(workout.initial_calories.Sit_ups*2)Kcal/h")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .padding(.bottom, 20)
                } else {
                    VStack{
                        ForEach(planJW, id: \.self) { plan in
                            ForEach(plan.recommendations.workouts, id: \.self) { workout in
                                Text("\(workout.workout): \(workout.avg_bpm), \(workout.duration*60)min, \(workout.frequency)/week")
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                            //.padding(10)
                        }
                        
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            loadPlans()
        }
    }
    private func loadPlans() {
        self.planLW = loadWorkoutPlansLW()
        self.planJW = loadWorkoutPlansJW()
    }
}

struct LWView: View {
    @EnvironmentObject var appState: AppState
    @State private var lw: WorkoutRecommendationResponse1?


    var body: some View {
        ScrollView {
            if let plan = lw {
                VStack{
                    Text("Plan Overview")
                        .font(.headline)
                        .padding()
                        //.background(Color.gray.opacity(0.1))
                        //.cornerRadius(10)
                        //.padding(.horizontal)
                    Text("\(plan.message)")
                                    .padding(.bottom)
                    Text("\(plan.single_plan.description)")
                        .italic()
                        .padding(.horizontal)
                    VStack{
                        ForEach(plan.single_plan.activities, id: \.self) { singleactivite in
                            Text("\(singleactivite.name): BPM: \(singleactivite.heart_rate), Duration: \(singleactivite.total_days)")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .frame(maxWidth: .infinity)
                                //.cornerRadius(10)
                                .padding(.horizontal)
                            ForEach(singleactivite.stages, id: \.self) { stage in
                                Text("From day \(stage.start_day) to day \(stage.days+stage.start_day) \nWeight:\(stage.weight) \(stage.minutes) per day")
                                    .padding(3)
                                    //.padding(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    Text("\(plan.mixed_plan.description)")
                        .italic()
                        .padding(.horizontal)
                    VStack{
                        ForEach(plan.mixed_plan.plan, id: \.self) { workout in
                            Text("Duration * \(workout.plan.Jumping_Jacks)/week:\(workout.total_days)days")
                            Text("Jumping Jacks:\nBPM:\(workout.heart_rates.Jumping_Jacks), Calories:\(workout.initial_calories.Jumping_Jacks*2)Kcal/h")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Text("Jogging: * \(workout.plan.Jogging)/week\nBPM:\(workout.heart_rates.Jogging), Calories:\(workout.initial_calories.Jogging*2)Kcal/h")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Text("JSwimming * \(workout.plan.Swimming)/week:\nBPM:\(workout.heart_rates.Swimming), Calories:\(workout.initial_calories.Swimming*2)Kcal/h")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Text("Walking: * \(workout.plan.Walking)/week\nBPM:\(workout.heart_rates.Walking), Calories:\(workout.initial_calories.Walking*2)Kcal/h")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            Text("Sit ups: * \(workout.plan.Sit_ups)/week\nBPM:\(workout.heart_rates.Sit_ups), Calories:\(workout.initial_calories.Sit_ups*2)Kcal/h")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                    }
                }
            } else {
                Text("Wait a second...")
            }
        }.onAppear(){
            getLoseWeight()
        }
    }
    func getLoseWeight() {
        guard let url = URL(string: "https://fu.tktonny.top/estimate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "logintoken") else {
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WorkoutRecommendationResponse1.self, from: data)
                DispatchQueue.main.async {
                    lw = response
                    appendWorkoutPlanLW(newPlan: response)
                    print("Workouts: \(response.message)")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    func saveWorkoutPlansLW(plans: [WorkoutRecommendationResponse1]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(plans)
            UserDefaults.standard.set(data, forKey: "workoutPlansLW")
        } catch {
            print("Unable to Encode Array of Workout Plans for Lose Weight(\(error))")
        }
    }
    func loadWorkoutPlansLW() -> [WorkoutRecommendationResponse1] {
        if let data = UserDefaults.standard.data(forKey: "workoutPlansLW") {
            let decoder = JSONDecoder()
            do {
                let plans = try decoder.decode([WorkoutRecommendationResponse1].self, from: data)
                return plans
            } catch {
                print("Unable to Decode Array of Workout Plans for Lose Weight(\(error))")
            }
        }
        return []
    }
    func appendWorkoutPlanLW(newPlan: WorkoutRecommendationResponse1) {
        var existingPlans = loadWorkoutPlansLW() // Load existing plans
        existingPlans.append(newPlan)          // Append new plan
        saveWorkoutPlansLW(plans: existingPlans) // Save updated plans
        print("Appended \(newPlan) to Lose Weight Plans")
    }
}

struct JWView: View {
    @EnvironmentObject var appState: AppState
    @State private var jw: WorkoutRecommendationResponse2?

    var body: some View {
        ScrollView {
            if let plan = jw {
                VStack{
                    Text("Plan Overview")
                        .font(.headline)
                        .padding()
                    VStack{
                        ForEach(plan.recommendations.workouts, id: \.self) { workout in
                            Text("\(workout.workout): \(workout.avg_bpm), \(workout.duration*60)min, \(workout.frequency)/week")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("Wait a second...")
            }
        }.onAppear(){
            getJustWorkout()
        }
    }
    func getJustWorkout() {
        guard let url = URL(string: "https://fu.tktonny.top/recommend_workout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "logintoken") else {
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WorkoutRecommendationResponse2.self, from: data)
                DispatchQueue.main.async {
                    jw = response
                    appendWorkoutPlanJW(newPlan: response)

                    print("Workouts: \(response.recommendations.workouts.map { $0.workout })")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    func saveWorkoutPlansJW(plans: [WorkoutRecommendationResponse2]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(plans)
            UserDefaults.standard.set(data, forKey: "workoutPlansJW")
        } catch {
            print("Unable to Encode Array of Workout Plans for Just Workout(\(error))")
        }
    }
    func loadWorkoutPlansJW() -> [WorkoutRecommendationResponse2] {
        if let data = UserDefaults.standard.data(forKey: "workoutPlansJW") {
            let decoder = JSONDecoder()
            do {
                let plans = try decoder.decode([WorkoutRecommendationResponse2].self, from: data)
                return plans
            } catch {
                print("Unable to Decode Array of Workout Plans for Just Workout(\(error))")
            }
        }
        return []
    }
    func appendWorkoutPlanJW(newPlan: WorkoutRecommendationResponse2) {
        var existingPlans = loadWorkoutPlansJW() // Load existing plans
        existingPlans.append(newPlan)          // Append new plan
        saveWorkoutPlansJW(plans: existingPlans) // Save updated plans
        print("Appended \(newPlan) to Just Workout Plans")
    }
}


#Preview {
    PlansView()
}
