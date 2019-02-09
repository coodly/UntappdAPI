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

public enum UntappdError: Error {
    case noData
    case network(Error)
    case server(String)
    case invalidJSON
    case unknown
}

internal struct NetworkResult<T: Codable> {
    var value: T?
    let statusCode: Int
    let error: UntappdError?
}

internal enum Parameter {
    case query(String)
    case sort(String)
    case limit(Int)
    case offset(Int)
}

internal class NetworkRequest<Result, Response: Codable> {
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    internal var result: Result? {
        didSet {
            guard let value = result else {
                return
            }
            
            resultHandler?(value)
        }
    }
    internal var resultHandler: ((Result) -> Void)?

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
    
    internal func get(path: String, params: [Parameter] = []) {
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
            case .sort(let by):
                name = "sort"
                value = by
            case .limit(let limit):
                name = "limit"
                value = String(describing: limit)
            case .offset(let offset):
                name = "offset"
                value = String(describing: offset)
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
    
    private func handle(data: Data?, response: URLResponse?, error networkError: Error?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        Logging.log("Status code: \(statusCode)")
        
        if let data = data, let string = String(data: data, encoding: .utf8) {
            Logging.log("Response:\n\(string)")
        }
        
        var value: Response?
        var untappdError: UntappdError?
        
        defer {
            self.handle(result: NetworkResult(value: value, statusCode: statusCode, error: untappdError))
        }
        
        if let remoteError = networkError  {
            untappdError = .network(remoteError)
            return
        }
        
        if statusCode == 200, data == nil {
            untappdError = .noData
            return
        }
        
        guard let data = data else {
            untappdError = .noData
            return
        }
        
        do {
            value = try self.decoder.decode(Response.self, from: data)
        } catch {
            Logging.log("Decode error: \(error)")
            untappdError = .invalidJSON
        }
    }
    
    internal func handle(result: NetworkResult<Response>) {
        Logging.log("Handle \(result)")
    }
}
