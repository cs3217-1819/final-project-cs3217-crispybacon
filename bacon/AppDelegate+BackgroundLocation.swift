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

        guard let latestLocation = locations.last else {
            // iOS guarantees that `locations` contains at least 1 CLLocation object
            fatalError("This should never happen")
        }

        // Delegate logic of deciding whether to send user a notification reminder
        // to LocationPrompt module
        LocationPrompt.shouldPromptUser(currentLocation: latestLocation) { decision in
            log.info("LocationPrompt decision=\(decision)")
            if !decision {
                return
            }

            log.info("Creating local notification")

            let notification = UNMutableNotificationContent()
            notification.title = Constants.notificationTitle
            notification.subtitle = Constants.notificationSubtitle
            notification.body = Constants.notificationBody
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let request = UNNotificationRequest(identifier: Constants.notificationIdentifier,
                                                content: notification,
                                                trigger: trigger)

            self.notificationCenter.add(request) { error in
                if let error = error {
                    log.warning("""
                        Error adding notification request to notification center:
                        \(String(describing: error))
                    """)
                } else {
                    log.info("Added notification request to notification center")
                }
            }
        }
    }
}
