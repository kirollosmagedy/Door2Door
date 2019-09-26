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
    private var mapView: GMSMapView!
    private let disposeBag = DisposeBag()
    private let marker = GMSMarker()

    let viewModel = MapsViewModel()
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var mapsContainerView: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var statusTitleLbl: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        statusTitleLbl.isHidden = true
        
        //should be user current location
        let camera = GMSCameraPosition.camera(withLatitude: 52.519061, longitude: 13.426789, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: mapsContainerView.frame, camera: camera)
        mapsContainerView.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: mapsContainerView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapsContainerView.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: mapsContainerView.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: mapsContainerView.leftAnchor).isActive = true
        cancelBtn.isHidden = true

        viewModel.statusPublishRelay.do(onNext: { _ in
            self.statusTitleLbl.isHidden = false
        }).map({ (status) in
            return status.rawValue
        }).asDriver(onErrorJustReturn: "").drive(self.statusLbl.rx.text).disposed(by: disposeBag)
        
        viewModel.directionPublishSubject.subscribe(onNext: { routes in
            self.mapView.drawLine(routes: routes)
        }, onError: { (error) in
            //check for internet connection or show blocking error thrown from google api
        }).disposed(by: disposeBag)
        
        viewModel.vechicalLocationPublishReplay.subscribe(onNext: { (location) in
            self.createCarMarker(lat: location.lat ?? 0.0, lng: location.lng ?? 0.0)
        }).disposed(by: self.disposeBag)
        
        viewModel.statusPublishRelay.subscribe(onNext: { (status) in
            switch status {
            case .droppedOff:
                let alertViewController = UIAlertController(title: "Congratulations!", message: "your trip has completed successfully!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    alertViewController.dismiss(animated: true)
                }
                alertViewController.addAction(okAction)
                self.present(alertViewController, animated: true)
                self.startBtn.isHidden = false
            case .inVehicle:
                self.cancelBtn.disableButton()
            case .waitingForPickup:
                self.cancelBtn.isHidden = false
                self.cancelBtn.enableButton()
                
            }
        }).disposed(by: self.disposeBag)
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
    
    @IBAction func startPressed(_ sender: UIButton) {
        self.startBtn.isHidden = true
        viewModel.startMonitoringForLocation()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: 52.519061, longitude: 13.426789, zoom: 12.0)
        mapView.camera = camera
        mapView.clear()
        viewModel.disconnect()
        startBtn.isHidden = false
        cancelBtn.isHidden = true
        
    }
    
}

