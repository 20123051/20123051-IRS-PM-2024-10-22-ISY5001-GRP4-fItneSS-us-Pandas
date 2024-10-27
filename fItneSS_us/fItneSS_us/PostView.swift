//
//  PostView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 20/10/24.
//


import SwiftUI

struct CreatPostResponse_success: Decodable {
    var message: String
    var post_id: Int
}

struct CreatPostResponse_fail: Decodable {
    var message: String
}

struct PostView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var related_workout = "NA" // Default selection
    let workouts = ["NA", "Yoga", "Cardio", "Strength", "Crossfit", "Pilates"]

    @State private var showingImagePicker = false
    @State private var inputImages: [UIImage] = []
    @State private var postMessage = ""
    @State private var isPosting = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top half for image selection
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(Array(zip(inputImages.indices, inputImages)), id: \.0) { index, img in
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width / 3 - 10, height: geometry.size.width / 3 - 10) // Square shape
                                    .cornerRadius(5)
                                    .overlay(deleteButton(for: index), alignment: .topTrailing)
                            }

                            Button(action: {
                                self.showingImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                }
                                .frame(width: geometry.size.width / 3 - 10, height: geometry.size.width / 3 - 10)
                                .background(Color.secondary.opacity(0.3))
                                .cornerRadius(5)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: geometry.size.height / 3) // Allocate half the height for images
                    
                    // Bottom half for text inputs and submit button
                    VStack {
                        TextField("Title", text: $title)
                            .padding()
                            .background(Color.secondary.opacity(0.3))
                            .cornerRadius(5)
                            .padding([.horizontal, .top])

                        TextEditor(text: $content)
                            .frame(height: geometry.size.height / 3)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(5)
                            .padding(.horizontal)
                        HStack {
                            Text("Related Workout")
                            Picker("Select Workout", selection: $related_workout) {
                                ForEach(workouts, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            //.padding()
                            //.background(Color.secondary.opacity(0.3))
                            .cornerRadius(5)
                            //.padding(.horizontal)
                            
                            Button("Post") {
                                submitPost()
                            }
                            .disabled(inputImages.isEmpty || isPosting)
                            .padding()
                            .background(inputImages.isEmpty || isPosting ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            // Workout Picker
                            
                        }
                        

                    }
                    .frame(height: (geometry.size.height / 2 )+100) // Allocate half the height for text fields and button
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(images: self.$inputImages)
            }
            .alert(isPresented: $isPosting) {
                Alert(title: Text("Post Submission"), message: Text(postMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func deleteButton(for index: Int) -> some View {
        Button(action: {
            inputImages.remove(at: index)
        }) {
            Image(systemName: "xmark.circle.fill")
                .padding(2)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .foregroundColor(.white)
        }
    }

    private func submitPost() {
            guard !title.isEmpty, !content.isEmpty, !related_workout.isEmpty, !inputImages.isEmpty else {
                postMessage = "Please fill in all fields."
                isPosting = true
                return
            }
        
            guard let token = UserDefaults.standard.string(forKey: "logintoken") else {
                postMessage = "Authentication error. Please login again."
                isPosting = true
                return
            }
        
            let url = URL(string: "https://fu.tktonny.top/post")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")  // Set Authorization header
            
            let httpBody = NSMutableData()
            appendFormData(fieldName: "title", fieldValue: title, boundary: boundary, httpBody: httpBody)
            appendFormData(fieldName: "content", fieldValue: content, boundary: boundary, httpBody: httpBody)
            appendFormData(fieldName: "related_workout", fieldValue: related_workout, boundary: boundary, httpBody: httpBody)
            
        
            for (index, image) in inputImages.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    appendFileData(fieldName: "images", fileName: "image\(index).jpg", mimeType: "image/jpeg", fileData: imageData, boundary: boundary, httpBody: httpBody)
                }
            }
            httpBody.appendString("--\(boundary)--")
            
            /*
            for (index, image) in inputImages.enumerated() {
                httpBody.appendString("--\(boundary)\r\n")
                httpBody.appendString("Content-Disposition: form-data; name=\"file\(index)\"; filename=\"image\(index).jpg\"\r\n")
                httpBody.appendString("Content-Type: image/jpeg\r\n\r\n")
                if let imageData = image.jpegData(compressionQuality: 1) {
                    httpBody.append(imageData)
                    httpBody.appendString("\r\n")
                }
            }
            httpBody.appendString("--\(boundary)--")
             */
            //let data = try? JSONEncoder().encode(httpBody)
            
            
            request.httpBody = httpBody as Data
            //print(request.httpBody!)
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            DispatchQueue.main.async {
                self.isPosting = false
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    self.postMessage = "Upload error: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    print("Post submitted successfully!")
                    self.postMessage = "Post submitted successfully!"
                    self.title = ""
                    self.content = ""
                    self.inputImages.removeAll()
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let creatpostResponse = try decoder.decode(CreatPostResponse_fail.self, from: data)
                        print("Failed to submit post.\(creatpostResponse.message)")
                        self.postMessage = "Failed to submit post."
                    } catch {
                        print("JSON decoding error: \(error.localizedDescription)")
                        self.postMessage = "Error processing the request."
                    }
                }
            }
        }.resume()
        }
    private func appendFormData(fieldName: String, fieldValue: String, boundary: String, httpBody: NSMutableData) {
        httpBody.appendString("--\(boundary)\r\n")
        httpBody.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n")
        httpBody.appendString("\(fieldValue)\r\n")
    }

    private func appendFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, boundary: String, httpBody: NSMutableData) {
        httpBody.appendString("--\(boundary)\r\n")
        httpBody.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        httpBody.appendString("Content-Type: \(mimeType)\r\n\r\n")
        httpBody.append(fileData)
        httpBody.appendString("\r\n")
    }
    private func loadImage() {
        // Load images after picking
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.images.append(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// Preview
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
