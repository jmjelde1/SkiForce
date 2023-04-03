//
//  SeasonStatsView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//

import SwiftUI
import Accelerate
import Charts

struct SeasonStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    
    var body: some View {
        let seasonStatData = SetSeasonStatsData(items: items)
        let runCountArray = MakeRunCountArray(items: items)
        let insets = EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        let tripleInsets = EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
        let runData: [RunsPerMonth] = [
            .init(month: "December", count: 24),
            .init(month: "January", count: 40),
            .init(month: "February", count: 66),
            .init(month: "March", count: 45),
            .init(month: "April", count: 55)
        ]
        
        NavigationView{
            
            
            VStack{
                
                Group{
                    HStack{
                        Text("Records")
                            .font(.system(size: 20))
                            .bold()
                    }.padding()
                    
                    Divider()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                        .overlay(.blue)
                    
                    HStack{
                        VStack{
                            Text("\(seasonStatData.maxSpeed, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Max Speed")
                        }.padding(insets)
                        
                        
                        VStack{
                            Text("\(seasonStatData.maxGForce, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Max G Force")
                        }.padding(insets)
                    }
                    
                    HStack{
                        VStack{
                            Text("\(seasonStatData.maxAltitude, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Max Altitude")
                        }.padding(insets)
                        
                        VStack{
                            Text("\(seasonStatData.largestDescent, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Largest Descent")
                        }.padding(insets)

                    }
                    
                    VStack{
                        Text("\(seasonStatData.longestAirtime, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Longest Airtime")
                    }.padding(insets)
                    
                    HStack{
                        Text("Totals")
                            .font(.system(size: 20))
                            .bold()
                    }.padding(.top, 10)
                    
                    Divider()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                        .overlay(.blue)
                    
                    HStack{
                        VStack{
                            Text("\(seasonStatData.amountOfRuns)")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Runs")
                        }.padding(tripleInsets)
                        
                        VStack{
                            Text("\(seasonStatData.amountOfTurns)")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Turns")
                        }.padding(tripleInsets)
                        
                        VStack{
                            Text("\(seasonStatData.amountOfJumps)")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Jumps")
                        }.padding(tripleInsets)
                    }
                } // end group1
                
                Group{
                    HStack{
                        VStack{
                            Text("\(seasonStatData.totalAirtime, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Airtime")
                        }.padding(insets)
                        
                        VStack{
                            Text("\(seasonStatData.totalAltitudeDescent, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Altitude Descent")
                        }.padding(insets)
                    }

                    GroupBox("Amount of Runs - Last Five Months"){
//                        Chart(runCountArray){
//                            BarMark(
//                                x: .value("Week Day", $0.weekday, unit: .day),
//                                y: .value("Run Count", $0.runs)
//                            )
                        
                        Chart {
                            ForEach(runData) { runs in
                                BarMark(
                                    x: .value("Month", runs.month),
                                    y: .value("Count", runs.count)
                                )
                            }
                           
                        
                            .foregroundStyle(Color.red)
                        }
                        .chartYAxis{
                            AxisMarks(position: .leading)
                        }
//                        .chartXAxis{
//                            AxisMarks (values: .stride (by: .day)) { value in
//                                AxisGridLine().foregroundStyle(.orange)
//                                AxisValueLabel(format: .dateTime.weekday(),
//                                               centered: true)
//                            }
//                        }
                        
                    }.groupBoxStyle(ColoredGroupBox())
                        .padding()
                    
                } // end group 2
                
                
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar{
//                    ToolbarItem(placement: .principal){
//                        HStack{
//                            Image(systemName: "star")
//                            Text("Season Stats")
//                                .bold()
//                        }
//
//                    }
//                }
            }
        }
    }
}

struct ColoredGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                    .font(.headline)
                Spacer()
            }
            
            configuration.content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.white)) // Set your color here!!
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(.blue, lineWidth: 2))
        
    }
}

struct SeasonStatData: Identifiable{
    let id = UUID()
    let amountOfRuns: Int
    let amountOfTurns: Int
    let maxGForce: Double
    let maxSpeed: Double
    let averageSpeed: Double
    
    let totalAltitudeDescent: Double
    let maxAltitude: Double
    let largestDescent: Double
    
    let totalAirtime: Double
    let amountOfJumps: Int
    let longestAirtime: Double
    
}

func SetSeasonStatsData(items: FetchedResults<Item>) -> SeasonStatData {
    var maxSpeedArray: [Double] = []
    var averageSpeedArray: [Double] = []
    var gForceArray: [Double] = []
    var totalDescent: Double = 0.0
    var maxAltitudeArray: [Double] = []
    var sumAirTime: Double = 0.0
    var longestAirTimeArray: [Double] = []
    var altitudeDifferenceArray: [Double] = []
    

    var jumps = 0
    var turns = 0
    
    for item in items {
        maxSpeedArray.append(item.maxSpeed)
        averageSpeedArray.append(item.averageSpeed)
        gForceArray.append(item.maxgForce)
        altitudeDifferenceArray.append(item.altitudeDifference)
        maxAltitudeArray.append(item.maxAltitude)
        sumAirTime = sumAirTime + item.sumAirtime
        longestAirTimeArray.append(item.longestAirtime)
        jumps = jumps + Int(item.numOfJumps)
        turns = turns + Int(item.turns)
        totalDescent = totalDescent + item.altitudeDifference
        
    }
    
    let data = SeasonStatData(amountOfRuns: items.count, amountOfTurns: turns, maxGForce: gForceArray.max() ?? 0.0, maxSpeed: maxSpeedArray.max() ?? 0.0, averageSpeed: vDSP.mean(averageSpeedArray), totalAltitudeDescent: totalDescent, maxAltitude: maxAltitudeArray.max() ?? 0.0, largestDescent: altitudeDifferenceArray.max() ?? 0.0, totalAirtime: sumAirTime, amountOfJumps: jumps, longestAirtime: longestAirTimeArray.max() ?? 0.0)
    
    return data
}

func MakeRunCountArray(items: FetchedResults<Item>) -> [RunCount]{
    var array: [RunCount] = []
    let calendar = Calendar.current
    let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
    var countsByDay: [String: Int] = [:]
    
    for item in items {
        if item.timestamp! > oneWeekAgo {
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: item.timestamp!)
                countsByDay["\(String(describing: dayComponents.year!))0\(String(describing: dayComponents.month!))\(String(describing: dayComponents.day!))", default: 0] += 1
           
        }
    }
    print(countsByDay)
    for (dayComponents, count) in countsByDay {
        array.append(RunCount(day: dayComponents, runs: count))

    }

    
    return array
}

struct RunCount: Identifiable {
    let id = UUID()
    let weekday: Date
    let runs: Int
    
    init(day: String, runs: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        self.weekday = formatter.date(from: day) ?? Date.distantPast
        self.runs = runs
    }
    
    var weekdayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return  dateFormatter.string(from: weekday)
    }
}

struct RunsPerMonth: Identifiable {
    var id = UUID()
    var month: String
    var count: Int
}
