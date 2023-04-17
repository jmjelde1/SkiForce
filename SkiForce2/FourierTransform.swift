//
//  FourierTransform.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 4/3/23.
//
// Fourier Transform

import Accelerate
import Foundation

class FourierTransform {
    
//   performs a Fourier transform on the signal array
    func Transform(signal: [Float]) -> [Double]{
        // Perform Fourier Transform
        var magnitudes = [Float](repeating: 0, count: Int(signal.count))
        
        var signal_fft = [Float](repeating: 0.0, count: signal.count)
        let log2n = vDSP_Length(log2(Float(signal.count)))
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(FFT_RADIX2))!
        defer { vDSP_destroy_fftsetup(fftSetup) }
        var splitComplexSignal = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: signal),
                                                  imagp: UnsafeMutablePointer(mutating: signal_fft))
        vDSP_fft_zrip(fftSetup, &splitComplexSignal, 1, log2n, FFTDirection(FFT_FORWARD))

        vDSP.absolute(signal_fft, result: &magnitudes)
        var doubles = magnitudes.map{Double($0)}
        return doubles
    }
}
