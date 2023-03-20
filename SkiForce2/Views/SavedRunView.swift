//
//  SavedRunView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/5/23.
//

import SwiftUI
import Charts


struct SavedRunView: View {
    let item: Item
    
    @State private var statsTapped = true
    @State private var mapTapped =  false
    @State private var graphTapped = false
    
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    statsTapped = true
                    mapTapped =  false
                    graphTapped = false
                    
                    
                }, label: {Text("Basic Stats")

                })
                .bold()
                .foregroundColor(Color.white)
                .padding()

             
                Spacer()
                
                Button(action: {
                    statsTapped = false
                    mapTapped =  true
                    graphTapped = false
                    
                    
                }, label: {Text("Map")})
                .bold()
                .foregroundColor(Color.white)
                .padding()
                

                Spacer()
                
                Button(action: {
                    statsTapped = false
                    mapTapped =  false
                    graphTapped = true
                    
                }, label: {Text("Graphs")})
                .bold()
                .foregroundColor(Color.white)
                .padding()
               
            }
            .background(.blue.gradient)// end hstack
        

            
            Spacer()
            
            if statsTapped == true{
                StatsView(item: item)
            } else if graphTapped == true{
                GraphView(item: item)
            } else if mapTapped == true{
                MapView(item: item)
            }
            
        }

    }
}

struct GraphView: View{
    let item: Item
    
    @State private var showSelectionBar = false
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    @State private var selectedSpeed = 0.0
    
    
    var body: some View {
        
        let speeds = makeSpeedArray(model: item)
        let motionArray = makeMotionArray(model: item)
        let motionYArray = makeMotionYArray(model: item)
        //        NavigationView(){
        
        var speed_values = makeArrayFromMotionArray(arr: speeds, xValue: false)
        var speed_time_values = makeStringArray(arr: speeds)
        
        VStack{
          
            GroupBox("Speed Graph / meters per second"){
                Chart{
                    ForEach(speeds) { speed in
                        LineMark(
                            x: .value("Time", speed.x_value),
                            y: .value("Speed", speed.y_value))
                    }
//                    .interpolationMethod(.catmullRom)
                    
                }
                .padding()
                .cornerRadius(10)
                .foregroundStyle(.red)
                .chartOverlay {
                    pr in GeometryReader {
                        geoProxy in Rectangle().foregroundStyle(Color.orange.gradient)
                            .frame(width: 2, height: geoProxy.size.height * 0.95)
                            .opacity(showSelectionBar ? 1.0 : 0.0)
                            .offset(x: offsetX)
                        
                        Capsule()
                            .foregroundStyle(.red.gradient)
                            .frame(width: 50, height: 40)
                            .overlay {
                                VStack {
                                    Text("\(selectedSpeed, specifier: "%.2f")")
                                        .font(.system(size: 10))
                                }
                                .foregroundStyle(.white.gradient)
                            }
                            .opacity(showSelectionBar ? 1.0 : 0.0)
                            .offset(x: offsetX - 50)
                        
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture().onChanged { value in
                                if !showSelectionBar {
                                    showSelectionBar = true
                                }
                                let origin = geoProxy[pr.plotAreaFrame].origin
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )
                                offsetX = location.x
                                offsetY = location.y
                                
                                let (time, _) = pr.value(at: location, as: (String, Double).self) ?? ("-", 0.0)
                                print(time)
                                let index = speed_time_values.firstIndex(of: time)
                                let speed = speed_values[index ?? 0]
                                selectedSpeed = speed
                            }
                                .onEnded({ _ in
                                         showSelectionBar = false
                                     }))
                    }
                }
                
            }
            
            
            GroupBox("Motion Stuff"){
                Chart{
                    ForEach(motionArray) { motion in
                        LineMark(
                            x: .value("Time", motion.x_value),
                            y: .value("Speed", motion.y_value))
                    }.interpolationMethod(.catmullRom)
                }
                .padding()
            }
            
            
            GroupBox("Jump Stuff"){
                Chart{
                    ForEach(motionYArray) { motion in
                        LineMark(
                            x: .value("Time", motion.x_value),
                            y: .value("Speed", motion.y_value))
                    }.interpolationMethod(.catmullRom)
                }
            }
            
            
        }
        .navigationTitle(item.name!)
            
        
//    }
    }
}

struct StatsView: View {
    let item: Item
    
    var body: some View{
        VStack{
            // Group 1
            Group{
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
                        Text("\(item.maxSpeed, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Max Speed")
                    }.padding()
                    VStack{
                        Text("\(item.averageSpeed, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Average Speed")
                    }.padding()
                }.padding(.bottom, 30)
                
                HStack{
                    Image(systemName: "mountain.2")
                        .font(.system(size: 15))
                    Text("Altitudes")
                        .font(.system(size: 20))
                }
                
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.blue)
                
                HStack{
                    VStack{
                        Text("\(item.minAltitude, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Min")
                    }.padding()
                    
                    VStack{
                        Text("\(item.maxAltitude, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Max")
                    }.padding()
                    
                    VStack{
                        Text("\(item.altitudeDifference, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Difference")
                    }
                }.padding(.bottom, 30)
                
                HStack{
                    Image(systemName: "figure.skiing.downhill")
                        .font(.system(size: 15))
                    Text("Motion")
                        .font(.system(size: 20))
                }
                
                
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.blue)
                
                HStack{
                    VStack{
                        Text(String(item.turns))
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Amount of turns")
                    }.padding()
                    
                    VStack{
                        Text("\(item.maxgForce, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Max G-Force")
                    }.padding()
                }.padding(.bottom, 30)
            }
            
        
            // Group2
            Group{
                HStack{
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 15))
                    Text("Airtime")
                        .font(.system(size: 20))
                }

                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.blue)
                
                Text("Work in progress")
                    .bold()
                    .foregroundColor(Color.red)
                
                Spacer()
            }
        }
    }
}




struct Speed: Identifiable {
    let id = UUID()
    let x_value: Double
    let y_value: Double
    
    init(x_value: Double, y_value: Double){
        self.x_value = x_value
        self.y_value = y_value
    }
}

struct Motion: Identifiable {
    let id = UUID()
    let x_value: String
    let y_value: Double
    
    init(x_value: Double, y_value: Double){
        self.x_value = String(x_value)
        self.y_value = y_value
    }
}

func makeSpeedArray(model: Item) -> [Motion]{
    let x_arr = model.speedTimeArray
    let y_arr = model.speedArray
    var array: [Motion] = []
    
    for i in 0...x_arr!.count-1{
        array.append(Motion(x_value: x_arr![i], y_value: y_arr![i]))
    }
    return array
}

func makeMotionArray(model: Item) -> [Motion]{
    let x_arr = model.motionTimeArray
    let y_arr = model.motionArray
    var array: [Motion] = []
    
    for i in 0...x_arr!.count-1{
        array.append(Motion(x_value: x_arr![i], y_value: y_arr![i]))
    }
    return array
}

func makeMotionYArray(model: Item) -> [Motion]{
    let x_arr = model.motionTimeArray
    let y_arr = model.motionYArray
    var array: [Motion] = []
    
    for i in 0...x_arr!.count-1{
        array.append(Motion(x_value: x_arr![i], y_value: y_arr![i]))
    }
    return array
}

func makeArrayFromMotionArray(arr: [Motion], xValue: Bool) -> [Double]{
    
    var new_arr: [Double] = []
    
//    if xValue{
//        for value in arr{
//            new_arr.append(value.x_value)
//        }
        
//    } else {
        for value in arr{
            new_arr.append(value.y_value)
        }
//    }
    return new_arr
}

func makeStringArray(arr: [Motion]) -> [String]{
    var new_arr: [String] = []
    
    for value in arr{
        new_arr.append(value.x_value)
    }
    return new_arr
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

