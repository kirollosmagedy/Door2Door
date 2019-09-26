//
//  GoogleBaseResponse.swift
//  door2doorDemo
//
//  Created by Fady on 9/24/19.
//  Copyright © 2019 Fady. All rights reserved.
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



