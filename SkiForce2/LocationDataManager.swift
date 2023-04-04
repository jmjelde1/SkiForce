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
import CoreML

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
    var skiType: String = ""
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
            
            self.speeds.append(first.speed * 3.6)
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
        maxSpeed = (speeds.max() ?? 0)
        
//        delete last few seconds
//        look at updateInterval to see how much time is deleted
        motion = motion.dropLast(80)
        motionY = motionY.dropLast(80)
        motionTime = motionTime.dropLast(80)
        
//      if mottion is large enough
        if (motion.count < 128){
            skiType = "Not enough data to decide ski type"
        }else{
//        Convert motion into an array Fourier Tranform can take
            let floats = Array(motion.suffix(128)).map{ Float($0) }
//        fast fourier transform
            let transformedData = FourierTransform().Transform(signal: floats)
//            make prediction
            let prediction = PredictSkiType(data: transformedData)
            if prediction == "sl" {
                skiType = "Slalom"
            }else{
                skiType = "Giant Slalom"
            }
        }

        
        
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
        skiType = ""
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
    
    func PredictSkiType(data: [Double]) -> String{
        do {
            let config = MLModelConfiguration()
            let model = try SwiftSkiTypeClassifier(configuration: config)
            let prediction = try model.prediction(_0: data[0], _1: data[1], _2: data[2], _3: data[3], _4: data[4], _5: data[5], _6: data[6], _7: data[7], _8: data[8], _9: data[9], _10: data[10], _11: data[11], _12: data[12], _13: data[13], _14: data[14], _15: data[15], _16: data[16], _17: data[17], _18: data[18], _19: data[19], _20: data[20], _21: data[21], _22: data[22], _23:  data[23], _24: data[24], _25: data[25], _26: data[26], _27: data[27], _28: data[28], _29: data[29], _30: data[30], _31: data[31], _32: data[32], _33: data[33], _34: data[34], _35: data[35], _36: data[36], _37: data[37], _38: data[38], _39: data[39], _40: data[40], _41: data[41], _42: data[42], _43: data[43], _44: data[44], _45: data[45], _46: data[46], _47: data[47], _48: data[48], _49: data[49], _50: data[50], _51: data[51], _52: data[52], _53: data[53], _54: data[54], _55: data[55], _56: data[56], _57: data[57], _58: data[58], _59: data[59], _60: data[60], _61: data[61], _62: data[62], _63: data[63])
            
            return prediction.target
           
        } catch {
            return "Did not work"
        }
    }
}

extension Date {
    func toSeconds() -> Double! {
        return Double(self.timeIntervalSince1970 * 1) // multiply to get thousands etc.
    }
}
