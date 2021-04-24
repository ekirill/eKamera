import os
import Foundation
import UIKit

class ApiClient {
    let baseApiUrl = "https://ekirill.ru/api/v1/"
    
    static func handleHttpErrors(response: URLResponse?, error: Error?, expectedMime: String?) {
        if let error = error {
            os_log("fetch fail: %s", log: OSLog.default, type: .error, error.localizedDescription)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            os_log("fetch fail: response is not HTTPURLResponse", log: OSLog.default, type: .error)
            return
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            os_log("fetch fail: wrong status code %d", log: OSLog.default, type: .error, httpResponse.statusCode)
            return
        }
        
        if let wantMime=expectedMime {
            guard let mimeType = httpResponse.mimeType, mimeType == wantMime else {
                os_log("fetch fail: mimeType is not %s", log: OSLog.default, type: .error, wantMime)
                return
            }
        }
    }
    
    func getCameras(page: Int, completion: @escaping (CamerasListResponse) -> Void) {
        let apiUrl = baseApiUrl + "cameras/"

        guard var components = URLComponents(string: apiUrl) else {
            os_log("fetch fail: invalid url %s", log: OSLog.default, type: .error, apiUrl)
            return
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        let request = URLRequest(url: components.url!)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            ApiClient.handleHttpErrors(response: response, error: error, expectedMime: "application/json")

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(CamerasListResponse.self, from: data)
                    
                    completion(response)
                } catch let error {
                    os_log("fetch fail: invalid json %s", log: OSLog.default, type: .error, error.localizedDescription)
                    return
                }
            }
        }
        task.resume()
    }
    
    func getThumbnail(thumnailUrl: String, completion: @escaping (UIImage) -> Void) {
        guard let imageUrl = URL(string: thumnailUrl) else {
            os_log("fetch fail: invalid url %s", log: OSLog.default, type: .error, thumnailUrl)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            ApiClient.handleHttpErrors(response: response, error: error, expectedMime: nil)

            if let data = data {
                guard let imageData = data as Data? else {
                    os_log("fetch fail: invalid data", log: OSLog.default, type: .error)
                    return
                }
                
                guard let img = UIImage(data: imageData) else {
                    os_log("fetch fail: data not an image", log: OSLog.default, type: .error)
                    return
                }
                    
                completion(img)
            }
        }
        task.resume()
    }
}
