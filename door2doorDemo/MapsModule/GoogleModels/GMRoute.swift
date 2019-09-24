//
//  GMRoute.swift
//  door2doorDemo
//
//  Created by Kiro on 9/24/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import Foundation

class GMRoute: Codable {
    let overviewPolyline: GMPolyline?
    
    enum CodingKeys: String, CodingKey {
        case overviewPolyline = "overview_polyline"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        overviewPolyline = try values.decodeIfPresent(GMPolyline.self, forKey: .overviewPolyline)
    }
}

class GMPolyline: Codable {
    let points: String?
}
