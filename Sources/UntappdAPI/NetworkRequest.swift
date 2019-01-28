/*
 * Copyright 2019 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

private enum Method: String {
    case GET
}

internal enum Parameter {
    case query(String)
}

internal class NetworkRequest {
    private let baseURL: URL
    internal init(baseURL: URL = URL(string: "https://api.untappd.com/v4")!) {
        self.baseURL = baseURL
    }
    
    final internal func execute() {
        performRequest()
    }
    
    internal func performRequest() {
        Logging.log("Perform request")
    }
    
    internal func get(path: String, params: [Parameter]) {
        execute(method: .GET, to: path, params: params)
    }
    
    private func execute(method: Method, to path: String, params: [Parameter]) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = components.path + path
        
        var queryItems = [URLQueryItem]()
        
        params.forEach() {
            param in
            
            let name: String
            let value: String
            switch param {
            case .query(let term):
                name = "q"
                value = term
            }
            
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        
        if let accessToken = Injection.shared.accessToken {
            queryItems.append(URLQueryItem(name: "access_token", value: accessToken))
        } else if let client = Injection.shared.clientID, let secret = Injection.shared.clientSecret {
            queryItems.append(URLQueryItem(name: "client_id", value: client))
            queryItems.append(URLQueryItem(name: "client_secret", value: secret))
        }
        
        components.queryItems = queryItems
        
        let requestURL = components.url!
        let request = NSMutableURLRequest(url: requestURL)
        
        request.httpMethod = method.rawValue
        
        Logging.log("\(method) to \(requestURL.absoluteString)")
        Injection.shared.fetch.fetch(request: request as URLRequest, completion: handle(data:response:error:))
    }
    
    private func handle(data: Data?, response: URLResponse?, error: Error?) {
        
    }
}
