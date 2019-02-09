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

public class Untappd {
    private init(clientID: String, clientSecret: String, fetch: NetworkFetch) {
        Injection.shared.clientID = clientID
        Injection.shared.clientSecret = clientSecret
        Injection.shared.fetch = fetch
    }
    
    public static func anonymous(clientID: String, clientSecret: String, fetch: NetworkFetch) -> Untappd {
        return Untappd(clientID: clientID, clientSecret: clientSecret, fetch: fetch)
    }
    
    public func search(beer name: String, completion: @escaping ((BeersResult) -> Void)) {
        Logging.log("Search '\(name)")
        let request = SearchBeerRequest(name: name)
        Injection.shared.inject(into: request)
        request.resultHandler = completion
        request.execute()
    }
    
    public func info(for beer: BeerOverview, completion: @escaping ((BeerInfoResult) -> Void)) {
        info(for: beer.bid, completion: completion)
    }

    public func info(for beerId: Int, completion: @escaping ((BeerInfoResult) -> Void)) {
        Logging.log("Fetch info for \(beerId)")
        let request = BeerInfoRequest(beerId: beerId)
        Injection.shared.inject(into: request)
        request.resultHandler = completion
        request.execute()
    }
}
