//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import Foundation

struct WeatherResponse: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct Current: Decodable {
    let tempC: Double
    let tempF: Double
    let condition: Condition
    let humidity: Int
    let windKph: Double
    let windDir: String
    let pressureMb: Double
    let feelslikeC: Double
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition
        case humidity
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case pressureMb = "pressure_mb"
        case feelslikeC = "feelslike_c"
    }
}

struct Condition: Decodable {
    let text: String
    let icon: String
}

struct AQIResponse: Decodable {
    let location: Location
    let current: AQICurrent
    let forecast: AQIForecast
}

struct AQICurrent: Decodable {
    let airQuality: AirQuality
    
    enum CodingKeys: String, CodingKey {
        case airQuality = "air_quality"
    }
}

struct AQIForecast: Decodable {
    let forecastday: [AQIForecastDay]
}

struct AQIForecastDay: Decodable {
    let hour: [HourlyAQI]
}

struct HourlyAQI: Decodable {
    let time: String
    let airQuality: AirQuality
    
    enum CodingKeys: String, CodingKey {
        case time
        case airQuality = "air_quality"
    }
}

struct AirQuality: Decodable {
    let co: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let usEpaIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case co, no2, o3, so2, pm2_5, pm10
        case usEpaIndex = "us-epa-index"
    }
} 
