//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import Foundation
import CoreLocation

actor LocationService {
    private let manager: CLLocationManager
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var delegate: LocationDelegate?
    private let managerProxy: LocationManagerProxy
    
    init() async {
        self.manager = CLLocationManager()
        self.managerProxy = await MainActor.run { LocationManagerProxy() }
    }
    
    func requestLocation() async throws -> CLLocation {
        if let continuation = continuation {
            continuation.resume(throwing: LocationError.inProgress)
            self.continuation = nil
        }
        
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            
            Task {
                let delegate = LocationDelegate(service: self)
                self.delegate = delegate
                
                do {
                    try await configureLocationManager(with: delegate)
                } catch {
                    cont.resume(throwing: error)
                    self.continuation = nil
                    self.delegate = nil
                }
            }
        }
    }
    
    private func configureLocationManager(with delegate: LocationDelegate) async throws {
        await MainActor.run {
            managerProxy.delegate = delegate
            managerProxy.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        let authStatus = await managerProxy.authorizationStatus
        switch authStatus {
        case .notDetermined:
            await managerProxy.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            await managerProxy.startUpdatingLocation()
        case .denied, .restricted:
            throw LocationError.unauthorized
        @unknown default:
            throw LocationError.unknown
        }
    }
    
    nonisolated func handleLocationUpdate(_ locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            NotificationCenter.default.post(
                name: Notification.Name("LocationUpdated"),
                object: nil,
                userInfo: ["location": location]
            )
        }
        
        Task {
            await self.completeContinuation(with: .success(location))
        }
    }
    
    nonisolated func handleError(_ error: Error) {
        Task {
            await self.completeContinuation(with: .failure(error))
        }
    }
    
    private func completeContinuation(with result: Result<CLLocation, Error>) {
        switch result {
        case .success(let location):
            continuation?.resume(returning: location)
        case .failure(let error):
            continuation?.resume(throwing: error)
        }
        continuation = nil
        delegate = nil
    }
    
    enum LocationError: Error {
        case unauthorized
        case unknown
        case inProgress
        case setupError
    }
}

@MainActor
private class LocationManagerProxy {
    private let manager: CLLocationManager
    
    init() {
        self.manager = CLLocationManager()
    }
    
    var delegate: CLLocationManagerDelegate? {
        get { manager.delegate }
        set { manager.delegate = newValue }
    }
    
    var desiredAccuracy: CLLocationAccuracy {
        get { manager.desiredAccuracy }
        set { manager.desiredAccuracy = newValue }
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

private class LocationDelegate: NSObject, CLLocationManagerDelegate {
    private let service: LocationService
    
    init(service: LocationService) {
        self.service = service
        super.init()
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        service.handleLocationUpdate(locations)
        Task { @MainActor in
            let proxy = LocationManagerProxy()
            proxy.stopUpdatingLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        service.handleError(error)
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let proxy = LocationManagerProxy()
            let authStatus = proxy.authorizationStatus
            
            switch authStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                proxy.startUpdatingLocation()
            case .denied, .restricted:
                service.handleError(LocationService.LocationError.unauthorized)
            default:
                break
            }
        }
    }
} 
