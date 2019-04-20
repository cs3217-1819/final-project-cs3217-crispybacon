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

    // To be removed after location manager is up
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()

    var core: CoreLogic?
    var isInEditMode = false

    // Relevant if in Add Mode
    var currentMonthTransactions = [Transaction]()
    var prediction: Prediction?

    // Relevant if in Edit Mode
    var transactionToEdit: Transaction?

    var transactionType = Constants.defaultTransactionType
    var dateTime = Date()
    var tags = Set<Tag>()
    private var photo: UIImage?
    private var location: CLLocation?
    private var frequencyNature: TransactionFrequencyNature = .oneTime
    private var frequencyInterval: TransactionFrequencyInterval?

    @IBOutlet private weak var amountField: UITextField!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var imagePreview: PreviewImageView!
    @IBOutlet private weak var repeatStack: UIStackView!
    @IBOutlet private weak var frequencyLabel: UILabel!
    @IBOutlet private weak var repeatTimeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request permission for location services
        // To be removed after location manager is up
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if isInEditMode {
            setUpEditMode()
        } else {
            setUpAddMode()
        }
        refreshAllViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        refreshAllViews()
    }

    private func setUpEditMode() {
        guard let transactionToEdit = transactionToEdit else {
            alertUser(title: Constants.warningTitle, message: Constants.transactionEditFailureMessage)
            performSegue(withIdentifier: Constants.editToTransactions, sender: nil)
            return
        }
        transactionType = transactionToEdit.type
        amountField.text = transactionToEdit.amount.toFormattedString
        tags = transactionToEdit.tags
        dateTime = transactionToEdit.date
        location = transactionToEdit.location?.location
        photo = transactionToEdit.image?.image
        descriptionField.text = transactionToEdit.description
        frequencyNature = transactionToEdit.frequency.nature
        frequencyInterval = transactionToEdit.frequency.interval
        if let repeatTime = transactionToEdit.frequency.repeats {
            repeatTimeField.text = String(repeatTime)
        }

        checkEditableFields()

        log.info("""
                AddTransactionViewController finished set-up in Edit Mode.
                """)
    }

    private func checkEditableFields() {
        if frequencyNature == .oneTime {
            frequencyLabel.alpha = 0
        } else {
            timeLabel.alpha = 0
        }
    }

    private func setUpAddMode() {
        // To be removed when lcoation manager is up
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // hard coded for now
            locationManager.startUpdatingLocation()
            getCurrentLocation()
        }

        // Get prediction and auto-fill in the relevant fields
        getPrediction()

        log.info("""
                AddTransactionViewController finished set-up in Add Mode.
                """)
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
        prediction = core.getPrediction(dateTime, CodableCLLocation(location), currentMonthTransactions)
        guard let prediction = prediction else {
            return
        }
        // Populate the fields with the prediction result
        amountField.text = prediction.amountPredicted.toFormattedString
        tags = prediction.tagsPredicted
    }

    @IBAction func toggleFrequency(_ sender: UITapGestureRecognizer) {
        if frequencyNature == .oneTime {
            frequencyNature = .recurring
            frequencyInterval = .daily
        } else {
            guard let interval = frequencyInterval else {
                return
            }
            switch interval {
            case .daily:
                frequencyInterval = .weekly
            case .monthly:
                frequencyInterval = .yearly
            case .weekly:
                frequencyInterval = .monthly
            case .yearly:
                if isInEditMode {
                    frequencyInterval = .daily
                } else {
                    frequencyInterval = nil
                    frequencyNature = .oneTime
                }
            }
        }
        displayFrequency()
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
        do {
            let date = captureDate()
            let type = captureType()
            let frequency = try captureFrequency()
            let tags = captureTags()
            let amount = captureAmount()
            let description = captureDescription()
            let image = capturePhoto()
            let location = captureLocation()

            log.info("""
                AddTransactionViewController.captureInputs() with inputs captured:
                date=\(date), type=\(type), frequency=\(frequency), tags=\(tags),
                amount=\(amount), description=\(description), image=\(String(describing: image)),
                location=\(String(describing: location)))
                """)

            if isInEditMode {
                performEdit(date: date, type: type, frequency: frequency, tags: tags, amount: amount,
                            description: description, image: image, location: location)
            } else {
                performAdd(date: date, type: type, frequency: frequency, tags: tags, amount: amount,
                           description: description, image: image, location: location)
            }
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionAddFailureMessage)
        }
    }

    private func performEdit(date: Date, type: TransactionType, frequency: TransactionFrequency,
                             tags: Set<Tag>, amount: Decimal, description: String,
                             image: CodableUIImage?, location: CodableCLLocation?) {
        do {
            try transactionToEdit?.edit(date: date, type: type, frequency: frequency,
                                        tags: tags, amount: amount, description: description,
                                        image: image, location: location, successCallback: {
                self.performSegue(withIdentifier: Constants.editToTransactions, sender: nil)
            }, failureCallback: { errorMessage in
                self.alertUser(title: Constants.warningTitle, message: errorMessage)
            })
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionEditFailureMessage)
        }
    }

    private func performAdd(date: Date, type: TransactionType, frequency: TransactionFrequency,
                            tags: Set<Tag>, amount: Decimal, description: String,
                            image: CodableUIImage?, location: CodableCLLocation?) {
        guard let coreLogic = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            try coreLogic.recordTransaction(date: date, type: type, frequency: frequency,
                                            tags: tags, amount: amount, description: description,
                                            image: image, location: location, prediction: prediction)
            performSegue(withIdentifier: Constants.addToMainSuccess, sender: nil)
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

    private func captureFrequency() throws -> TransactionFrequency {
        if frequencyNature == .oneTime {
            return try TransactionFrequency(nature: .oneTime)
        }
        guard let repeatTime = repeatTimeField.text else {
            throw InvalidArgumentError(message: Constants.repeatTimeMessage)
        }
        return try TransactionFrequency(nature: .recurring, interval: frequencyInterval, repeats: Int(repeatTime))
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
        location = currentLocation
        displayLocation()
    }

    private func refreshAllViews() {
        displayTags()
        displayDateTime()
        displayLocation()
        displayType()
        displayPic()
        displayFrequency()
    }

    private func displayPic() {
        imagePreview.image = photo
    }

    private func displayLocation() {
        guard let location = location else {
            // Location functionality is disabled
            return
        }
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                self.locationLabel.text = String(place)
            }
        }
    }

    private func displayDateTime() {
        timeLabel.text = Constants.getDateLessPreciseFormatter().string(from: dateTime)
    }

    private func displayTags() {
        var tagString = ""
        for tag in tags {
            tagString += tag.toString() + "  "
        }
        if tagString == "" {
            tagString = Constants.addTagMessage
        }
        tagLabel.text = tagString
    }

    private func displayType() {
        if transactionType == .expenditure {
            setExpenditureType()
        } else {
            setIncomeType()
        }
    }

    private func displayFrequency() {
        if frequencyNature == .oneTime {
            frequencyLabel.text = "One-time"
            repeatStack.alpha = 0
            return
        }
        repeatStack.alpha = 1
        guard let interval = frequencyInterval else {
            return
        }
        frequencyLabel.text = interval.rawValue
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
        displayPic()
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
            tagController.shouldUnwindToAdd = true
        }
        if segue.identifier == Constants.addToCalendar {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.referenceDate = dateTime
            calendarController.shouldUnwindToAdd = true
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
