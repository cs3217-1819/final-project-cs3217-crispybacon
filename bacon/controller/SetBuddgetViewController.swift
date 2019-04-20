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
            let startDate = try Date().getStartOfCurrentMonth()
            let endDate = try Date().getEndOfCurrentMonth()
            let budget = try Budget(from: startDate, to: endDate, amount: budgetAmount)
            try core.saveBudget(budget)
            performSegue(withIdentifier: Constants.unwindFromBudgetToMain, sender: nil)
        } catch {
            self.handleError(error: error, customMessage: Constants.budgetSetFailureMessage)
        }
    }
}
