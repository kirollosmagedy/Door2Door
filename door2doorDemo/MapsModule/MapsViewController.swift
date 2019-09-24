//
//  ViewController.swift
//  door2doorDemo
//
//  Created by Kiro on 9/22/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

class MapsViewController: UIViewController {
    var mapView: GMSMapView!
    let viewModel = MapsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 40.4, longitude: 30.3, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        drawLine(startLocation: CLLocation(lat: 40.4, lng: 30.3), destinationLocation:   CLLocation(lat: 40.5, lng: 30.4))
    }
    
  
    func drawLine(startLocation: CLLocation, destinationLocation: CLLocation) {
        
        viewModel.getDirections(startLocation: startLocation, destinationLocation: destinationLocation, intermediatePoints: nil).subscribe(onNext: { routes in
            self.mapView.drawLine(routes: routes)
        }, onError: { (error) in
            
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.startMonitoringForLocation()

    }
    
    func createCarMarker() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        let markerImage = UIImage(imageLiteralResourceName: "google-maps-car-icon")
        let imageView = UIImageView(image: markerImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        marker.iconView = imageView
        mapView.selectedMarker = marker
    }
}



