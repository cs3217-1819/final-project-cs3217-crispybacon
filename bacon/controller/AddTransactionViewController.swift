//
//  AddTransactionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 21/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {

    var isExpenditure = true
    @IBOutlet weak var amountField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Fabian, this is what I need from you
        // model.addTrasaction(date, type, frequency, category, amount)
    }
    
    private func captureDate() -> Date {
        return Date()
    }
    
    private func captureType() -> TransactionType {
        if isExpenditure {
            return .expenditure
        } else {
            return .income
        }
    }
    
    private func captureFrequency() -> TransactionFrequency {
        return try! TransactionFrequency(nature: .oneTime, interval: nil, repeats: nil)
    }
    
    private func captureCategory() -> TransactionCategory {
        return .food
    }
    
    private func captureAmount() -> Decimal {
        // No error handling yet
        // PS: apparently iPad does not support number only keyboards...
        let amountString = amountField.text
        let amountDecimal = Decimal(string: amountString ?? "00.00")
        return amountDecimal ?? 00.00
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
