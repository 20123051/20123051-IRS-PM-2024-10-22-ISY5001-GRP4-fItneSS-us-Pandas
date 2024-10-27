//
//  Post.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI
import Foundation
import Combine


struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme // Access the color scheme from the environment
    @State private var posts: [Message.Posts_get] = []
    private var postsService = PostsService()

    var body: some View {
        VStack(spacing: 0) {
            // ScrollView to enable scrolling
            ScrollView {
                // Grid Layout for Posts
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(posts, id: \.id) { post in
                        NavigationLink(destination: PostDetailView(post: PostDetail.defaultPost))
                        {
                            VStack {
                                AsyncImage(url: URL(string: "https://fu.tktonny.top/img/f64fa1b9-d002-41ed-9ca9-0c9bcc033fb0_image0.jpg")) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                // Post Title
                                Text(post.title)
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .foregroundColor(colorScheme == .dark ? .white : .black) // Conditionally set the color based on the color scheme
                                
                                // Post Description
                                Text("Author:\(post.author)")
                                    .foregroundColor(colorScheme == .dark ? .white : .gray) // Conditionally set the color based on the color scheme
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                
                                // Like Count
                                Text("\(post.likes) Likes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Divider()  // Separator between posts
                            }
                            //.background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            postsService.fetchPosts { fetchedPosts in
                self.posts = fetchedPosts
            }
        }
    }
}

class PostsService {
    func fetchPosts(completion: @escaping ([Message.Posts_get]) -> Void) {
        guard let url = URL(string: "https://fu.tktonny.top/posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "logintoken") else {
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            //print("Response: \(response?.debugDescription ?? "Unknown response")")
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let decoder = JSONDecoder()
                let posts = try decoder.decode(Message.self, from: data)
                DispatchQueue.main.async {
                    let posts1 = posts.posts
                    completion(posts1)
                    print("Fetched posts: \(posts)")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}

struct Message: Codable, Hashable{
    var posts: [Posts_get]
    var total: Int
    var pages: Int
    var current_page: Int
    
    struct Posts_get: Codable, Hashable{
        var id: Int
        var title: String
        var text: String?
        var related_workout: String
        var views: Int
        var likes: Int
        var collections: Int
        var created_at: String
        var author: String
    }
}
/*
struct ImageModel: Codable, Identifiable {
    var id: Int
    var fileName: String
    var fileType: String
    var fileSize: Int
    var uploadDate: String
    var metadata: [String: Any]?
}

class ImageService {
    var cancellables = Set<AnyCancellable>()

    func getImages(postId: Int, completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        guard let url = URL(string: "https://fu.tktonny.top/images?post_id=\(postId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "logintoken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [ImageModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error in getImages: \(error)")
                    }
                },
                receiveValue: { images in
                    completion(.success(images))
                }
            )
            .store(in: &cancellables)
    }
}
*/
#Preview {
    SharingView()
}
