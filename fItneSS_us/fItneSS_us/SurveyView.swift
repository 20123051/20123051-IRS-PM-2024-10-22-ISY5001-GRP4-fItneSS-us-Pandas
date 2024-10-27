//
//  SurveyView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 21/10/24.
//


import SwiftUI

struct BodyInfo: Encodable{
    var gender: String = "Male"
    var age: Int = 23//后续修改为数据库记录出生年份 计算年龄避免每年修改
    var height: Double = 170.0
    var current_weight: Double = 62.0
    var target_weight: Double = 60.0
    var experience_level: String = "Beginner"
    
    // Computed property to return gender in lowercase
    var formattedGender: String {
        gender.lowercased()
    }

    // Computed property to convert experience levels to numerical values
    var experienceLevelNumeric: String {
        switch experience_level {
        case "Intermediate":
            return "2"
        case "Advanced":
            return "3"
        default:
            return "1"
        }
    }
    
    // Encodable conformance to send properly formatted data to the server
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formattedGender, forKey: .gender)
        try container.encode(age, forKey: .age)
        try container.encode(height, forKey: .height)
        try container.encode(current_weight, forKey: .current_weight)
        try container.encode(target_weight, forKey: .target_weight)
        try container.encode(experienceLevelNumeric, forKey: .experience_level)
    }

    enum CodingKeys: String, CodingKey {
        case gender, age, height, current_weight, target_weight, experience_level
    }
}

struct SurveyView: View {
    @EnvironmentObject var appState: AppState
    @State private var bodyInfo = BodyInfo()
    @State private var message: String = ""
    let genders = ["Male", "Female"]
    let experienceLevels = ["Beginner", "Intermediate", "Advanced"]
    let ages = Array(20...70)
    let heights = stride(from: 100.0, to: 250.0, by: 1).map { $0 }
    let weights = stride(from: 30.0, to: 200.0, by: 1).map { $0 }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    Picker("Gender", selection: $bodyInfo.gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("Age", selection: $bodyInfo.age) {
                        ForEach(ages, id: \.self) { age in
                            Text("\(age) years").tag(age)
                        }
                    }

                    Picker("Height (cm)", selection: $bodyInfo.height) {
                        ForEach(heights, id: \.self) { height in
                            Text("\(height, specifier: "%.1f") cm").tag(height)
                        }
                    }

                    Picker("Current Weight (kg)", selection: $bodyInfo.current_weight) {
                        ForEach(weights, id: \.self) { weight in
                            Text("\(weight, specifier: "%.1f") kg").tag(weight)
                        }
                    }

                    Picker("Target Weight (kg)", selection: $bodyInfo.target_weight) {
                        ForEach(weights, id: \.self) { weight in
                            Text("\(weight, specifier: "%.1f") kg").tag(weight)
                        }
                    }

                    Picker("Experience Level", selection: $bodyInfo.experience_level) {
                        ForEach(experienceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    Button("Submit") {
                        submitBodyInfo()
                    }
                }
            }
            .navigationBarTitle("Survey", displayMode: .inline)
        }
    }

    func submitBodyInfo() {
        guard let url = URL(string: "https://fu.tktonny.top/body_info") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "logintoken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            message = "Authentication token not found"
            return
        }
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(bodyInfo)
        } catch {
            message = "Failed to encode body information"
            return
        }
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(bodyInfo)
        } catch {
            message = "Failed to encode body information"
            return
        }

        //print(bodyInfo)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Login error: \(error.localizedDescription)"
                    //self.isLoggingIn = false
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    self.message = "Failed to receive HTTP response"
                    //self.isLoggingIn = false
                    return
                }
                
                if statusCode == 201 {
                    do{
                        appState.toSurvey = false
                    }catch {
                        print("json error: \(error)")
                        //self.isLoggingIn = false
                    }
                }else{
                    do{
                        let decoder = JSONDecoder()
                        let serverResponse = try decoder.decode(SurveyResponse.self, from: data)
                        print("FAILURE\(serverResponse)")
                        self.message = (serverResponse.message)
                        self.message = "Failed to submit information"
                    }catch{
                        print("json error: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct SurveyResponse: Decodable {
    let message: String
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
