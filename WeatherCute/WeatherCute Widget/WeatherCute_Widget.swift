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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WeatherCute_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView()
    }
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
    }
}

struct WeatherCute_Widget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherCute_WidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
