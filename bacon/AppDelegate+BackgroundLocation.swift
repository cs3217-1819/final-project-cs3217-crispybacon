//
//  AppDelegate+BackgroundLocation.swift
//  bacon
//
//  Created by Fabian Terh on 19/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import UserNotifications

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        log.info("Received location update.")

        // Create notification
        let notification = UNMutableNotificationContent()
        notification.title = Constants.notificationTitle
        notification.subtitle = Constants.notificationSubtitle
        notification.body = Constants.notificationBody
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: Constants.notificationIdentifier,
                                            content: notification,
                                            trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                log.warning("Error adding notification request to notification center: \(String(describing: error))")
            } else {
                log.info("Added notification request to notification center")
            }
        }
    }
}
