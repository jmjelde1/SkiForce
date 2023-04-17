//
//  CurrentDataView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//
// View for data that has been collected but not saved
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
        let currInsets = EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        NavigationView{
            ScrollView{
                HStack{
                    Text("Ski Type Prediction: ")
                        .bold()
                        .font(.title3)
                    
                    Text(speedAndMotionData.skiType)
                        .bold()
                        .foregroundColor(.blue)
                        .font(.title3)
                }.padding(.top, 30)
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.red)
                HStack{
                    
                    VStack{
                        Text("\(speedAndMotionData.maxSpeed, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Max Speed (km/h)")
                    }.padding()
                    VStack{
                        Text("\(speedAndMotionData.averageSpeed, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Average Speed (km/h)")
                    }.padding()
                }.padding(.bottom, 20)
               
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.red)
   
                HStack{
                    VStack{
                        Text("\(speedAndMotionData.turns)")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Turns")
                    }.padding()
                    VStack{
                        Text("\(speedAndMotionData.maxGForce, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Max G-force")
                    }.padding()
                }.padding(.bottom, 20)
                
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 40, height: 4)
                    .overlay(.red)
                
                HStack{
                    VStack{
                        Text("\(speedAndMotionData.altitudeDifference, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Total Descent (m)")
                    }.padding()
                    VStack{
                        Text("\(speedAndMotionData.numOfJumps)")
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("Jumps")
                    }.padding()
                }.padding(.bottom, 5)
               
                Spacer()
                    MapView(latitudeArray: speedAndMotionData.latitudeArray, longitudeArray: speedAndMotionData.longitudeArray)
                        .cornerRadius(20)
                        .frame(width: 380, height: 270, alignment: .bottom)
            }
            .navigationTitle("Your Run - Summary")
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
    
//    Saves all data collected from current run
    private func addItem(name: String) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = name
            newItem.maxSpeed = speedAndMotionData.maxSpeed
            newItem.speedArray = speedAndMotionData.speedArray
            newItem.speedTimeArray = speedAndMotionData.speedTimeArray
            newItem.averageSpeed = speedAndMotionData.averageSpeed
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
            newItem.discipline = speedAndMotionData.skiType
            
            do {
                try viewContext.save()
                
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

func makeArrays(time_arr: [Double], y_arr: [Double]) -> [Motion]{
    
    var array: [Motion] = []
    
    for i in 0...time_arr.count-1{
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

private func displayData(items: FetchedResults<Item>){
    for item in items {
        print(item.name!)
        print(item.motionArray!)
    }
}

struct CurrentDataGroupBox: GroupBoxStyle {
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
            .fill(.gray.opacity(0.3)))
    }
}

