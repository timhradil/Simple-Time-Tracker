import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var today = Date.now
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Button("Next Week") {
                    today += 7 * 24 * 60 * 60
                }
                Button("Last Week") {
                    today -= 7 * 24 * 60 * 60
                }
                ForEach(dataStore.focuses.indices, id:\.self) { index in
                    Toggle(dataStore.focuses[index].name, isOn: $dataStore.focuses[index].isSelected)
                        .frame(alignment: .leading)
                }
            }.frame(width: 100)
            Divider()
            VStack {
                if dataStore.focuses.isEmpty {
                    Text("Create a focus")
                } else {
                    let focusChartData = getFocusChartData(focuses: dataStore.focuses, today: today as NSDate)
                    if focusChartData.isEmpty {
                        Chart(getEmptyFocusChartData()) { data in
                            BarMark(
                                x: .value("Week Day", data.day),
                                y: .value("Minutes", data.minutes)
                            )
                        }
                        .padding()
                        .chartYScale(domain: 0...15)
                        Spacer(minLength: 20)
                    } else {
                        let counts = focusChartData.map{$0.minutes}
                        let max = counts.max()
                        let yLimit = (max!.truncatingRemainder(dividingBy: 15) + 1) * 15
                        Chart(focusChartData) { data in
                            BarMark(
                                x: .value("Week Day", data.day),
                                y: .value("Minutes", data.minutes)
                            )
                            .position(by: .value("Focus", data.name))
                            .foregroundStyle(by: .value("Focus", data.name))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .annotation {
                                if data.minutes > 0 {
                                    Text(verbatim: String(format: "%.0f", data.minutes.rounded(.up))).font(.caption)
                                }
                            }
                        }
                        .padding()
                        .chartYScale(domain: 0...yLimit)
                    }
                }
            }
            .padding()
            .frame(width: 400)
        }.frame(width: 500, height: 200)
    }
}

func getFocusChartData(focuses: [Focus], today: NSDate) -> [FocusChartData] {
    var ret: [FocusChartData] = []
    let lastMonday = getLastMonday(today: today)
    let nextMonday = lastMonday + 7 * 24 * 60 * 60
    let days = ["M","T","W","R","F","S","U"]
    for focus in focuses {
        if focus.isSelected {
            var bins = Array(repeating: 0.0, count: 7)
            for time in focus.times {
                if (time.start > lastMonday && time.start < nextMonday) {
                    bins[Int((time.start - lastMonday) / (24 * 60 * 60))] += time.length
                }
            }
            for i in days.indices {
                ret.append(FocusChartData(day: days[i], minutes: bins[i]/60, name: focus.name))
            }
        }
    }
    return ret
}

func getEmptyFocusChartData() -> [FocusChartData] {
    var ret: [FocusChartData] = []
    let days = ["M","T","W","R","F","S","U"]
    for i in days.indices {
        ret.append(FocusChartData(day: days[i], minutes: 0, name: ""))
    }
    return ret
}

func getLastMonday(today: NSDate) -> Double {
    var nextDateComponent = DateComponents()
    nextDateComponent.weekday = 2
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
    let monday = calendar?.nextDate(after: today as Date, matching: nextDateComponent, options: NSCalendar.Options(arrayLiteral: [.searchBackwards, .matchNextTime]))
    
    return monday!.timeIntervalSince1970
}
