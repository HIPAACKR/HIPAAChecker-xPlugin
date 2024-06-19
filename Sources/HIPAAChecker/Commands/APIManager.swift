import Foundation
import HIPAACheckerCore


enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

public struct APIManager {
    
    // Define a completion handler typealias
    typealias AuthenticationCompletion = (Result<String?, NetworkError>) -> Void
    typealias GetRulesCompletion = (Result<Data?, NetworkError>) -> Void
    typealias GetProjectInfoCompletion = (Result<String?, NetworkError>) -> Void
    typealias HIPAACheckerResultsCompletion = (Result<Bool?, NetworkError>) -> Void

    func authenticate(email: String, password: String, completion: @escaping AuthenticationCompletion) {
        // Define the URL for the authentication endpoint
        let urlString = "https://hipaachecker.health/api/v1/sessions.json"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
        ]

        // Convert the request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(.requestFailed(NSError(domain: "SerializationError", code: 0, userInfo: nil))))
            return
        }

        // Set the request body
        request.httpBody = jsonData

        // Create a URLSession
        let session = URLSession.shared

        // Create a URLSessionDataTask to perform the request
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Parse the token from the response data
                if let responseData = data,
                   let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []),
                   let jsonDict = jsonResponse as? [String: Any],
                   let token = jsonDict["jwt_token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } else {
                completion(.success(nil))
            }
        }

        // Start the URLSessionDataTask
        task.resume()
    }
    
    func getRules(_ token: String, completion: @escaping GetRulesCompletion) {
        // Define the URL for the authentication endpoint
        let urlString = "https://hipaachecker.health/api/v1/rules"
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            completion(.failure(.invalidURL))
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Create a URLSession
        let session = URLSession.shared

        // Create a URLSessionDataTask to perform the request
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response
            if let error = error {
                print("Error:", error)
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                print("Authentication successful")
                print(httpResponse)
                    guard let responseData = data else {
                        print("No data received")
                        completion(.failure(.invalidResponse))
                        return
                    }
                completion(.success(responseData))

            } else if httpResponse.statusCode == 401 {
                completion(.failure(.requestFailed(NSError(domain: "Authentication failed. Please try with correct credentials!", code: 0, userInfo: nil))))
                print("Authentication failed with status code:", httpResponse.statusCode)

            }
            else{
                print("Authentication failed with status code:", httpResponse.statusCode)
//                completion(.failure(.invalidResponse))
                completion(.failure(.requestFailed(NSError(domain: "Server error!", code: 0, userInfo: nil))))

            }
        }

        // Start the URLSessionDataTask
        task.resume()
    }
    func getProjectInformation(name: String, bundle: String, token: String, completion: @escaping GetProjectInfoCompletion) {
        // Define the URL for the authentication endpoint
        let urlString = "https://hipaachecker.health/api/v1/ios/user_uploads"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Create the request body
        let requestBody: [String: Any] = [
            "project_name": name,
            "project_identifier": bundle
        ]

        // Convert the request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(.requestFailed(NSError(domain: "SerializationError", code: 0, userInfo: nil))))
            return
        }

        // Set the request body
        request.httpBody = jsonData

        // Create a URLSession
        let session = URLSession.shared

        // Create a URLSessionDataTask to perform the request
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Parse the token from the response data
                if let responseData = data,
                   let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []),
                   let jsonDict = jsonResponse as? [String: Any],
                   let projectId = jsonDict["id"] as? Int {
                    print(jsonDict)
                    completion(.success("\(projectId)"))
                } else {
                    completion(.failure(.invalidResponse))
                }
            }
            else if httpResponse.statusCode == 401 {
                completion(.failure(.requestFailed(NSError(domain: "Authentication failed. Please try with correct credentials!", code: 0, userInfo: nil))))
                print("Authentication failed with status code:", httpResponse.statusCode)
                
            }
            else {
                completion(.failure(.requestFailed(NSError(domain: "Server error!", code: 0, userInfo: nil))))
            }
        }

        // Start the URLSessionDataTask
        task.resume()
    }
    
    func postHIPAACheckerResults(projectId: String, result: [String:Any], token: String, completion: @escaping HIPAACheckerResultsCompletion) {
        // Define the URL for the authentication endpoint
        let urlString = "https://hipaachecker.health/api/v1/ios/analyzed_results"
        // Create URL components
        var urlComponents = URLComponents(string: urlString)

        // Create a query item with the parameter
        let queryItem = URLQueryItem(name: "user_upload_id", value: projectId)

        // Add the query item to the URL components
        urlComponents?.queryItems = [queryItem]

        // Construct the URL
        guard let url = urlComponents?.url else {
            print("Failed to construct URL")
            completion(.failure(.invalidURL))
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Create the request body
        
//        print(result)
        var requestBody = [String: Any]()
        requestBody["analyzed_results"] = result as Any

        print(requestBody)
        
        // Convert the request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(.requestFailed(NSError(domain: "SerializationError", code: 0, userInfo: nil))))
            return
        }

        // Set the request body
        request.httpBody = jsonData

        // Create a URLSession
        let session = URLSession.shared

        // Create a URLSessionDataTask to perform the request
        let task = session.dataTask(with: request) { (data, response, error) in
            // Handle response
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Parse the token from the response data
                if let responseData = data,
                   let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []),
                   let jsonDict = jsonResponse as? [String: Any] {
                    print(jsonDict)
                    completion(.success(true))
                } else {
                    completion(.failure(.invalidResponse))
                }
            } else if httpResponse.statusCode == 401 {
                completion(.failure(.requestFailed(NSError(domain: "Authentication failed. Please try with correct credentials!", code: 0, userInfo: nil))))
                print("Authentication failed with status code:", httpResponse.statusCode)
                
            }
            else {
                completion(.failure(.requestFailed(NSError(domain: "Server error!", code: 0, userInfo: nil))))
            }
        }

        // Start the URLSessionDataTask
        task.resume()
    }

}
