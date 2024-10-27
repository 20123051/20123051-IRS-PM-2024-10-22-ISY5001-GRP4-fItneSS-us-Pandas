//
//  SitesView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//

import SwiftUI
import MapKit


struct SitesView: View {
    @StateObject private var mapCoordinator = MapView.MapCoordinator()
    @State private var gyms: [Gym] = []
    private var gymService = GymService()
    var body: some View {
        ZStack(alignment: .top) {
            MapView()
                .edgesIgnoringSafeArea(.all)
            //Button("Center on Me") {
            //    mapCoordinator.centerMapOnUserLocation()
            //}
            //.padding()
            //.background(Color.blue)
            //.foregroundColor(.white)
            //.clipShape(Circle())
            //.position(x: UIScreen.main.bounds.width - 70, y: 100)  // Position the button
            
            BottomSheetView() {
                VStack {
                    Text("Nearby Sites")
                        .font(.headline)
                    List(gyms, id: \.id) { gym in
                        VStack(alignment: .leading) {
                            Text(gym.name).bold()
                            Text(gym.address)
                            Text("Rating: \(gym.rating) - \(gym.distance)")
                            ForEach(gym.opening_hours, id: \.self) { hour in
                                Text(hour)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            let currentLocation = CLLocationCoordinate2D(latitude: 1.29558, longitude: 103.77525) // Placeholder for actual location
            gymService.fetchNearbyGyms(latitude: currentLocation.latitude, longitude: currentLocation.longitude) { gyms in
                self.gyms = gyms
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }
    
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        //添加GestureRecognizer
        let gRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(MapCoordinator.touch(gestureReconizer:)))
        mapView.addGestureRecognizer(gRecognizer)
        //绑定协调器
        mapView.delegate = context.coordinator
        //传入MKMapView对象
        context.coordinator.initMap(mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.showsUserLocation = true
        uiView.showsScale = true
        uiView.showsBuildings = false
        
        let loc = CLLocationCoordinate2D(latitude: 1.29558, longitude: 103.77525)
        let region = MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        uiView.setRegion(uiView.regionThatFits(region), animated: true)
    }
    
    class MapCoordinator : NSObject, MKMapViewDelegate,  ObservableObject{
        
        var mMapView : MKMapView?
        @Published var annotations: [MKAnnotation] = []

        func initMap(_ mapView : MKMapView)  {
            mMapView = mapView
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            print(mapView.centerCoordinate)
        }
        
        @objc func touch(gestureReconizer: UITapGestureRecognizer) {
            let point = gestureReconizer.location(in: gestureReconizer.view)
            let loc = mMapView?.convert(point, toCoordinateFrom: mMapView)
            print(loc!)
        }
        @objc func centerMapOnUserLocation() {
            print("get user location")
            if let userLocation = mMapView?.userLocation.location?.coordinate {
                print("get user location userLocation")
                let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mMapView?.setRegion(region, animated: true)
            }
        }
    }
}


struct BottomSheetView<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position = BottomSheetPosition.half
    var content: () -> Content
    
    var body: some View {
        let dragGesture = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return VStack {
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 40, height: 6)
                .foregroundColor(.gray)
                .opacity(0.5)
                .padding(5)
            
            content()
        }
        .padding(10)
        .background(Color(.systemBackground).opacity(0.95))
        .frame(height: UIScreen.main.bounds.height)
        .offset(y: position.offset + self.dragState.translation.height)
        .animation(.interactiveSpring())
        .gesture(dragGesture)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalMovement = drag.translation.height / UIScreen.main.bounds.height
        let downwardMovement = verticalMovement > 0
        let upwardMovement = verticalMovement < 0
        let movementSpeed = abs(drag.predictedEndLocation.y - drag.location.y)

        switch position {
            case .full:
                if downwardMovement {
                    position = .half
                }
            case .half:
                if upwardMovement {
                    position = .full
                } else if downwardMovement {
                    position = .off
                }
            case .off:
                if upwardMovement {
                    position = .half
                }
        }
    }
    
    enum BottomSheetPosition {
        case full, half, off
        
        var offset: CGFloat {
            switch self {
                case .full: return 100
                case .half: return (UIScreen.main.bounds.height / 2 + 100)
                case .off: return (UIScreen.main.bounds.height-100)
            }
        }
    }
    
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
                case .inactive:
                    return .zero
                case .dragging(let translation):
                    return translation
            }
        }
    }
}

struct Gym: Codable, Identifiable {
    var id: Int
    var name: String
    var address: String
    var rating: Double
    var distance: String
    var opening_hours: [String]
    var top_keywords: [Keyword]

    struct Keyword: Codable, Hashable {
        var word: String
        var frequency: Int
    }
}

class GymService {
    func fetchNearbyGyms(latitude: Double, longitude: Double, completion: @escaping ([Gym]) -> Void) {
        guard let url = URL(string: "https://fu.tktonny.top/nearby_gyms?latitude=\(latitude)&longitude=\(longitude)") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch gyms: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let gyms = try JSONDecoder().decode([Gym].self, from: data)
                DispatchQueue.main.async {
                    completion(gyms)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        SitesView()
    }
}

