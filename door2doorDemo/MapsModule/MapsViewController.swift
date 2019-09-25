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
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var mapsContainerView: UIView!
    let marker = GMSMarker()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 40.4, longitude: 30.3, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: mapsContainerView.frame, camera: camera)
        mapsContainerView.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: mapsContainerView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapsContainerView.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: mapsContainerView.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: mapsContainerView.leftAnchor).isActive = true

        viewModel.statusPublishRelay.asDriver(onErrorJustReturn: "").drive(self.statusLbl.rx.text).disposed(by: disposeBag)
        viewModel.directionPublishSubject.subscribe(onNext: { routes in
            self.mapView.drawLine(routes: routes)
        }, onError: { (error) in
            //check for internet connection or show blocking error thrown from google api
        }).disposed(by: disposeBag)
        
        viewModel.vechicalLocationPublishReplay.subscribe(onNext: { (location) in
            self.createCarMarker(lat: location.lat ?? 0.0, lng: location.lng ?? 0.0)
        }).disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.startMonitoringForLocation()

    }
    
    func createCarMarker(lat: Double, lng: Double) {
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.map = mapView
        let markerImage = UIImage(imageLiteralResourceName: "google-maps-car-icon")
        let imageView = UIImageView(image: markerImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        marker.iconView = imageView
        mapView.selectedMarker = marker
    }
}



