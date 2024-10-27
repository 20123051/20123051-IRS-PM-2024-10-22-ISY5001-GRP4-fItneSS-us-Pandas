//
//  Post.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 20/10/24.
//


import SwiftUI

struct Comment: Identifiable {
    let id = UUID()
    let name: String
    let text: String
    let date: Date
}

struct PostDetail: Identifiable {
    var id: Int
    var title: String
    var text: String
    var relatedWorkout: String
    var views: Int
    var likes: Int
    var collections: Int
    var images: [UIImage]
    var comments: [Comment]
}

extension PostDetail {
    static var defaultPost: PostDetail {
        PostDetail(
            id: 1,
            title: "Hello, World!",
            text: "This is a sample post to demonstrate the layout of a PostDetailView.",
            relatedWorkout: "Yoga",
            views: 100,
            likes: 25,
            collections: 10,
            images: [UIImage(systemName: "photo")!, UIImage(systemName: "photo.fill")!],
            comments: [
                Comment(name: "Jane Doe", text: "Great post!", date: Date()),
                Comment(name: "John Smith", text: "Thanks for sharing.", date: Date())
            ]
        )
    }
}

struct PostDetailView: View {
    @State var post: PostDetail
    @State private var newCommentText = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        TabView {
                            ForEach(post.images, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height / 2)
                                    .cornerRadius(10)
                                    .padding()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: geometry.size.height / 2)

                        Text(post.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding([.leading, .trailing, .top])

                        Text(post.text)
                            .font(.body)
                            .padding()

                        HStack {
                            Button(action: {
                                post.likes += 1
                            }) {
                                Label("\(post.likes)", systemImage: "heart")
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Spacer()

                            Button(action: {
                                post.collections += 1
                            }) {
                                Label("\(post.collections)", systemImage: "folder")
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Spacer()

                            Label("\(post.views)", systemImage: "eye")
                        }
                        .padding()
                        .font(.subheadline)

                        VStack(alignment: .leading) {
                            Text("Comments")
                                .font(.headline)
                                .padding(.top)
                            ForEach(post.comments) { comment in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(comment.name)
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text(comment.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(comment.text)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                HStack {
                    TextField("Add a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Post") {
                        let newComment = Comment(name: "Current User", text: newCommentText, date: Date())
                        post.comments.append(newComment)
                        newCommentText = ""
                    }
                    .disabled(newCommentText.isEmpty)
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: PostDetail.defaultPost)
    }
}
