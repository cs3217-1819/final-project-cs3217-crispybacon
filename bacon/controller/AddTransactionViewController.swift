//
//  AddTransactionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 21/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import CoreLocation

class AddTransactionViewController: UIViewController {

    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var core: CoreLogic?
    var currentMonthTransactions = [Transaction]()
    var transactionType = Constants.defaultTransactionType
    var dateTime = Date()
    var tags = Set<Tag>()
    private var photo: UIImage?
    private var location: CLLocation?

    @IBOutlet private weak var amountField: UITextField!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up transaction type
        if transactionType == .expenditure {
            setExpenditureType()
        } else {
            setIncomeType()
        }

        // Request permission for location services
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        // Get current location immediately
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // hard coded for now
            locationManager.startUpdatingLocation()
            getCurrentLocation()
        }

        // Get prediction and auto-fill in the relevant fields
        getPrediction()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Need to add display location and photo too when ready
        displayDateTime(dateTime: dateTime)
        displayTags(tags: tags)
    }

    private func getPrediction() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        guard let location = location else {
            // Location functionality is disabled
            return
        }
        guard let prediction = core.getPrediction(dateTime,
                                                  CodableCLLocation(location),
                                                  currentMonthTransactions) else {
            return
        }
        // Populate the fields with the prediction result
        amountField.text = prediction.amountPredicred.toFormattedString
        tags = prediction.tagsPredicted
    }

    @IBAction func typeFieldPressed(_ sender: UITapGestureRecognizer) {
        if transactionType == .expenditure {
            setIncomeType()
        } else {
            setExpenditureType()
        }
    }

    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = true
        camera.delegate = self
        present(camera, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        captureInputs()
        performSegue(withIdentifier: Constants.addToMainSuccess, sender: nil)
    }

    private func captureInputs() {
        guard let coreLogic = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }

        let date = captureDate()
        let type = captureType()
        let frequency = captureFrequency()
        let tags = captureTags()
        let amount = captureAmount()
        let description = captureDescription()
        let photo = capturePhoto()
        let location = captureLocation()

        log.info("""
            AddTransactionViewController.captureInputs() with inputs captured:
            date=\(date), type=\(type), frequency=\(frequency), tags=\(tags),
            amount=\(amount), description=\(description), photo=\(String(describing: photo)),
            location=\(String(describing: location)))
            """)

        do {
            try coreLogic.recordTransaction(date: date, type: type, frequency: frequency,
                                            tags: tags, amount: amount, description: description,
                                            image: photo, location: location)
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionAddFailureMessage)
        }
    }

    private func captureDate() -> Date {
        return dateTime
    }

    private func captureType() -> TransactionType {
        return transactionType
    }

    private func captureFrequency() -> TransactionFrequency {
        // swiftlint:disable force_try
        return try! TransactionFrequency(nature: .oneTime, interval: nil, repeats: nil)
        // swiftlint:enable force_try
    }

    private func captureTags() -> Set<Tag> {
        return tags
    }

    private func captureAmount() -> Decimal {
        let amountString = amountField.text
        let amountDecimal = Decimal(string: amountString ?? Constants.defaultAmountString)
        return amountDecimal ?? Constants.defaultAmount
    }

    private func captureDescription() -> String {
        let userInput = descriptionField.text
        return userInput ?? Constants.defaultDescription
    }

    private func capturePhoto() -> CodableUIImage? {
        guard let image = photo else {
            return nil
        }
        return CodableUIImage(image)
    }

    private func captureLocation() -> CodableCLLocation? {
        guard let location = location else {
            return nil
        }
        return CodableCLLocation(location)
    }

    private func getCurrentLocation() {
        guard let currentLocation = locationManager.location else {
            return
        }
        displayLocation(currentLocation)
        location = currentLocation
    }

    private func displayLocation(_ location: CLLocation) {
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                self.locationLabel.text = String(place)
            }
        }
    }

    private func displayDateTime(dateTime: Date) {
        timeLabel.text = Constants.getDateLessPreciseFormatter().string(from: dateTime)
    }

    private func displayTags(tags: Set<Tag>) {
        var tagString = ""
        for tag in tags {
            tagString += tag.toString() + "  "
        }
        if tagString == "" {
            tagString = Constants.addTagMessage
        }
        tagLabel.text = tagString
    }

    private func setExpenditureType() {
        transactionType = .expenditure
        typeLabel.text = "- \(Constants.currency)"
        typeLabel.textColor = UIColor.red
        tagLabel.textColor = UIColor.red
    }

    private func setIncomeType() {
        transactionType = .income
        typeLabel.text = "+ \(Constants.currency)"
        typeLabel.textColor = UIColor.green
        tagLabel.textColor = UIColor.green
    }

}

extension AddTransactionViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            log.info("""
                AddTransactionViewController.didFinishPickingMediaWithInfo():
                No image found!
                """)
            return
        }
        photo = image
    }
}

extension AddTransactionViewController: CLLocationManagerDelegate {
}

extension AddTransactionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.addToTagSelection {
            guard let tagController = segue.destination as? TagSelectionViewController else {
                return
            }
            tagController.core = core
            tagController.canEdit = false
        }
    }
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        if let calendarViewController = segue.source as? DateTimeSelectionViewController {
            dateTime = calendarViewController.selectedDate
        }
        if let tagSelectionViewController = segue.source as? TagSelectionViewController {
            tags = tagSelectionViewController.selectedTags
        }
    }
}
