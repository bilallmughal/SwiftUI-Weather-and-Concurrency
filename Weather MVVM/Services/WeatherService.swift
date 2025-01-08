//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import Foundation

actor WeatherService {
    private let apiKey: String
    private let baseURL = "http://api.weatherapi.com/v1"
    private let session: URLSession
    
    init(apiKey: String) {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    enum WeatherError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
        case serverError(String)
    }
    
    func fetchWeather(for query: String) async throws -> WeatherResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/current.json?key=\(apiKey)&q=\(encodedQuery)") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
    
    func fetchAQI(for query: String) async throws -> AQIResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/forecast.json?key=\(apiKey)&q=\(encodedQuery)&aqi=yes&days=3") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(AQIResponse.self, from: data)
    }
} 
