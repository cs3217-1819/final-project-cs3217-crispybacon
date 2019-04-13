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

        let currentTime = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 1
        let futureTime = Calendar.current.date(byAdding: dateComponents, to: currentTime)

        guard let future = futureTime else {
            self.alertUser(title: Constants.warningTitle, message: Constants.budgetSetFailureMessage)
            return
        }

        do {
            let budget = try Budget(from: currentTime, to: future, amount: budgetAmount)
            try core.saveBudget(budget)
            performSegue(withIdentifier: "unwindFromBudgetToMain", sender: nil)
        } catch {
            self.handleError(error: error, customMessage: Constants.budgetSetFailureMessage)
        }
    }
}
