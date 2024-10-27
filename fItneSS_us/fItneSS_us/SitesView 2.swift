//
//  SitesView 2.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 22/10/24.
//


import SwiftUI
import MapKit

struct SitesView2: View {
    @ObservedObject var mapCoordinator = MapCoordinator()
    
    var body: some View {
        ZStack {
            MapView2(coordinator: mapCoordinator)
                .edgesIgnoringSafeArea(.all)

            Button("Center on Me") {
                if let mapView = mapCoordinator.mapView {
                    print(1)
                    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(region, animated: true)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Circle())
            .position(x: UIScreen.main.bounds.width - 70, y: 100)

            BottomSheetView2 {
                VStack {
                    Text("Nearby Sites").font(.headline)
                    List {
                        Text("Site 1")
                        Text("Site 2")
                        Text("Site 3")
                    }
                }
                .padding()
            }
        }
    }
}

struct MapView_Previews2: PreviewProvider {
    static var previews: some View {
        SitesView2()
    }
}
