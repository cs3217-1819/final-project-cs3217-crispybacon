//
//  MainPageViewController+CLLocationManagerDelegate.swift
//  bacon
//
//  Created by Fabian Terh on 19/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation

extension MainPageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // Do something with locations
    }
}
