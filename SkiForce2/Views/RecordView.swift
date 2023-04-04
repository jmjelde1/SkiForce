//
//  RecordView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//

import SwiftUI
import CoreLocation

struct RecordView: View {
    @StateObject var locationDataManager = LocationDataManager()
    
    @State private var buttonTapped = false
    @State private var buttonTappedTwice = false
    @State private var count = 0
    @State var speedArray = [] as [Double]
    @State private var isPresented = false
    
    var body: some View {
        
        VStack {
            
            Button(action: {
                count += 1
                locationDataManager.startUpdatingSpeed()
                locationDataManager.startUpdatingMotion()
                
                buttonTapped.toggle()
                buttonTappedTwice = false
                if count == 2{
                    buttonTappedTwice = true
                    count = 0
                    locationDataManager.stopUpdatingSpeedAndMotion()
                }
                
            }
            ){
                Text(buttonTapped ? "Stop Recording" : "Press to record")
                    .bold()
                    .foregroundColor(Color.white)
                    
//                Text((locationDataManager.locationManager.location?.speed.description ?? "-2"))
               
            }
            .sheet(isPresented: $buttonTappedTwice){
            
                CurrentDataView(buttonTappedTwice: $buttonTappedTwice, speedAndMotionData:  getSpeedAndMotionData(locationDataManager))
                
            }
            .frame(width: 200, height: 200)
            .background(buttonTapped ? Color.red : Color.blue)
            .clipShape(Circle())
            .shadow(color: Color.red, radius: 10)
            
        }
    }
}


struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}

struct SpeedAndMotionData: Identifiable {
    let id = UUID()
    let speedArray: [Double]
    let speedTimeArray: [Double]
    let altitudeDifference: Double
    let averageSpeed: Double
    let maxSpeed: Double
    let latitudeArray: [Double]
    let longitudeArray: [Double]
    let minAltitude: Double
    let maxAltitude: Double
    
    let motionYArray: [Double]
    let motionArray: [Double]
    let motionTimeArray: [Double]
    let maxGForce: Double
    let turns: Int16
    let longestAirtime: Double
    let sumAirtime: Double
    let numOfJumps: Int16
    let skiType: String
}

func getSpeedAndMotionData(_ locationManager: LocationDataManager) -> SpeedAndMotionData{


    let speedAndMotion = SpeedAndMotionData(speedArray: locationManager.speeds, speedTimeArray: locationManager.speedTime, altitudeDifference: locationManager.altitudeDifference, averageSpeed: locationManager.averageSpeed, maxSpeed: locationManager.maxSpeed, latitudeArray: locationManager.latitudeArray, longitudeArray: locationManager.longitudeArray, minAltitude: locationManager.minAltitude, maxAltitude: locationManager.maxAltitude, motionYArray: locationManager.motionY, motionArray: locationManager.motion, motionTimeArray: locationManager.motionTime, maxGForce: locationManager.maxGForce, turns: locationManager.turns, longestAirtime: locationManager.longestAirtime, sumAirtime: locationManager.sumAirtime, numOfJumps: locationManager.numOfJumps, skiType: locationManager.skiType)
    
    locationManager.clearAllData()
    
    return speedAndMotion
}


