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
class AQIViewModel: ObservableObject {
    private let weatherService: WeatherService
    private let locationManager: LocationManager
    
    @Published var aqiData: AQIResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedTimeFrame: TimeFrame = .day
    
    enum TimeFrame: String, CaseIterable {
        case day = "24 Hours"
        case week = "3 Days"
    }
    
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
                await self.fetchAQIForLocation(location)
            }
        }
    }
    
    private func fetchAQIForLocation(_ location: CLLocation) async {
        let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        await fetchAQI(for: coordinates)
    }
    
    func fetchAQI(for query: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            aqiData = try await weatherService.fetchAQI(for: query)
        } catch {
            errorMessage = "Failed to fetch AQI data: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    var aqiChartData: [(hour: String, value: Double)] {
        guard let forecast = aqiData?.forecast.forecastday.first?.hour else { return [] }
        return forecast.map { hourData in
            let hour = hourData.time.split(separator: " ")[1]
            return (String(hour), hourData.airQuality.pm2_5)
        }
    }
    
    func getAQIDescription(index: Int) -> (String, Color) {
        switch index {
        case 1: return ("Good", .green)
        case 2: return ("Moderate", .yellow)
        case 3: return ("Unhealthy for Sensitive Groups", .orange)
        case 4: return ("Unhealthy", .red)
        case 5: return ("Very Unhealthy", .purple)
        case 6: return ("Hazardous", .brown)
        default: return ("Unknown", .gray)
        }
    }
} 
