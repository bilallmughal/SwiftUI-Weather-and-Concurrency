//
//  Weather_MVVMApp.swift
//  Weather MVVM
//
//  Created by Muhammad Bilal on 08/01/2025.
//


import SwiftUI
import Charts

struct AQIView: View {
    @ObservedObject var viewModel: AQIViewModel
    @State private var cityInput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                searchBar
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let aqiData = viewModel.aqiData {
                    ScrollView {
                        VStack(spacing: 20) {
                            currentAQICard(aqiData)
                            aqiChart
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView("Enter a city name",
                                        systemImage: "aqi.high")
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Air Quality Index")
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Enter city name", text: $cityInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .onSubmit {
                    Task {
                        await viewModel.fetchAQI(for: cityInput)
                    }
                }
            
            Button {
                Task {
                    await viewModel.fetchAQI(for: cityInput)
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
    
    private func currentAQICard(_ data: AQIResponse) -> some View {
        let (description, color) = viewModel.getAQIDescription(index: data.current.airQuality.usEpaIndex)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text(data.location.name)
                .font(.title2)
                .bold()
            
            HStack {
                Text("Current AQI:")
                    .font(.headline)
                Text(description)
                    .foregroundColor(color)
                    .bold()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                AQIDetailRow(title: "PM2.5", value: data.current.airQuality.pm2_5)
                AQIDetailRow(title: "PM10", value: data.current.airQuality.pm10)
                AQIDetailRow(title: "O3", value: data.current.airQuality.o3)
                AQIDetailRow(title: "NO2", value: data.current.airQuality.no2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private var aqiChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PM2.5 Levels")
                .font(.headline)
            
            Chart {
                ForEach(viewModel.aqiChartData, id: \.hour) { dataPoint in
                    LineMark(
                        x: .value("Hour", dataPoint.hour),
                        y: .value("PM2.5", dataPoint.value)
                    )
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Hour", dataPoint.hour),
                        y: .value("PM2.5", dataPoint.value)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct AQIDetailRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 60, alignment: .leading)
            Text(String(format: "%.1f", value))
                .bold()
        }
    }
} 
