//
//  GoogleBaseResponse.swift
//  door2doorDemo
//
//  Created by Kiro on 9/24/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import Foundation


class GMBaseResponse: Codable {
    let status: String?
    let routes: [GMRoute]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case routes
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        routes = try values.decodeIfPresent([GMRoute].self, forKey: .routes)
    }
}



