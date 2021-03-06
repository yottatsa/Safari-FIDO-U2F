//  ----------------------------------------------------------------
//  Created by Sam Deane on 05/02/2017.
//
//  Copyright (c) 2017-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

import Foundation

class U2FRequest {
    typealias Dictionary = [String:Any]
    
    let appId : String
    let registeredKeys : [Dictionary]
    let origin : String
    let requestId : Int
    let timeout : Int?
    var responseType : String { get { return "unknown" } }

    init?(requestDictionary : Dictionary, origin : URL) {
        guard let appId = requestDictionary["appId"] as? String, let requestId = requestDictionary["requestId"] as? Int else {
            return nil
        }
        
        self.appId = appId
        
        if let keys = requestDictionary["registeredKeys"] as? [Dictionary] {
            self.registeredKeys = keys.filter { return ($0["version"] as? String) == U2FDevice.VERSION }
        } else {
            self.registeredKeys = []
        }
        self.requestId = requestId
        self.timeout = requestDictionary["timeout"] as? Int
        self.origin = "\(origin.scheme!)://\(origin.host!)"
    }
    
    /**
        Parse a request dictionary, and attempt to create and return a request object.
     */
    
    static func parse(type : String, requestDictionary : Dictionary, url : URL) throws -> U2FRequest {
        var request : U2FRequest?
        switch type {
        case U2FSignRequest.RequestType:
            request = U2FSignRequest(requestDictionary: requestDictionary, origin:url)

        case U2FRegisterRequest.RequestType:
            request = U2FRegisterRequest(requestDictionary: requestDictionary, origin:url)

        default:
            throw U2FError.unknownRequestType(type: type)
        }

        guard request != nil else {
            throw U2FError.unparseableRequest(request: requestDictionary)
        }

        return request!
    }

    static func find(key: String, version : String, in dictionary : Dictionary) -> Dictionary? {
        if let items = dictionary[key] as? [Dictionary] {
            for item in items {
                if let itemVersion = item["version"] as? String {
                    if version == itemVersion {
                        return item
                    }
                }
            }
        }
        return nil
    }
    
    func run(device : U2FDevice) throws -> U2FResponse.Dictionary {
        throw U2FError.unknown(in: "abstract method should have been implemented")
    }
}

