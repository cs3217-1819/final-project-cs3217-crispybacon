//
//  SetBuddgetViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 13/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class SetBuddgetViewController: UIViewController {

    @IBOutlet private weak var budgetField: UITextField!

    var core: CoreLogic?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }

        let amountString = budgetField.text
        let amountDecimal = Decimal(string: amountString ?? Constants.defaultBudgetString)
        let budgetAmount = amountDecimal ?? Constants.defaultBudget

        do {
            let startDate = try getStartOfCurrentMonth()
            let endDate = try getEndOfCurrentMonth()
            let budget = try Budget(from: startDate, to: endDate, amount: budgetAmount)
            try core.saveBudget(budget)
            performSegue(withIdentifier: Constants.unwindFromBudgetToMain, sender: nil)
        } catch {
            self.handleError(error: error, customMessage: Constants.budgetSetFailureMessage)
        }
    }

    private func getStartOfCurrentMonth() throws -> Date {
        guard let date = Calendar.current.date(from:
            Calendar.current.dateComponents([.year, .month],
                                            from: Calendar.current.startOfDay(for: Date()))) else {
            throw InitializationError(message: "Should be able to retrieve the start of month.")
        }
        return date
    }

    private func getEndOfCurrentMonth() throws -> Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(month: 1,
                                                                        second: -1),
                                               to: try getStartOfCurrentMonth()) else {
            throw InitializationError(message: "Should be able to retrieve the end of month.")
        }
        return date
    }
}
