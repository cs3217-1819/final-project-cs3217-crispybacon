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
    var transactionType = Constants.defaultTransactionType
    private var selectedCategory = Constants.defaultCategory
    private var photo: UIImage?
    private var userLocation: CodableCLLocation?

    @IBOutlet private weak var amountField: UITextField!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var descriptionField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if transactionType == .expenditure {
            setExpenditureType()
        } else {
            setIncomeType()
        }
        categoryLabel.text = Constants.defaultCategoryString
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        captureLocation()
    }

    @IBAction func typeFieldPressed(_ sender: UITapGestureRecognizer) {
        if transactionType == .expenditure {
            setIncomeType()
        } else {
            setExpenditureType()
        }
    }

    @IBAction func categoryButtonPressed(_ sender: UIButton) {
        let userInput = sender.title(for: .normal) ?? Constants.defaultCategoryString
        log.info("""
            AddTransactionViewController.categoryButtonPressed() with arguments:
            sender.title=\(userInput)
            """)
        selectedCategory = TransactionCategory(rawValue: userInput) ?? Constants.defaultCategory
        categoryLabel.text = sender.title(for: .normal) ?? Constants.defaultCategoryString
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
        performSegue(withIdentifier: "addToMainSuccess", sender: nil)
    }

    private func captureInputs() {
        let date = captureDate()
        let type = captureType()
        let frequency = captureFrequency()
        let category = captureCategory()
        let amount = captureAmount()
        let description = captureDescription()
        let photo = capturePhoto()
        let location = userLocation

        log.info("""
            AddTransactionViewController.captureInputs() with inputs captured:
            date=\(date), type=\(type), frequency=\(frequency), category=\(category),
            amount=\(amount), description=\(description), photo=\(String(describing: photo)),
            location=\(String(describing: location)))
            """)

        // Fabian, this is what I need from you
        // model.addTrasaction(date, type, frequency, category, amount)
    }

    private func captureDate() -> Date {
        return Date()
    }

    private func captureType() -> TransactionType {
        return transactionType
    }

    private func captureFrequency() -> TransactionFrequency {
        // swiftlint:disable force_try
        return try! TransactionFrequency(nature: .oneTime, interval: nil, repeats: nil)
        // swiftlint:enable force_try
    }

    private func captureCategory() -> TransactionCategory {
        return selectedCategory
    }

    private func captureAmount() -> Decimal {
        // No error handling yet
        // PS: apparently iPad does not support number only keyboards...
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
    
    private func captureLocation() {
        guard let location = locationManager.location else {
            return
        }
        // Display
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                self.locationLabel.text = "\(place)"
            }
        }
        userLocation = CodableCLLocation(location)
    }

    private func setExpenditureType() {
        transactionType = .expenditure
        typeLabel.text = "- $"
        typeLabel.textColor = UIColor.red
        categoryLabel.textColor = UIColor.red
    }

    private func setIncomeType() {
        transactionType = .income
        typeLabel.text = "+ $"
        typeLabel.textColor = UIColor.green
        categoryLabel.textColor = UIColor.green
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return // ?
        }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

extension AddTransactionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToMainSuccess" {
            guard let mainController = segue.destination as? MainPageViewController else {
                return
            }
            mainController.isUpdateNeeded = true
        }
    }
}
