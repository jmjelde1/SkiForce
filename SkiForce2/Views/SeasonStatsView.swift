//
//  SeasonStatsView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//

import SwiftUI
import Accelerate

struct SeasonStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    
    var body: some View {
        let seasonStatData = SetSeasonStatsData(items: items)
        
        NavigationView{
            
            
            VStack{
                
                Group{
                    HStack{
                        VStack{

                            Text("\(seasonStatData.amountOfRuns)")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Runs")
                        }
                        
                        VStack{

                            Text("\(seasonStatData.amountOfTurns)")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Turns")
                        }
                        
                        
                    }
                    HStack{
                        Image(systemName: "speedometer")
                            .font(.system(size: 15))
                        Text("Speeds")
                            .font(.system(size: 20))
                    }.padding(.top, 20)
                    
                    Divider()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                        .overlay(.blue)
                    
                    HStack{
                        VStack{
                            Text("\(seasonStatData.maxSpeed, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Max Speed")
                        }.padding()
                        VStack{
                            Text("\(seasonStatData.averageSpeed, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(Color.blue)
                            Text("Average Speed")
                        }.padding()
                    }.padding(.bottom, 20)
                    
                    
                    
                } // end group1
                
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        HStack{
                            Image(systemName: "star")
                            Text("Season Stats")
                                .bold()
                        }
                        
                    }
                }
            }
        }
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
    
    let totalAirtime: Double
    let amountOfJumps: Int
    let longestAirtime: Double
    
}

func SetSeasonStatsData(items: FetchedResults<Item>) -> SeasonStatData {
    var maxSpeedArray: [Double] = []
    var averageSpeedArray: [Double] = []
    var gForceArray: [Double] = []
    var altitudeDiffernceArray: [Double] = []
    var maxAltitudeArray: [Double] = []
    var sumAirTimeArray: [Double] = []
    var longestAirTimeArray: [Double] = []
    var jumps = 0
    var turns = 0
    
    for item in items {
        maxSpeedArray.append(item.maxSpeed)
        averageSpeedArray.append(item.averageSpeed)
        gForceArray.append(item.maxgForce)
        altitudeDiffernceArray.append(item.altitudeDifference)
        maxAltitudeArray.append(item.maxAltitude)
        sumAirTimeArray.append(item.sumAirtime)
        longestAirTimeArray.append(item.longestAirtime)
        jumps = jumps + Int(item.numOfJumps)
        turns = turns + Int(item.turns)
        
    }
    
    let data = SeasonStatData(amountOfRuns: items.count, amountOfTurns: turns, maxGForce: gForceArray.max() ?? 0.0, maxSpeed: maxSpeedArray.max() ?? 0.0, averageSpeed: vDSP.mean(averageSpeedArray), totalAltitudeDescent: vDSP.sum(altitudeDiffernceArray), maxAltitude: maxAltitudeArray.max() ?? 0.0, totalAirtime: vDSP.sum(sumAirTimeArray), amountOfJumps: jumps, longestAirtime: longestAirTimeArray.max() ?? 0.0)
    
    return data
}
