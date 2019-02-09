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

private let BeerInfoPathBase = "/beer/info/%@"

internal struct BeerInfoResponse: Codable {
    let response: BeerResponseContainer
}

internal struct BeerResponseContainer: Codable {
    let beer: BeerDetails
}

public struct BeerInfoResult {
    public let beer: BeerDetails?
    public let error: Error?
}

internal class BeerInfoRequest: NetworkRequest<BeerInfoResult, BeerInfoResponse> {
    private let beerId: Int
    internal init(beerId: Int) {
        self.beerId = beerId
    }
    
    override func performRequest() {
        let path = String(format: BeerInfoPathBase, NSNumber(value: beerId))
        
        get(path: path)
    }
    
    override func handle(result: NetworkResult<BeerInfoResponse>) {
        self.result = BeerInfoResult(beer: result.value?.response.beer, error: result.error)
    }
}
