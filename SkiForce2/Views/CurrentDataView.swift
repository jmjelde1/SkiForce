//
//  CurrentDataView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//

import SwiftUI
import Charts

struct CurrentDataView: View {
    
//    Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var buttonTappedTwice: Bool

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var speedAndMotionData: SpeedAndMotionData
    @State private var showingAlertSave = false
    @State private var showingAlertClose = false
    @State private var name = ""
    @State private var showSelectionBar = false
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    @State private var selectedSpeed = 0.0
    
    var body: some View {
        
        let motionY = makeArrays(time_arr: speedAndMotionData.motionTimeArray, y_arr: speedAndMotionData.motionYArray)
        let motionTime = makeDoubleArrayToStringArray(arr: speedAndMotionData.motionTimeArray)
        let motionY_Yvalues = makeArrayFromMotionArray(arr: motionY)
        
        NavigationView{
            VStack{
                Text("Longest jump \(speedAndMotionData.longestAirtime)")
                Text("Sum airtime \(speedAndMotionData.sumAirtime)")
                Text("num of jumps \(speedAndMotionData.numOfJumps)")
                
                Text("Jump Stuff")
                    .bold()
                Chart{
                    ForEach(motionY) { motion in
                        LineMark(
                            x: .value("Time", motion.x_value),
                            y: .value("Speed", motion.y_value))
                    }
                }.padding()
                    .chartOverlay{
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
                                    let index = motionTime.firstIndex(of: time)
                                    let speed = motionY_Yvalues[index ?? 0]
                                    selectedSpeed = speed
                                }
                                    .onEnded({ _ in
                                        showSelectionBar = false
                                    }))
                        }
                    }
                
            }
            .navigationTitle("Your Run")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Save"){
                        showingAlertSave = true
                    }
                    .alert("Save Run?", isPresented: $showingAlertSave){
                        TextField("Name your run", text: $name)
                        Button("Save", role: .cancel) {
                            addItem(name: name)
                            buttonTappedTwice = false
                        }
                        Button("Cancel", role: .destructive) {}
                        } message: {
                            Text("Saved runs can be viewed in History")
                        }
                    }
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Close"){
                        showingAlertClose = true
                    }.alert("Are you sure you don't want to save your run?", isPresented: $showingAlertClose){
                        TextField("Name your run", text: $name)
                        Button("Save", role: .cancel) {
                            addItem(name: name)
                            buttonTappedTwice = false
                        }
                        Button("Don't Save", role: .destructive) {
                            buttonTappedTwice = false
                        }
                        } message: {
                            Text("All data will be lost if not saved. Saved runs can be viewed in History")
                                .bold()
                        }
                    }
                }
            }
        }
    
    private func addItem(name: String) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = name
            newItem.maxSpeed = speedAndMotionData.maxSpeed
            newItem.speedArray = speedAndMotionData.speedArray
            newItem.speedTimeArray = speedAndMotionData.speedTimeArray
            newItem.averageSpeed = speedAndMotionData.averageSpeed
//            newItem.locationCoordinates = speedAndMotionData.locationCoordinates
            newItem.altitudeDifference = speedAndMotionData.altitudeDifference
            newItem.longitudeArray = speedAndMotionData.longitudeArray
            newItem.latitudeArray = speedAndMotionData.latitudeArray
            newItem.maxAltitude = speedAndMotionData.maxAltitude
            newItem.minAltitude = speedAndMotionData.minAltitude
            
            newItem.motionYArray = speedAndMotionData.motionYArray
            newItem.turns = speedAndMotionData.turns
            newItem.maxgForce = speedAndMotionData.maxGForce
            newItem.motionArray = speedAndMotionData.motionArray
            newItem.motionTimeArray = speedAndMotionData.motionTimeArray
            newItem.longestAirtime = speedAndMotionData.longestAirtime
            newItem.numOfJumps = speedAndMotionData.numOfJumps
            newItem.sumAirtime = speedAndMotionData.sumAirtime
            
            

            do {
                try viewContext.save()
                
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

func makeArrays(time_arr: [Double], y_arr: [Double]) -> [Motion]{
    
    var array: [Motion] = []
    
    for i in 0...time_arr.count-1{
//        print("time arr \(time_arr[i]), y_arr \(y_arr[i])")
        array.append(Motion(x_value: time_arr[i], y_value: y_arr[i]))
    }
    return array
}

private func makeDoubleArrayToStringArray(arr: [Double]) -> [String]{
    var new_arr: [String] = []
    
    for val in arr{
        new_arr.append(String(val))
    }
    return new_arr
}



//struct CurrentDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentDataView(gpsData: GpsData)
//    }
//}
