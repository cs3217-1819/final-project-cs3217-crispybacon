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
        let notif = UNMutableNotificationContent()
        notif.title = "Title"
        notif.subtitle = "Subtitle"
        notif.body = "Notification body"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "foo", content: notif, trigger: trigger)
        notificationCenter.add(request) { error in
            print(String(describing: error))
        }
    }
}
