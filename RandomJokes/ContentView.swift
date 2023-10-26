//
//  ContentView.swift
//  RandomJokes
//
//  Created by Rahul Verma on 11/06/23.
//

import SwiftUI

enum jokeError: Error {
    case URLnotcorrect
    case InvalidResponse
    case jsonNoParsable
    case unexpectedError
}

struct ContentView: View {
    @State var joke: jokeInstance?
    var url: String = "https://icanhazdadjoke.com/"
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack {
                Text(joke?.joke ?? "No jokes yet")
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                Button("Get Joke", action: {
                    getJoke { result in
                        switch result {
                        case .success(let joke):
                            self.joke = joke  // Handle the retrieved joke
                        case .failure(let error):
                            print(error)  // Handle the error
                        }
                    }
                }).padding(3)
            }
        }
    }
    
    func getJoke(completion: @escaping (Result<jokeInstance, Error>) -> Void) {
        guard let url = URL(string: "\(url)") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(jokeInstance.self, from: data)
                    completion(.success(res))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "No data received", code: 0, userInfo: nil)
                completion(.failure(error))
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct jokeInstance: Codable {
    let id: String
    let joke: String
    let status: Int
}
