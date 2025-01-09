//
//  WidgetView.swift
//  WeatherCute WidgetExtension
//
//  Created by Kate Duncan-Welke on 4/4/22.
//  Copyright © 2022 Kate Duncan-Welke. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let useStub: Bool

    @ViewBuilder
    var body: some View {
        
        
        switch family {
        case .systemSmall:
            SmallWidgetView(useStub: useStub)
        case .systemMedium:
            MediumWidgetView(useStub: useStub)
        case .systemLarge:
            LargeWidgetView(useStub: useStub)
        case .systemExtraLarge:
            ExtraLargeWidgetView(useStub: useStub)
        @unknown default:
            EmptyView()
        }
    }
}

struct SmallWidgetView: View {
    
    private let viewModel = ContentViewModel()
    let useStub: Bool

    var body: some View {
        ZStack {
            Color(UIColor(named: "Custom Background Color") ?? UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            VStack(spacing: 0) {
                Text(viewModel.getLocationName(useStub: useStub))
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .lineLimit(1)
                Image("none")
                    .resizable()
                    .scaledToFit()
                Text(viewModel.getCurrentTemp(useStub: useStub))
                    .font(.system(size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(viewModel.getCurrentDescription(useStub: useStub))
                    .font(.system(size: 15.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .lineLimit(1)
            }

            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    Image(uiImage: viewModel.getCurrentConditionImage(useStub: useStub) ??   #imageLiteral(resourceName: "none.png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.95)
                        .frame(width: geo.size.width, height: geo.size.height * 0.90)
                }
            )

            GeometryReader { geo in
                Image(viewModel.getAlertButton(useStub: useStub))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.32, height: geo.size.height * 0.62)
            }
        }
    }
}

struct MediumWidgetView: View {

    private let viewModel = ContentViewModel()
    let useStub: Bool

    var body: some View {
        ZStack {
            Color(UIColor(named: "Custom Background Color") ?? UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            HStack {
                GeometryReader { geo in
                    Image(uiImage: viewModel.getCurrentConditionImage(useStub: useStub) ??   #imageLiteral(resourceName: "none.png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.95)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                VStack(spacing: 0) {
                    Text(viewModel.getLocationName(useStub: useStub))
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                    Text(viewModel.getCurrentTemp(useStub: useStub))
                        .font(.system(size: 22.0))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(viewModel.getCurrentDescription(useStub: useStub))
                        .font(.system(size: 15.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                    Text(viewModel.getForecastName(index: 0, useStub: useStub))
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Text("\(viewModel.getForecastTemp(index: 0, useStub: useStub)) \(viewModel.getForecastText(index: 0, useStub: useStub))")
                        .font(.system(size: 15.0))
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                        .multilineTextAlignment(.center)
                }

                Spacer()
                Spacer()
                Spacer()
            }

            GeometryReader { geo in
                Image(viewModel.getAlertButton(useStub: useStub))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.2, height: geo.size.height * 0.4)
            }
        }
    }
}

struct LargeWidgetView: View {

    private let viewModel = ContentViewModel()
    let useStub: Bool

    var body: some View {
        ZStack {
            Color(UIColor(named: "Custom Background Color") ?? UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))
            
            VStack(spacing: 0) {
                Text(viewModel.getLocationName(useStub: useStub))
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 15)
                    .multilineTextAlignment(.center)
                Image("none")
                    .resizable()
                    .scaledToFit()
                Text(viewModel.getCurrentTemp(useStub: useStub))
                    .font(.system(size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(viewModel.getCurrentDescription(useStub: useStub))
                    .font(.system(size: 15.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)

                HStack {
                    Spacer()

                    VStack {
                        Text("Humidity")
                            .font(.system(size: 16.0))
                            .foregroundColor(.white)
                        Text(viewModel.getCurrentHumidity(useStub: useStub))
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {
                        Text("Dewpoint")
                            .font(.system(size: 16.0))
                            .foregroundColor(.white)
                        Text(viewModel.getCurrentDewpoint(useStub: useStub))
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {
                        Text(viewModel.setHeatChillLabel(useStub: useStub))
                            .font(.system(size: 16.0))
                            .foregroundColor(.white)
                        Text(viewModel.getCurrentHeatChill(useStub: useStub))
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()
                }

                Spacer()
                Spacer()

                Text(viewModel.getForecastName(index: 0, useStub: useStub))
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text("\(viewModel.getForecastTemp(index: 0, useStub: useStub)) \(viewModel.getForecastText(index: 0, useStub: useStub))")
                    .font(.system(size: 15.0))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
            }

            .background(
                GeometryReader { geo in
                    Image(uiImage: viewModel.getCurrentConditionImage(useStub: useStub) ??   #imageLiteral(resourceName: "none.png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.95)
                        .frame(width: geo.size.width, height: geo.size.height * 0.70)
                }
            )

            GeometryReader { geo in
                Image(viewModel.getAlertButton(useStub: useStub))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.2, height: geo.size.height * 0.4)
            }
        }
    }
}

struct ExtraLargeWidgetView: View {

    private let viewModel = ContentViewModel()
    let useStub: Bool

    var body: some View {
        ZStack {
            Color(UIColor(named: "Custom Background Color") ?? UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            HStack {
                VStack {
                    Spacer()

                    Text(viewModel.getLocationName(useStub: useStub))
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    Image("none")
                        .resizable()
                        .scaledToFit()
                    Text(viewModel.getCurrentTemp(useStub: useStub))
                        .font(.system(size: 22.0))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(viewModel.getCurrentDescription(useStub: useStub))
                        .font(.system(size: 15.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)

                    HStack {
                        Spacer()

                        VStack {
                            Text("Humidity")
                                .font(.system(size: 16.0))
                                .foregroundColor(.white)
                            Text(viewModel.getCurrentHumidity(useStub: useStub))
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack {
                            Text("Dewpoint")
                                .font(.system(size: 16.0))
                                .foregroundColor(.white)
                            Text(viewModel.getCurrentDewpoint(useStub: useStub))
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack {
                            Text(viewModel.setHeatChillLabel(useStub: useStub))
                                .font(.system(size: 16.0))
                                .foregroundColor(.white)
                            Text(viewModel.getCurrentHeatChill(useStub: useStub))
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }

                    Spacer()
                    Spacer()
                }

                HStack {
                    Spacer()

                    VStack {
                        Spacer()
                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 0, useStub: useStub))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 0, useStub: useStub))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 0, useStub: useStub))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)
                        }

                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geo in
                                Image(uiImage: viewModel.getForecastIcon(index: 0, useStub: useStub) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.95)
                                    .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            }
                        )

                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 2, useStub: useStub))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 2, useStub: useStub))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 2, useStub: useStub))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)
                        }

                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geo in
                                Image(uiImage: viewModel.getForecastIcon(index: 2, useStub: useStub) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.95)
                                    .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            }
                        )

                        Spacer()
                        Spacer()
                    }

                    Spacer()
                    Spacer()

                    VStack {
                        Spacer()
                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 1, useStub: useStub))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 1, useStub: useStub))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 1, useStub: useStub))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)
                        }

                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geo in
                                Image(uiImage: viewModel.getForecastIcon(index: 1, useStub: useStub) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.95)
                                    .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            }
                        )

                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 3, useStub: useStub))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 3, useStub: useStub))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 3, useStub: useStub))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)
                        }

                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { geo in
                                Image(uiImage: viewModel.getForecastIcon(index: 3, useStub: useStub) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.95)
                                    .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            }
                        )

                        Spacer()
                        Spacer()
                    }

                    Spacer()
                    Spacer()
                }
            }

            .background(
                GeometryReader { geo in
                    Image(uiImage: viewModel.getCurrentConditionImage(useStub: useStub) ??   #imageLiteral(resourceName: "none.png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.5)
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.75)
                }
            )

            GeometryReader { geo in
                Image(viewModel.getAlertButton(useStub: useStub))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.1, height: geo.size.height * 0.4)
            }
        }
    }
}
