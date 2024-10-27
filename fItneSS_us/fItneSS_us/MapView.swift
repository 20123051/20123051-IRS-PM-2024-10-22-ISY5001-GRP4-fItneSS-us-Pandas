//
//  MapView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 22/10/24.
//

import SwiftUI
import MapKit

struct MapView2: UIViewRepresentable {
    @ObservedObject var coordinator: MapCoordinator

    init(coordinator: MapCoordinator) {
        self.coordinator = coordinator
    }

    func makeCoordinator() -> MapCoordinator {
        return coordinator
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // If needed, update the map view when SwiftUI state changes
    }
}

class MapCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    var mapView: MKMapView?
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}
