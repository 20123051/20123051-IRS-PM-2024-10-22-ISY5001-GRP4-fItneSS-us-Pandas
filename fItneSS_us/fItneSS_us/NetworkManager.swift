//
//  NetworkManager.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 18/10/24.
//


import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    func fetchData(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed with HTTP status code"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            completion(.success(data))
        }
        task.resume()
    }
}
extension NetworkManager {
    func login(login: String, password: String, completion: @escaping (Bool) -> Void) {
        // Implement API call to login
        completion(true)  // Mock implementation
    }
    
    func signup(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        // Implement API call to signup
        completion(true)  // Mock implementation
    }
}
