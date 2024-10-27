//
//  WorkoutSite.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//

import Foundation
import MapKit


struct WorkoutSite: Identifiable {
    var id = UUID()
    var name: String
    var location: String
    var coordinates: CLLocationCoordinate2D
    var hours: String
}
