//
//  ContentView.swift
//  WeatherCute
//
//  Created by Katherine Duncan-Welke on 5/9/25.
//  Copyright © 2025 Kate Duncan-Welke. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var contentViewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor(named: "Custom Background Color") ?? UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))
            VStack {
                HStack {
                    Button("✎") {
                        
                    }
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                    .padding(.leading, 20)
                    Spacer()
                    Picker("", selection: $contentViewModel.unit) {
                        ForEach(TemperatureUnit.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 110)
                    Spacer()
                    Button("+") {
                        
                    }
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .padding(.trailing, 20)
                }
                
                TabView {
                    ForEach(0..<contentViewModel.getLocationsCount()) { index in
                        WeatherView(index: index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 650)
                
                HStack {
                    Button {
                        
                    } label: {
                        Image("info")
                            .resizable()
                    }
                    .frame(width: 25, height: 25)
                    .padding(.leading, 20)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct WeatherView: View {
    @State private var contentViewModel = ContentViewModel()
    
    let index: Int
    
    private let size: CGFloat = 145.0
    private let padding: CGFloat = 5.0
    
    private var columns: [GridItem] {
        return [.init(.adaptive(minimum: size, maximum: size))]
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(contentViewModel.getLocationName(index: index))
                    .foregroundStyle(.white)
                    .font(.system(size: 22, weight: .medium))
                Button {
                    
                } label: {
                    Image("reload")
                        .resizable()
                }
                .frame(width: 25, height: 25)
            }
            if let currentImage = contentViewModel.getCurrentConditionImage(index: index) {
                Image(uiImage: currentImage)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, -40)
            } else {
                Image(uiImage: UIImage(named: "cloudy")!)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, -40)
            }
            Text(contentViewModel.getCurrentTemp(index: index))
                .foregroundStyle(.white)
                .font(.system(size: 33, weight: .semibold))
                .padding(.top, -60)
            Text(contentViewModel.getCurrentDescription(index: index))
                .foregroundStyle(.white)
                .font(.system(size: 17, weight: .medium))
                .padding(.top, -35)
                .padding(.bottom, 15)
            HStack {
                Spacer()
                VStack {
                    Text("Humidity")
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .padding(.bottom, 10)
                    Text(contentViewModel.getCurrentHumidity(index: index))
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
                Spacer()
                VStack {
                    Text("Dew Point")
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .padding(.bottom, 10)
                    Text(contentViewModel.getCurrentDewpoint(index: index))
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
                Spacer()
                VStack {
                    Text(contentViewModel.setHeatChillLabel(index: index))
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .padding(.bottom, 10)
                    Text(contentViewModel.getCurrentHeatChill(index: index))
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
                Spacer()
            }
            HStack {
                Text(contentViewModel.getObservationName(index: index))
                    .foregroundStyle(.white)
                    .font(.system(size: 13))
                    
                Button("Change?") {
                    
                }
                .foregroundStyle(.black)
                .font(.system(size: 14))
            }
            .padding(.top, 20)
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: padding) {
                    ForEach(0..<contentViewModel.getForecastCount(index: index)) { index in
                        Text(contentViewModel.getForecastName(index: index))
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                        Text(contentViewModel.getForecastTemp(index: index))
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                        Image(uiImage: contentViewModel.getForecastIcon(index: index) ?? UIImage(named: "none")!)
                        Text(contentViewModel.getForecastText(index: index))
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
