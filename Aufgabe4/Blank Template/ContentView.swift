//
//  ContentView.swift
//  memoStudies
//
//  Created by Dragan Macos on 25.04.23.
//

import SwiftUI
import MapKit

let dimension = 4

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        @State private var trackingMode = MapUserTrackingMode.follow
        
        var body: some View {
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $trackingMode)
                .edgesIgnoringSafeArea(.all)
        }
}
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
