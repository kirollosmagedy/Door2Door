//
//  Maps+Extensions.swift
//  door2doorDemo
//
//  Created by Fady on 9/24/19.
//  Copyright © 2019 Fady. All rights reserved.
//

import MapKit
import GoogleMaps
extension CLLocation {
    convenience init(lat: Double, lng: Double) {
        self.init(latitude: CLLocationDegrees(exactly: lat)!, longitude: CLLocationDegrees(exactly: lng)!)
    }
}

extension GMSMapView {
    func drawLine(routes: [GMRoute]) {
        self.clear()
        for route in routes {
            let points = route.overviewPolyline?.points
            let path = GMSPath.init(fromEncodedPath: points!)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 3
            
            let bounds = GMSCoordinateBounds(path: path!)
            self.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
            polyline.map = self
        }
    }
}
