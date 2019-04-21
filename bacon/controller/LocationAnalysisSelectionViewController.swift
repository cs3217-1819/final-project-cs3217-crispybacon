//
//  LocationAnalysisSelectionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class LocationAnalysisSelectionViewController: UIViewController {

    var core: CoreLogicInterface?
    var fromDate = Date()
    var toDate = Date()
    var locations = [CLLocation]()

    @IBOutlet private weak var toLabel: UILabel!
    @IBOutlet private weak var fromLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        displayTime()
    }

    private func displayTime() {
        let formatter = Constants.getDateOnlyFormatter()
        fromLabel.text = "From: " + formatter.string(from: fromDate)
        toLabel.text = "To: " + formatter.string(from: toDate)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            locations = try core.getBreakdownByLocation(from: fromDate, to: toDate)
            performSegue(withIdentifier: Constants.locationSelectionToLocationAnalysis, sender: nil)
        } catch {
            self.handleError(error: error, customMessage: Constants.analysisFailureMessage)
        }
    }
}

// MARK: LocationAnalysisSelectionViewController: segues
extension LocationAnalysisSelectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.locationSelectionToCalendarFrom {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.unwindDestination = self
            calendarController.referenceDate = fromDate
            calendarController.isSelectingFromDate = true
        }
        if segue.identifier == Constants.locationSelectionToCalendarTo {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.unwindDestination = self
            calendarController.referenceDate = toDate
            calendarController.isSelectingFromDate = false
        }
        if segue.identifier == Constants.locationSelectionToLocationAnalysis {
            guard let locationAnalysisController = segue.destination as? LocationAnalysisViewController else {
                return
            }
            locationAnalysisController.locations = locations
        }
    }

    @IBAction func unwindToLocationAnalysisSelection(segue: UIStoryboardSegue) {
        if let calendarController = segue.source as? DateTimeSelectionViewController {
            if calendarController.isSelectingFromDate {
                fromDate = calendarController.selectedDate
            } else {
                toDate = calendarController.selectedDate
            }
            displayTime()
        }
    }
}
