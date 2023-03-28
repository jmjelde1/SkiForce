//
//  LocationDataManager.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/3/23.
//


import Foundation
import CoreLocation
import Accelerate
import CoreMotion

class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    
    var speeds: [Double] = []
    var speedTime: [Double] = []
    var altitudes: [Double] = []
    var maxSpeed: Double = 0
    var averageSpeed: Double = 0
    var altitudeDifference: Double = 0
    var latitudeArray: [Double] = []
    var longitudeArray: [Double] = []
    var maxAltitude: Double = 0
    var minAltitude: Double = 0
    
    var speedStartTime = 0.0;
    var speedFirstTime = true
    
    var motionStartTime = 0.0
    var motionFirstTime = true
    var motion: [Double] = []
    var motionTime: [Double] = []
    var maxGForce: Double = 0.0
    var turns: Int16 = 0
    var motionY: [Double] = []
    
    var longestAirtime: Double = 0.0
    var sumAirtime: Double = 0.0
    var numOfJumps: Int16 = 0
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Insert code to handle location updates
        guard let first = locations.first else {
            return
        }
        if self.speedFirstTime{
            self.speedStartTime = Date().toSeconds()
            self.speedFirstTime = false
        }
        if (Date().toSeconds() - self.speedStartTime > 5){
            
            self.speeds.append(first.speed)
            self.altitudes.append(first.altitude)
        
                
            self.latitudeArray.append(first.coordinate.latitude)
            self.longitudeArray.append(first.coordinate.longitude)
            
            
            self.speedTime.append(Date().toSeconds() - self.speedStartTime - 5)
//        self.speedTime.append(Date().toSeconds() - self.speedStartTime)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func startUpdatingSpeed(){
        locationManager.startUpdatingLocation()
        startUpdatingMotion()
    }
    
    func stopUpdatingSpeedAndMotion() {
        locationManager.stopUpdatingLocation()
        motionManager.stopAccelerometerUpdates()
        
        maxAltitude = altitudes.max() ?? 0
        minAltitude = altitudes.min() ?? 0
        
        turns = NumOfTurns(dist: 10, stepSize: 7)
        
        if(self.altitudes.first != nil && self.altitudes.last != nil){
            altitudeDifference = self.altitudes.first! - self.altitudes.last!
        }else{
            altitudeDifference = 0
        }
        averageSpeed = vDSP.mean(speeds)
        maxSpeed = speeds.max() ?? 0
        
//        delete last few seconds
//        look at updateInterval to see how much time is deleted
//        motion = motion.dropLast(80)
//        motionY = motionY.dropLast(80)
//        motionTime = motionTime.dropLast(80)
        
        
        let airtimes = airtime(motionY: motionY, motionTime: motionTime)
        longestAirtime = airtimes.max() ?? 0
        sumAirtime = airtimes.reduce(0, +)
        numOfJumps = Int16(airtimes.count)
    }
    
    func clearAllData() {
        
        altitudeDifference = 0
        altitudes.removeAll()
        speedTime.removeAll()
        speeds.removeAll()
        speedFirstTime = true
        speedStartTime = 0.0
        latitudeArray.removeAll()
        longitudeArray.removeAll()
        minAltitude = 0
        maxAltitude = 0
        
        motion.removeAll()
        motionTime.removeAll()
        motionY.removeAll()
        maxGForce = 0
        motionFirstTime = true
        motionStartTime = 0.0
        turns = 0
        longestAirtime = 0.0
        sumAirtime = 0.0
        numOfJumps = 0
    }
    
    func startUpdatingMotion(){
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, error) in
            if let trueData = data{
                if self.motionFirstTime{
                    self.motionStartTime = trueData.timestamp
                    self.motionFirstTime = false
                }
                
                if (trueData.timestamp-self.motionStartTime > 5){
                                        
                    self.motion.append(trueData.acceleration.x)
                    self.motionY.append(trueData.acceleration.y)
//                    self.motionTime.append(trueData.timestamp - self.motionStartTime)
                    self.motionTime.append(trueData.timestamp - self.motionStartTime - 5)
                }
            }
            self.maxGForce = Double(self.motion.map(abs).max() ?? -1)
        }
        
    }
    
    func NumOfTurns(dist : Int, stepSize : Int) -> Int16{
        var slopeIsPositive = true
        var currentX = 0.0
        var futureX = 0.0
        var diff = 0.0
        var turns = 0
        for i in stride(from:0, to:self.motion.count-dist-1, by:stepSize){
            currentX = self.motion[i]
            futureX = self.motion[i+dist]
            diff = futureX - currentX
            if (slopeIsPositive && diff<0){
                turns += 1
                slopeIsPositive = false
            }
            else if (slopeIsPositive == false && diff >= 0){
                turns += 1
                slopeIsPositive = true
            }
        }
        return Int16(turns)
    }
    
    func airtime(motionY: [Double], motionTime: [Double]) -> [Double] {
        var airtime: [Double] = []
        var inAir = false
        var hasTakenOff = false
        var startTime = 0.0
        var stopTime = 0.0
        
        for index in 0...motionY.count-2{
            if (motionY[index] < 0.11 && motionY[index] > -0.11) && (motionY[index+1] < 0.11 && motionY[index+1] > -0.11) {
                inAir = true
                hasTakenOff = true
                startTime = motionTime[index]
            } else {
                inAir = false
            }
            if !inAir && hasTakenOff{
                hasTakenOff = false
                stopTime = motionTime[index+1]
                airtime.append(stopTime-startTime)
            }
        }
        
        return airtime
    }
}

extension Date {
    func toSeconds() -> Double! {
        return Double(self.timeIntervalSince1970 * 1) // multiply to get thousands etc.
    }
}
