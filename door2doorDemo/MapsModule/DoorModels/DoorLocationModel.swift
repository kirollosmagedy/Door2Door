//
//  DoorLocationModel.swift
//  door2doorDemo
//
//  Created by Kiro on 9/24/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import Foundation

class DoorLocationModel: Codable {
    let address: String?
    let lat: Double?
    let lng: Double?
    init(dic: [String: Any]) {
        address = dic["address"] as? String ?? ""
        lat = dic["lat"] as? Double
        lng = dic["lng"] as? Double
    }
}
