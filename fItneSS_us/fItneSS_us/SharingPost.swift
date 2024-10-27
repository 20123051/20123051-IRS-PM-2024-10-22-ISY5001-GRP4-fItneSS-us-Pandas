//
//  Post 2.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//

import Foundation


struct Users: Identifiable {
    var id: Int
    var username: String
    var email: String
    var password: String
    //var first_name: String
    //var last_name: String
    //var profile_image: String
    //var is_admin: Bool
    //var is_active: Bool
}

struct Post: Identifiable, Codable{
    var id: Int
    var user_id: Int
    var title: String
    var text: String
    var related_workout: String
    var views: Int
    var likes: Int
    var collections: Int
    var image: String // 预览图
}

struct Comments: Identifiable {
    var id: Int
    var post_id: Int
    var user_id: Int
    var text: String
}

struct LikedPosts {
    var user_id: Int
    var post_id: Int
}

struct CollectedPosts {
    var user_id: Int
    var post_id: Int
}

struct ViewedPosts {
    var user_id: Int
    var post_id: Int
}


struct UserFollows {
    var follower_id: Int
    var followed_id: Int
}

struct WorkoutInformation: Identifiable {
    var id: Int
    var user_id: Int
    var workout_type: String
    var duration: Int
    var calories_burned: Int
    var date: String
    //var name: String
    //var description: String
    //var image: String
}

struct Images: Identifiable {
    var id: Int
    var file_name: String
    var file_path: String
    var file_type: String
    var file_size: Int
}

struct PostImages {
    var post_id: Int
    var image_id: Int
}
