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

internal struct BeerSearchResult: Codable {
    let response: BeerSearchResponse
}

internal struct BeerSearchResponse: Codable {
    let beers: Beers
}

internal struct Beers: Codable {
    let items: [BeerItem]
}

internal enum BeersSort: String {
    case checkin
    case name
}

private let SearchPath = "/search/beer"

internal class SearchBeerRequest: NetworkRequest<BeerSearchResult> {
    private let name: String
    internal init(name: String) {
        self.name = name
    }
    
    override func performRequest() {
        get(path: SearchPath, params: [.query(name), .sort(BeersSort.name.rawValue)])
    }
}
