//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel: WeatherViewModel
    
    init(viewModel: WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                searchBar
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let weather = viewModel.weatherData {
                    WeatherContentView(weather: weather)
                } else {
                    ContentUnavailableView("Enter a city name", 
                                        systemImage: "magnifyingglass")
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Weather")
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Enter city name", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .onSubmit {
                    Task {
                        await viewModel.fetchWeather(for: viewModel.searchText)
                    }
                }
            
            Button {
                Task {
                    await viewModel.fetchWeather(for: viewModel.searchText)
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
    }
}

struct WeatherContentView: View {
    let weather: WeatherResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Location Info
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.location.name)
                    .font(.title)
                    .bold()
                Text("\(weather.location.region), \(weather.location.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Current Weather
            HStack(spacing: 20) {
                AsyncImage(url: URL(string: "https:" + weather.current.condition.icon)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 64, height: 64)
                
                VStack(alignment: .leading) {
                    Text("\(Int(weather.current.tempC))°C")
                        .font(.system(size: 42, weight: .bold))
                    Text(weather.current.condition.text)
                        .font(.title3)
                }
            }
            
            // Additional Details
            VStack(alignment: .leading, spacing: 12) {
                WeatherDetailRow(icon: "thermometer", title: "Feels like", value: "\(Int(weather.current.feelslikeC))°C")
                WeatherDetailRow(icon: "humidity", title: "Humidity", value: "\(weather.current.humidity)%")
                WeatherDetailRow(icon: "wind", title: "Wind", value: "\(Int(weather.current.windKph)) km/h \(weather.current.windDir)")
                WeatherDetailRow(icon: "gauge.medium", title: "Pressure", value: "\(Int(weather.current.pressureMb)) mb")
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct WeatherDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(title)
            Spacer()
            Text(value)
                .bold()
        }
    }
} 
