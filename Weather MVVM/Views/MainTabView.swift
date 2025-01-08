//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager: LocationManager
    @StateObject private var weatherViewModel: WeatherViewModel
    @StateObject private var aqiViewModel: AQIViewModel
    
    init(weatherService: WeatherService) {
        let locationManager = LocationManager()
        _locationManager = StateObject(wrappedValue: locationManager)
        _weatherViewModel = StateObject(wrappedValue: WeatherViewModel(weatherService: weatherService, locationManager: locationManager))
        _aqiViewModel = StateObject(wrappedValue: AQIViewModel(weatherService: weatherService, locationManager: locationManager))
    }
    
    var body: some View {
        TabView {
            AQIView(viewModel: aqiViewModel)
                .tabItem {
                    Label("Air Quality", systemImage: "aqi.high")
                }
            
            WeatherView(viewModel: weatherViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .task {
            await locationManager.initialize()
            locationManager.requestLocation()
        }
    }
} 
