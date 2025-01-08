//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import Foundation
import SwiftUI
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService: WeatherService
    private let locationManager: LocationManager
    
    @Published var weatherData: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var searchText = ""
    
    init(weatherService: WeatherService, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        
        setupLocationObserver()
    }
    
    private func setupLocationObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("LocationUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let location = notification.userInfo?["location"] as? CLLocation else { return }
            
            Task {
                await self.fetchWeatherForLocation(location)
            }
        }
    }
    
    private func fetchWeatherForLocation(_ location: CLLocation) async {
        let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        await fetchWeather(for: coordinates)
    }
    
    func fetchWeather(for query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            weatherData = try await weatherService.fetchWeather(for: query)
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
        isLoading = false
    }
} 
