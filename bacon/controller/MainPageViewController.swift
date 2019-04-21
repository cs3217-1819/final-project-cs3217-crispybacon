//
//  MainPageViewController.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import UIKit

class MainPageViewController: UIViewController {

    var core: CoreLogicInterface?
    var currentMonthTransactions = [Transaction]()
    var currentMonthYear = (0, 0)

    @IBOutlet private weak var budgetLabel: UILabel!
    @IBOutlet private weak var coinView: UIImageView!
    @IBOutlet private weak var pigView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try core = CoreLogic()
        } catch {
            self.handleError(error: error, customMessage: Constants.coreFailureMessage)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        loadCurrentMonthTransactions()
        updateBudgetStatus()
        animateFloatingCoin()
    }

    private func loadCurrentMonthTransactions() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        currentMonthYear = (currentMonth, currentYear)
        do {
            try currentMonthTransactions = core.loadTransactions(month: currentMonthYear.0, year: currentMonthYear.1)
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionLoadFailureMessage)
        }
    }

    @IBAction func budgetButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.mainToSetBudget, sender: nil)
    }

    @IBAction func plusButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.mainToAddTransactionEx, sender: nil)
    }

    @IBAction func coinSwipedUp(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: Constants.mainToAddTransactionEx, sender: nil)
    }

    @IBAction func coinSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: Constants.mainToAddTransactionIn, sender: nil)
    }

    private func updateBudgetStatus() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }

        do {
            let spendingStatus = try core.getSpendingStatus(currentMonthTransactions)
            displayBudgetStatus(status: spendingStatus)
        } catch {
            // Budget has not been set
            performSegue(withIdentifier: Constants.mainToSetBudget, sender: nil)
        }
    }

    private func displayBudgetStatus(status: SpendingStatus) {
        let currentSpending = status.currentSpending.toFormattedString
        let totalBudget = status.totalBudget.toFormattedString
        let percentage = status.percentage

        guard let spending = currentSpending, let budget = totalBudget else {
            self.alertUser(title: Constants.warningTitle, message: Constants.budgetStatusFailureMessage)
            budgetLabel.alpha = 0
            return
        }

        budgetLabel.text = Constants.currency + spending + " / " + Constants.currency + budget

        // Change image of pig and text color to reflect different states of current spending against budget
        // to give an intuitive overview for the user
        if percentage < 1 {
            budgetLabel.textColor = UIColor.green.withAlphaComponent(0.5)
            pigView.image = Constants.happyPig
            if percentage < 0.5 {
                pigView.image = Constants.veryHappyPig
            }
        } else if percentage == 1 {
            budgetLabel.textColor = UIColor.brown.withAlphaComponent(0.5)
            pigView.image = Constants.neutralPig
        } else {
            budgetLabel.textColor = UIColor.red.withAlphaComponent(0.5)
            pigView.image = Constants.sadPig
            if percentage > 1.5 {
                pigView.image = Constants.verySadPig
            }
        }
    }
}

// MARK: MainPageViewController: animations
extension MainPageViewController {
    func animateFloatingCoin() {
        let currentFrame = coinView.frame
        coinView.frame = CGRect(x: currentFrame.minX, y: 130.0,
                                width: currentFrame.width, height: currentFrame.height)
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.coinView.frame = CGRect(x: currentFrame.minX, y: 200.0,
                                         width: currentFrame.width, height: currentFrame.height)
        }, completion: nil)
    }
}

// MARK: MainPageViewController: segues
extension MainPageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.mainToAddTransactionEx {
            guard let addController = segue.destination as? AddTransactionViewController else {
                return
            }
            addController.transactionType = .expenditure
            addController.core = core
            addController.currentMonthTransactions = currentMonthTransactions
            addController.isInEditMode = false
        }
        if segue.identifier == Constants.mainToAddTransactionIn {
            guard let addController = segue.destination as? AddTransactionViewController else {
                return
            }
            addController.transactionType = .income
            addController.core = core
            addController.currentMonthTransactions = currentMonthTransactions
            addController.isInEditMode = false
        }
        if segue.identifier == Constants.mainToTransactions {
            guard let transactionsController = segue.destination as? TransactionsViewController else {
                return
            }
            transactionsController.core = core
            transactionsController.currentMonthTransactions = currentMonthTransactions
            transactionsController.monthCounter = currentMonthYear
        }
        if segue.identifier == Constants.mainToTags {
            guard let tagSelectionController = segue.destination as? TagSelectionViewController else {
                return
            }
            tagSelectionController.core = core
            tagSelectionController.canEdit = true
        }
        if segue.identifier == Constants.mainToSetBudget {
            guard let setBudgetController = segue.destination as? SetBuddgetViewController else {
                return
            }
            setBudgetController.core = core
        }
        if segue.identifier == Constants.mainToAnalysis {
            guard let analysisController = segue.destination as? AnalysisViewController else {
                return
            }
            analysisController.core = core
        }
    }

    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
    }
}
