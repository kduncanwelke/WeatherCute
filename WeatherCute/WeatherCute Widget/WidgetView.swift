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

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView()
        case .systemMedium:
            MediumWidgetView()
        case .systemLarge:
            LargeWidgetView()
        case .systemExtraLarge:
            ExtraLargeWidgetView()
        @unknown default:
            EmptyView()
        }
    }
}

struct SmallWidgetView: View {

    private let viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            VStack {
                Text(viewModel.getLocationName())
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Image(viewModel.getAlertButton())
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 120)
                    .padding(.bottom, 20)
                Image("none")
                    .resizable()
                    .scaledToFit()
                Text(viewModel.getCurrentTemp())
                    .font(.system(size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(viewModel.getCurrentDescription())
                    .font(.system(size: 15.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
            }

            .background(
                Image(uiImage: viewModel.getCurrentConditionImage() ?? #imageLiteral(resourceName: "none.png"))
                    .resizable()
                    .frame(width: 156.0, height: 110.0)
                    .padding(.bottom, 20)
            )
        }
    }
}

struct MediumWidgetView: View {

    private let viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            Image(viewModel.getAlertButton())
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 285)
                .padding(.bottom, 105)

            HStack {
                Image(uiImage: viewModel.getCurrentConditionImage() ?? #imageLiteral(resourceName: "none.png"))
                    .resizable()
                    .scaledToFit()

                VStack {
                    Text(viewModel.getLocationName())
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    Text(viewModel.getCurrentTemp())
                        .font(.system(size: 22.0))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(viewModel.getCurrentDescription())
                        .font(.system(size: 15.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                    Text(viewModel.getForecastName(index: 0))
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Text(viewModel.getForecastText(index: 0))
                        .font(.system(size: 15.0))
                        .foregroundColor(.white)
                        .padding(.bottom, 12)
                }

                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

struct LargeWidgetView: View {

    private let viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            VStack {
                Text(viewModel.getLocationName())
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Image(viewModel.getAlertButton())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 250)
                Image("none")
                    .resizable()
                    .scaledToFit()
                Text(viewModel.getCurrentTemp())
                    .font(.system(size: 22.0))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(viewModel.getCurrentDescription())
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
                        Text(viewModel.getCurrentHumidity())
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {
                        Text("Dewpoint")
                            .font(.system(size: 16.0))
                            .foregroundColor(.white)
                        Text(viewModel.getCurrentDewpoint())
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {
                        Text(viewModel.setHeatChillLabel())
                            .font(.system(size: 16.0))
                            .foregroundColor(.white)
                        Text(viewModel.getCurrentHeatChill())
                            .font(.system(size: 17.0))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

                    Spacer()
                }

                Spacer()
                Spacer()

                Text(viewModel.getForecastName(index: 0))
                    .font(.system(size: 16.0))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text(viewModel.getForecastText(index: 0))
                    .font(.system(size: 15.0))
                    .foregroundColor(.white)
                    .padding(.bottom, 18)
            }

            .background(
                Image(uiImage: viewModel.getCurrentConditionImage() ?? #imageLiteral(resourceName: "none.png"))
                    .resizable()
                    .frame(width: 312.0, height: 220.0)
                    .padding(.bottom, 110)
            )
        }
    }
}

struct ExtraLargeWidgetView: View {

    private let viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(UIColor(red: 0.14, green: 0.64, blue: 1.00, alpha: 1.00))

            HStack {
                VStack {
                    Spacer()

                    Text(viewModel.getLocationName())
                        .font(.system(size: 16.0))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    Image(viewModel.getAlertButton())
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 250)
                    Image("none")
                        .resizable()
                        .scaledToFit()
                    Text(viewModel.getCurrentTemp())
                        .font(.system(size: 22.0))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(viewModel.getCurrentDescription())
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
                            Text(viewModel.getCurrentHumidity())
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack {
                            Text("Dewpoint")
                                .font(.system(size: 16.0))
                                .foregroundColor(.white)
                            Text(viewModel.getCurrentDewpoint())
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack {
                            Text(viewModel.setHeatChillLabel())
                                .font(.system(size: 16.0))
                                .foregroundColor(.white)
                            Text(viewModel.getCurrentHeatChill())
                                .font(.system(size: 17.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }

                    Spacer()
                    Spacer()
                }

                .background(
                    Image(uiImage: viewModel.getCurrentConditionImage() ?? #imageLiteral(resourceName: "none.png"))
                        .resizable()
                        .frame(width: 312.0, height: 220.0)
                        .padding(.bottom, 80)
                )

                HStack {
                    Spacer()

                    VStack {
                        Spacer()
                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 0))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 0))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 0))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)

                            .background(
                                Image(uiImage: viewModel.getForecastIcon(index: 0) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .frame(width: 156.0, height: 110.0)
                                    .padding(.bottom, 160)
                            )
                        }

                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 2))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 2))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 2))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)

                            .background(
                                Image(uiImage: viewModel.getForecastIcon(index: 2) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .frame(width: 156.0, height: 110.0)
                                    .padding(.bottom, 160)
                            )
                        }

                        Spacer()
                        Spacer()
                    }

                    Spacer()
                    Spacer()

                    VStack {
                        Spacer()
                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 1))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 1))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 1))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)

                            .background(
                                Image(uiImage: viewModel.getForecastIcon(index: 1) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .frame(width: 156.0, height: 110.0)
                                    .padding(.bottom, 160)
                            )
                        }

                        Spacer()

                        VStack {
                            Text(viewModel.getForecastName(index: 3))
                                .font(.system(size: 16.0))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image("none")
                                .resizable()
                                .scaledToFit()
                            Text(viewModel.getForecastTemp(index: 3))
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                            Text(viewModel.getForecastText(index: 3))
                                .font(.system(size: 15.0))
                                .foregroundColor(.white)

                            .background(
                                Image(uiImage: viewModel.getForecastIcon(index: 3) ?? #imageLiteral(resourceName: "none.png"))
                                    .resizable()
                                    .frame(width: 156.0, height: 110.0)
                                    .padding(.bottom, 160)
                            )
                        }

                        Spacer()
                        Spacer()
                    }

                    Spacer()
                    Spacer()
                }
            }
        }
    }
}
