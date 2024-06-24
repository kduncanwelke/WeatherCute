//
//  WeatherCute_Widget.swift
//  WeatherCute Widget
//
//  Created by Kate Duncan-Welke on 4/4/22.
//  Copyright © 2022 Kate Duncan-Welke. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    private let viewModel = ViewModel()
    private let contentViewModel = ContentViewModel()

    func placeholder(in context: Context) -> MyTimelineEntry {
        MyTimelineEntry(date: Date(), useStub: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (MyTimelineEntry) -> ()) {
        let entry: MyTimelineEntry

        if context.isPreview && viewModel.getWeatherLocationTotal() == 0 {
            entry = MyTimelineEntry(date: Date(), useStub: true)
            print("preview")
        } else {
            entry = MyTimelineEntry(date: Date(), useStub: false)
            print("not preview")
        }

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MyTimelineEntry>) -> ()) {
        var entries: [MyTimelineEntry] = []

        viewModel.loadLocations()
        contentViewModel.setSearchParameters()

        contentViewModel.getForecastData(retried: false, completion: {})
        contentViewModel.getWeatherData(completion: {})

        contentViewModel.getAlerts(completion: {
            let currentDate = Date()

            let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

            let entry = MyTimelineEntry(date: entryDate, useStub: false)
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .after(entryDate))
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WeatherCute_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(useStub: entry.useStub)
    }
}

struct MyTimelineEntry: TimelineEntry {
    let date: Date
    let useStub: Bool
}

@main
struct WeatherCute_Widget: Widget {
    let kind: String = "WeatherCute_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherCute_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WeatherCute Widget")
        .description("Current conditions widget")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled()
    }
}

struct WeatherCute_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherCute_WidgetEntryView(entry: MyTimelineEntry(date: Date(), useStub: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
