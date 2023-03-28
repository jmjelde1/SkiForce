//
//  MapView.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/14/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapView: View {
    let latitudeArray: [Double]
    let longitudeArray: [Double]

    var body: some View {
        let coordinates = makeLineCoordinates(latitude: latitudeArray, longitude: longitudeArray)
        let region = makeRegion(coordinates: coordinates)
        MapLineView(region: region, lineCoordinates: coordinates)
    }
}

struct MapLineView: UIViewRepresentable {

  let region: MKCoordinateRegion
  let lineCoordinates: [CLLocationCoordinate2D]

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.region = region

    let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
    mapView.addOverlay(polyline)

    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapLineView

  init(_ parent: MapLineView) {
    self.parent = parent
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let routePolyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(polyline: routePolyline)
      renderer.strokeColor = UIColor.systemBlue
      renderer.lineWidth = 6
      return renderer
    }
    return MKOverlayRenderer()
  }
}


func makeLineCoordinates(latitude: [Double], longitude: [Double]) -> [CLLocationCoordinate2D] {
    
    var array: [CLLocationCoordinate2D] = []
    
    for i in 0...longitude.count-1{
        array.append(CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i]))
    }
    return array
}

func makeRegion(coordinates:[CLLocationCoordinate2D]) -> MKCoordinateRegion {
    
    var middle = coordinates.count/2
    
    let noe = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates[middle].latitude, longitude: coordinates[middle].longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    print(noe.center)
    
    return noe
}




