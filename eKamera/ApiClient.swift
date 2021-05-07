import os
import Foundation
import UIKit

class ApiClient {
    static let baseApiUrl = "https://ekirill.ru/api/v1/"
    
    private static func handleHttpErrors(response: URLResponse?, error: Error?, expectedMime: String?) {
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
    
    static func getCameras(_ page: Int, _ completion: @escaping (ApiResponse<Camera>) -> Void) {
        let apiUrl = ApiClient.baseApiUrl + "cameras/"

        guard var components = URLComponents(string: apiUrl) else {
            os_log("fetch fail: invalid url %s", log: OSLog.default, type: .error, apiUrl)
            return
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "ts", value: String(Int64(Date().timeIntervalSince1970))),
        ]
        let request = URLRequest(url: components.url!)

        os_log("making request: %s", log: OSLog.default, type: .debug, request.debugDescription)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            ApiClient.handleHttpErrors(response: response, error: error, expectedMime: "application/json")

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ApiResponse<Camera>.self, from: data)
                    
                    completion(response)
                } catch let error {
                    os_log("fetch fail: invalid json %s", log: OSLog.default, type: .error, error.localizedDescription)
                    return
                }
            }
        }
        task.resume()
    }

    static func getEventsFetcher(forCameraId camerId: String) -> (Int, @escaping (ApiResponse<Event>) -> Void) -> Void {
        return { page, completion in
            return ApiClient.getEvents(camerId, page, completion)
        }
    }

    static func getEvents(_ cameraId: String, _ page: Int, _ completion: @escaping (ApiResponse<Event>) -> Void) {
        let apiUrl = ApiClient.baseApiUrl + "cameras/\(cameraId)/events/"

        guard var components = URLComponents(string: apiUrl) else {
            os_log("fetch fail: invalid url %s", log: OSLog.default, type: .error, apiUrl)
            return
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "ts", value: String(Int64(Date().timeIntervalSince1970))),
        ]
        let request = URLRequest(url: components.url!)

        os_log("making request: %s", log: OSLog.default, type: .debug, request.debugDescription)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            ApiClient.handleHttpErrors(response: response, error: error, expectedMime: "application/json")

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ApiResponse<Event>.self, from: data)
                    
                    completion(response)
                } catch let error {
                    os_log("fetch fail: invalid json %s", log: OSLog.default, type: .error, error.localizedDescription)
                    return
                }
            }
        }
        task.resume()
    }
    
    static func getThumbnail(thumnailUrl: String, completion: @escaping (UIImage) -> Void) {
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
