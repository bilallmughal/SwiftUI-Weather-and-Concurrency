//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import Foundation
import CoreLocation

@MainActor
class LocationManager: ObservableObject {
    private var locationService: LocationService?
    
    @Published private(set) var location: CLLocation?
    @Published private(set) var error: Error?
    
    func initialize() async {
        locationService = await LocationService()
    }
    
    func requestLocation() {
        guard let locationService = locationService else { return }
        
        Task {
            do {
                let newLocation = try await locationService.requestLocation()
                await MainActor.run {
                    self.location = newLocation
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.location = nil
                }
            }
        }
    }
} 
