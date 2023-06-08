//
//  ContentView.swift
//  memoStudies
//
//  Created by Dragan Macos on 25.04.23.
//

import SwiftUI
import MapKit
import CoreLocation

struct Station: Identifiable {
    let id = UUID()
    let name: String
    let task: String
    let radius: CLLocationDistance
    let coordinate: CLLocationCoordinate2D
    var wasEntered: Bool = false
    var isCompleted: Bool = false
}

// redefine LocationManager because we want to modify and use it for our purposes
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationPermissionDenied = false
    
    // move the regions property to the LocationManager class and declare it as @Published
    @Published var regions = [
        Station(name: "Bahnhof Zoo", task: "", radius: 500, coordinate: CLLocationCoordinate2D(latitude: 52.506717, longitude: 13.332841)),
        Station(name: "San Francisco", task: "", radius: 1000, coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)),
        Station(name: "Los Angeles", task: "", radius: 1000, coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //implement this because the CLLocationManagerDelegate protocoll wants it that way
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied :
            locationPermissionDenied = true
            print("Denied")
            print(locationPermissionDenied)
        case .restricted:
            print("restricted")
        case .notDetermined:
            print("not Determined")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse :
            print("Authorized when in use")
            manager.allowsBackgroundLocationUpdates = true
            manager.startUpdatingLocation()
        default:
            print("Default")
        }
    }
    
    //implemtent this also because
    func locationManager(_ manager: CLLocationManager, didFailWithError error : Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    //that is our interesting function that we want to hijack
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            
            for index in regions.indices {
                //if !regions[index].isCompleted { // check if the station is not completed before updating its status
                    regions[index].isCompleted = isLocationWithinRegion(location: self.currentLocation ?? CLLocation(latitude: 0, longitude: 0), region: regions[index])
                //}
            }
        }
    }
}

struct ContentView: View {
    @StateObject var locationManager = LocationManager() // declare locationManager as @StateObject
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.505802, longitude: 13.331935),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        VStack {
            Text("Current Location:")
            Text("\(locationManager.currentLocation?.coordinate.latitude ?? 0), \(locationManager.currentLocation?.coordinate.longitude ?? 0)")
            
            // access the regions property of the locationManager instead of the ContentView class
            ForEach(locationManager.regions.indices, id: \.self) { index in
                Button(action: {
                    locationManager.regions[index].isCompleted.toggle()
                }) {
                    Text(locationManager.regions[index].name)
                }
                .padding()
                .background(locationManager.regions[index].isCompleted ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow))
        }
    }
}

func isLocationWithinRegion(location: CLLocation, region: Station) -> Bool {
    let distance = location.distance(from: CLLocation(latitude: region.coordinate.latitude, longitude: region.coordinate.longitude))
    return distance <= region.radius
}

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
