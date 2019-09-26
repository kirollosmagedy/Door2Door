//
//  MapsViewModel.swift
//  door2doorDemo
//
//  Created by Kiro on 9/24/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import RxSwift
import RxStarscream
import Starscream
import RxCocoa

class MapsViewModel {
    let statusPublishRelay = BehaviorRelay<DoorPickupStatus>(value: .unknown)
    let directionPublishSubject = PublishSubject<[GMRoute]>()
    let vechicalLocationPublishReplay = PublishRelay<DoorLocationModel>()
    
    private let disposeBag = DisposeBag()
    private var socket: WebSocket!
    private var bookingOpenedModel: BookingOpenedModel?
    private var currentVechileLocation: DoorLocationModel?
    
    func getDirections(startLocation: CLLocation, destinationLocation: CLLocation, intermediatePoints: [CLLocationCoordinate2D]?) {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
        var wayPoints = ""
        
        for point in intermediatePoints ?? [] {
            wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)%7C\(point.latitude),\(point.longitude)"
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&waypoints=\(wayPoints)&key=\(AppConstants.googleApiKey)"
        
        
        let response = Alamofire.request(URL(string: urlString)!, method: .get, parameters: nil, encoding: JSONEncoding.default , headers: nil)
        response.responseJSON { (googleData) in
            guard googleData.error == nil else {
                self.directionPublishSubject.onError(googleData.error!)
                return
            }
            if let data = googleData.data {
                if let googleResponse = try? JSONDecoder().decode(GMBaseResponse.self, from: data) {
                    print("😎 reterived google response successfuly")
                    self.directionPublishSubject.onNext(googleResponse.routes ?? [])
                } else {
                    // throw error google data could not be parsed
                    print("😱 could not parse google response")
                    self.directionPublishSubject.onError(BaseError.parsingFailed)
                }
            } else {
                // throw error data is empty
                print("😱 could not parse data is empty")
            }
            
            
        }
        
        
    }
    
    func startMonitoringForLocation() {
        socket = WebSocket(url: URL(string: "wss://d2d-frontend-code-challenge.herokuapp.com")!)
        
        if socket.isConnected {
            socket.disconnect()
        }
        
        socket.connect()
        (socket.rx.response.subscribe(onNext: { [weak self] (response: WebSocketEvent) in
            switch response {
            case .connected:
                print("Connected")
            case .disconnected(let error):
                self?.statusPublishRelay.accept(DoorPickupStatus.unknown)
            case .message(let msg):
                let data = msg.data(using: .utf8)
                if let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any] {
                    if let status = DDoorStatus(rawValue: json?["event"] as? String ?? "") {
                        let responseDic = json?["data"] as? [String: Any]
                        switch status {
                        case .bookingOpened:
                            self!.bookingOpenedModel = BookingOpenedModel(dic: responseDic ?? [:])
                            self?.statusPublishRelay.accept( DoorPickupStatus(rawValue: self!.bookingOpenedModel!.status ?? "") ?? DoorPickupStatus.waitingForPickup)
                            
                            self?.getDirections(startLocation: CLLocation(lat:
                                self!.bookingOpenedModel!.vehicleLocation?.lat ?? 0, lng: self!.bookingOpenedModel!.vehicleLocation?.lng ?? 0),
                                                destinationLocation: CLLocation(lat: self!.bookingOpenedModel!.pickupLocation?.lat ?? 0, lng: self!.bookingOpenedModel!.pickupLocation?.lng ?? 0), intermediatePoints: [])
                            
                        case .intermediateStopLocationsChanged:
                            
                            let intermediatePointsDic = json?["data"] as? [[String: Any]]
                            var intermediateStopLocations = [DoorLocationModel]()
                            
                            for point in intermediatePointsDic ?? [] {
                                intermediateStopLocations.append(DoorLocationModel(dic: point))
                            }
                            
                            var wayPoints = [CLLocationCoordinate2D]()
                            for intermediateLocation in intermediateStopLocations {
                                wayPoints.append(CLLocationCoordinate2D(latitude: intermediateLocation.lat ?? 0, longitude: intermediateLocation.lng ?? 0))
                            }
                            
                            self?.getDirections(startLocation: CLLocation(lat:
                                self!.currentVechileLocation?.lat ?? 0, lng: self!.currentVechileLocation?.lng ?? 0),
                                                destinationLocation: CLLocation(lat: self!.bookingOpenedModel!.dropoffLocation?.lat ?? 0, lng: self!.bookingOpenedModel!.dropoffLocation?.lng ?? 0), intermediatePoints: wayPoints)
                            
                        case .statusUpdated:
                            let statusString = json?["data"] as? String ?? ""
                            let status = DoorPickupStatus(rawValue: statusString)
                            self?.statusPublishRelay.accept(status ?? DoorPickupStatus.waitingForPickup)
                            
                            switch status {
                            case .waitingForPickup :
                                break
                            case .inVehicle :
                                var wayPoints = [CLLocationCoordinate2D]()
                                for intermediateLocation in self!.bookingOpenedModel?.intermediateStopLocations! ?? [] {
                                    wayPoints.append(CLLocationCoordinate2D(latitude: intermediateLocation.lat ?? 0, longitude: intermediateLocation.lng ?? 0))
                                }
                                self?.getDirections(startLocation: CLLocation(lat:
                                    self!.bookingOpenedModel!.pickupLocation?.lat ?? 0, lng: self!.bookingOpenedModel!.pickupLocation?.lng ?? 0),
                                                    destinationLocation: CLLocation(lat: self!.bookingOpenedModel!.dropoffLocation?.lat ?? 0, lng: self!.bookingOpenedModel!.dropoffLocation?.lng ?? 0), intermediatePoints: wayPoints)
                            case .droppedOff :
                                break
                            case .none:
                                break
                            case .unknown:
                                break
                            }
                        case .vehicleLocationUpdated:
                            let vechicleLocation = DoorLocationModel(dic: responseDic ?? [:])
                            self!.currentVechileLocation = vechicleLocation
                            self?.vechicalLocationPublishReplay.accept(vechicleLocation)
                        case .bookingClosed:
                            self?.socket.disconnect()
                        }
                    }
                }
            case .data(_):
                break
            case .pong:
                break
            }
            },onError: {
                error in
                if self.statusPublishRelay.value == .unknown {
                    self.directionPublishSubject.onError(error)
                }
        })).disposed(by: disposeBag)

    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
}

enum BaseError: Error {
    case parsingFailed
    case emptyData
}


enum DoorPickupStatus: String {
    case unknown
    case waitingForPickup = "waitingForPickup"
    case inVehicle = "inVehicle"
    case droppedOff = "droppedOff"
}
