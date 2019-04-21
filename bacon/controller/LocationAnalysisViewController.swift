//
//  LocationAnalysisViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 19/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import UIKit

class LocationAnalysisViewController: UIViewController {
    private var heatmapLayer: GMUHeatmapTileLayer = GMUHeatmapTileLayer()
    private var mapView = GMSMapView()
    let locationManager = CLLocationManager()
    var locations = [CLLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request permission for location services
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        heatmapLayer.map = mapView
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // user's current location at zoom level 10.
        guard let currentLocation = locationManager.location else {
            return
        }

        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: Float(Constants.heatMapZoom))
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        // Configure heatmap
        heatmapLayer.radius = UInt(Constants.heatMapRadius)
        heatmapLayer.map = mapView

        addHeatmap()
        view = mapView
    }

    func addHeatmap() {
        var coords = [GMUWeightedLatLng]()
        for location in locations {
            coords.append(GMUWeightedLatLng(coordinate: location.coordinate,
                                            intensity: 1.0))
        }
        heatmapLayer.weightedData = coords
    }
}

// MARK: LocationAnalysisViewController: CLLocationManagerDelegate
extension LocationAnalysisViewController: CLLocationManagerDelegate {
}
