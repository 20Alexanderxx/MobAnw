//
//  ContentView.swift
//  memoStudies
//
//  Created by Dragan Macos on 25.04.23.
//

import SwiftUI
import MapKit
import CoreLocation
import AVFoundation

struct Station: Identifiable {
    let id = UUID()
    let region: CLCircularRegion
    let task: String
    var dist_to_loc = 0.0
    var wasEntered: Bool = false
    var isCompleted: Bool = false
    var showAlert: Bool = false
}

// redefine (delegate) LocationManager because we want to modify and use it for our purposes
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationPermissionDenied = false
    
    @Published var regions: Array<Station> = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    convenience init(regionList region: Array<Station>) {
        self.init()
        regions = region
    }
    
    
    //that is our interesting function that we want to hijack
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            
            for index in regions.indices {
                regions[index].dist_to_loc = (currentLocation?.distance(
                    from: CLLocation(latitude: regions[index].region.center.latitude, longitude: regions[index].region.center.longitude)) ?? 0.0) as Double
                if !regions[index].wasEntered { // check if the station is not completed before updating its status
                    regions[index].wasEntered = regions[index].region.contains(CLLocationCoordinate2D(latitude: currentLocation?.coordinate.latitude ?? 0, longitude: currentLocation?.coordinate.longitude ?? 0))
                    if regions[index].wasEntered {
                        regions[index].showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {self.regions[index].showAlert = false}
                        AudioServicesPlayAlertSound(1150) //1150
                    }
                }
            }
        }
    }
}


var regions = [
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.506717, longitude: 13.332841),           radius: 100, identifier: "Bahnhof Zoo"), task: "Den Obdachlosen Hallo sagen"),
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.504988996307304, longitude: 13.33483623811678), radius: 100, identifier: "Gedächtniskirche"), task: "Den Ahnen gedenken"),
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.504766143284044, longitude: 13.35282168752689), radius: 200, identifier: "Lützowplatzpark"), task: "Heroin Spritzen einsammeln"),
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.51456487796334, longitude: 13.350798159127661), radius: 30, identifier: "Ost-Stern"), task: "5 Minuten Smarts zählen"),
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.51620557167104, longitude: 13.381657870151626), radius: 15, identifier: "Cafe Lebensart"), task: "Semmeln kaufen"),
    Station(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.51959759928302, longitude: 13.40705978053755), radius: 500, identifier: "Neptunbrunnen"), task: "Frühstücken")
]

struct ContentView: View {
    
    @StateObject var locationManager = LocationManager(regionList: regions) // declare locationManager as @StateObject
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.505802, longitude: 13.331935),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    @State private var userTrackingMode: MapUserTrackingMode = .follow

    var columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ZStack {
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(locationManager.regions.indices, id: \.self) { index in
                        
                        Button(action: {
                            if !locationManager.regions[index].isCompleted {
                                locationManager.regions[index].isCompleted = true
                            }
                        }) {
                            VStack {
                                Text(locationManager.regions[index].region.identifier).font(.title3)
                                Text(locationManager.regions[index].task).font(.footnote)
                            }
                            .alert(isPresented: $locationManager.regions[index].showAlert) {
                                Alert(
                                    title: Text(locationManager.regions[index].region.identifier),
                                    message: Text(locationManager.regions[index].task),
                                    dismissButton: .default(Text("Als erledigt markieren!")) {locationManager.regions[index].isCompleted = true}
                                )
                            }
                            .frame(width: (UIScreen.main.bounds.width-2*12) / 2)
                            .padding(4)
                            .background(locationManager.regions[index].wasEntered ? locationManager.regions[index].isCompleted ? Color.green : Color.yellow : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: $userTrackingMode,
                    annotationItems: locationManager.regions,
                    annotationContent: {place in MapAnnotation(
                        coordinate: place.region.center,
                        content: {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text("\(place.region.identifier): \(place.dist_to_loc, specifier: "%.1f")m")
                        }
                    )}
                )
                .gesture( // add a gesture modifier
                    DragGesture()
                        .onChanged { _ in
                            userTrackingMode = .none
                        }
                )
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { // add a button to toggle tracking mode
                        if userTrackingMode == .none {
                            userTrackingMode = .follow // start following user location
                        } else {
                            userTrackingMode = .none // stop following user location
                        }
                    }) {
                        Image(systemName: "location.circle")
                            .resizable()
                            .frame(width: 40, height: 40)// change button title according to tracking mode
                    }
                    .frame(width: 40, height: 40)
                    .padding(7)
                    .foregroundColor(Color.black)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .opacity(userTrackingMode == .none ? 1 : 0) // change button opacity according to tracking mode
                    .animation(.easeInOut)
                    .padding(7)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
