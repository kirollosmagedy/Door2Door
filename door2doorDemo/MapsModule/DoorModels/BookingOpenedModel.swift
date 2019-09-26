//
//  BookingOpenedModel.swift
//  door2doorDemo
//
//  Created by Fady on 9/24/19.
//  Copyright © 2019 Fady. All rights reserved.
//

import Foundation

class BookingOpenedModel: Codable {
    let status: String?
    let vehicleLocation: DoorLocationModel?
    let pickupLocation: DoorLocationModel?
    let dropoffLocation: DoorLocationModel?
    var intermediateStopLocations: [DoorLocationModel]? = []
    
    
    enum CodingKeys: String, CodingKey {
        case status
        case vehicleLocation
        case pickupLocation
        case dropoffLocation
        case intermediateStopLocations
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        vehicleLocation = try values.decodeIfPresent(DoorLocationModel.self, forKey: .vehicleLocation)
        pickupLocation = try values.decodeIfPresent(DoorLocationModel.self, forKey: .pickupLocation)
        dropoffLocation = try values.decodeIfPresent(DoorLocationModel.self, forKey: .dropoffLocation)
        intermediateStopLocations = try values.decodeIfPresent([DoorLocationModel].self, forKey: .intermediateStopLocations)
    }
    
    init(dic: [String: Any]) {
        self.status = dic["status"] as? String ?? ""
        self.vehicleLocation = DoorLocationModel(dic: dic["vehicleLocation"] as! [String : Any])
        self.pickupLocation = DoorLocationModel(dic: dic["pickupLocation"]  as! [String : Any])
        self.dropoffLocation = DoorLocationModel(dic: dic["dropoffLocation"]  as! [String : Any])
        let intermediatePointsDic = dic["intermediateStopLocations"] as? [[String:Any]]
        
        for point in intermediatePointsDic ?? [] {
            intermediateStopLocations?.append(DoorLocationModel(dic: point))
        }
    }
}
