import Foundation

// API Request Model
struct APIRequest: Codable {
    let data: String
    let service: String
}

// API Response Model
struct APIResponse: Codable {
    let response: String
}

class APIService {
    // Function to make API request
    func makeRequestAPI(request: APIRequest, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        // URL for the API endpoint
        let url = URL(string: "http://192.168.1.218:8000/api/service")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Encode request data to JSON
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            // Make a data task for the API request
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    // Handle network errors
                    completion(.failure(error!))
                    return
                }
                
                // Check if response status code is within the success range
                guard (200...299).contains(response.statusCode) else {
                    // Handle HTTP response errors
                    let httpResponseError = NSError(domain: "", code: response.statusCode, userInfo: nil)
                    completion(.failure(httpResponseError))
                    return
                }
                
                do {
                    // Decode API response data
                    let responseData = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(responseData))
                } catch {
                    // Handle decoding errors
                    completion(.failure(error))
                }
            }
            
            // Resume the data task
            task.resume()
        } catch {
            // Handle encoding errors
            completion(.failure(error))
        }
    }
}
