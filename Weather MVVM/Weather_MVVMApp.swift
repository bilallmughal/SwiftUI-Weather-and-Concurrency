//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//

import SwiftUI

@main
struct Weather_MVVMApp: App {

    #error("API_KEY is missing")
    private let weatherService = WeatherService(apiKey: "API_KEY")
    
    var body: some Scene {
        WindowGroup {
            MainTabView(weatherService: weatherService)
        }
    }
}
/// IMPORTANT
/// Get you API key from https://www.weatherapi.com/
/// API Docs : - https://www.weatherapi.com/docs/
