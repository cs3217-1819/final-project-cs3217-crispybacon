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

    override func viewDidLoad() {
        super.viewDidLoad()
        heatmapLayer.map = mapView
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // user's current location at zoom level 10.

        // Lizhi: To change to user's current location
        let currentLocation = CLLocation(latitude: 1.3521, longitude: 103.8198)

        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        // Configure heatmap
        heatmapLayer.radius = 30
        heatmapLayer.map = mapView

        addHeatmap()
        view = mapView
    }


    func addHeatmap() {
        var coords = [GMUWeightedLatLng]()
        let dummyCoordinate = CLLocation(latitude: 1.3521, longitude: 103.8198)
        for _ in 0 ..< 10 {
            coords.append(GMUWeightedLatLng(coordinate: dummyCoordinate.coordinate,
                                            intensity: 1.0))
        }

        heatmapLayer.weightedData = coords
    }

}
