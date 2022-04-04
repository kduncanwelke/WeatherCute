//
//  WidgetView.swift
//  WeatherCute WidgetExtension
//
//  Created by Kate Duncan-Welke on 4/4/22.
//  Copyright © 2022 Kate Duncan-Welke. All rights reserved.
//

import SwiftUI

struct WidgetView: View {

    private let viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            VStack {
                Text("A Place")
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Image("none")
                    .resizable()
                    .scaledToFit()
                Text("30°")
                    .font(.system(size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Cloudy Windy")
                    .font(.system(size: 15.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 15)
            }

            .background(
                Image("cloudywindy")
                    .resizable()
                    .frame(width: 156.0, height: 110.0)
                    .padding(.bottom, 25)
            )
        }
    }
}
