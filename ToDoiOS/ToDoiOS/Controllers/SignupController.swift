//
//  SignupController.swift
//  ToDoiOS
//
//  Created by Deniz Tutuncu on 10/29/21.
//

import Foundation

class SignupController {
    func signup(completion: @escaping (SignupResponse?) -> Void)  {
        let url = URL(string: "https://ancient-plateau-22374.herokuapp.com/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeRequestData()
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error fetching data: \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Error getting data")
                completion(nil)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let topLevel = try jsonDecoder.decode(TopLevelJSON.self, from: data)
                let data = topLevel.data
                completion(data)
            } catch {
                print("Error decoding JSON: \(error) \(error.localizedDescription)")
                completion(nil)
            }
        }
        dataTask.resume()
    }
}

private func makeRequestData() -> Data {
    let json = [
        "email": "email@example.com",
        "password": "my_password",
    ].compactMapValues { $0 }
    
    let data = ["user" : json]
    return try! JSONSerialization.data(withJSONObject: data)
}
