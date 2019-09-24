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

class MapsViewModel {
    let disposeBag = DisposeBag()
    var socket: WebSocket!
    
    func getDirections(startLocation: CLLocation, destinationLocation: CLLocation, intermediatePoints: [CLLocationCoordinate2D]?) -> Observable<[GMRoute]> {
        return Observable.create { (observer) -> Disposable in
            let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
            let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
            var wayPoints = ""
            
            for point in intermediatePoints ?? [] {
                wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)%7C\(point.latitude),\(point.longitude)"
            }
            
            let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&waypoints=\(wayPoints)&key=\(AppConstants.googleApiKey)"

           
            let response = Alamofire.request(URL(string: urlString)!, method: .get, parameters: nil, encoding: JSONEncoding.default , headers: nil)
            response.responseJSON { (googleData) in
                if let data = googleData.data {
                    if let googleResponse = try? JSONDecoder().decode(GMBaseResponse.self, from: data) {
                        print("😎 reterived google response successfuly")
                        observer.onNext(googleResponse.routes ?? [])
                    } else {
                        // throw error google data could not be parsed
                        print("😱 could not parse google response")
                        observer.onError(BaseError.parsingFailed)
                    }
                } else {
                    // throw error data is empty
                    print("😱 could not parse data is empty")
                    observer.onError(BaseError.emptyData)

                }
                
            }
            return Disposables.create()
        }
    }
    
    func startMonitoringForLocation() {
        socket = WebSocket(url: URL(string: "wss://d2d-frontend-code-challenge.herokuapp.com")!)
        socket.connect()
        socket.rx.response.subscribe(onNext: { [weak self] (response: WebSocketEvent) in
            switch response {
            case .connected:
                print("Connected")
            case .disconnected(let error):
                print("Disconnected with optional error : \(error)")
            case .message(let msg):
                let data = msg.data(using: .utf8)
                if let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? [String: Any] {
                    if let status = DDoorStatus(rawValue: json?["event"] as? String ?? "") {
                        let responseDic = json?["data"] as? [String: Any]
                        switch status {
                        case .bookingOpened:
                            let bookingOpenedModel = BookingOpenedModel(dic: responseDic ?? [:])
                            
                        case .intermediateStopLocationsChanged:
                            break
                        case .statusUpdated:
                            break
                        case .vehicleLocationUpdated:
                            break
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
        }).disposed(by: disposeBag)

    }
    
}

enum BaseError: Error {
    case parsingFailed
    case emptyData
}

