//
//  TransactionsViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import CoreLocation

class TransactionsViewController: UIViewController {

    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
    }

    var core: CoreLogic?
    var cellHeights: [CGFloat] = []
    var currentMonthTransactions = [Transaction]()
    var monthCounter = (0, 0) // is there a better way
    var rowsCount: Int {
        return currentMonthTransactions.count
    }

    @IBOutlet private weak var monthYearLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get current month and year and transactions
        let calendar = Calendar.current
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        monthCounter = (currentMonth, currentYear)
        loadMonthTransactions()
        setUpTableView()
    }

    private func loadMonthTransactions() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            try currentMonthTransactions = core.loadTransactions(month: monthCounter.0, year: monthCounter.1)
            tableView.reloadData()
            monthYearLabel.text = String(monthCounter.0) + "/" + String(monthCounter.1)
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionLoadFailureMessage)
        }
    }
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        var month = monthCounter.0 - 1
        var year = monthCounter.1
        if month == 0 {
            year -= 1
            month = 12
        }
        monthCounter = (month, year)
        loadMonthTransactions()
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        var month = monthCounter.0 + 1
        var year = monthCounter.1
        if month == 13 {
            year += 1
            month = 1
        }
        monthCounter = (month, year)
        loadMonthTransactions()
    }

    private func setUpTableView() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }

    // swiftlint:disable attributes
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        }
    }
    // swiftlint:enable attributes
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return rowsCount
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as TransactionCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        guard let cell = rawCell as? TransactionCell else {
            return rawCell
        }
        let arrayIndex = indexPath.row
        let displayedIndex = arrayIndex + 1

        // FoldingCell-specific congigurations
        let durations: [TimeInterval] = Constants.animatoinDuration
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations

        cell.closedNumberView.text = String(displayedIndex)

        let date = currentMonthTransactions[arrayIndex].date
        cell.closedDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        cell.openDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        cell.openTimeView?.text = Constants.getTimeOnlyFormatter().string(from: date)

        let type = currentMonthTransactions[arrayIndex].type
        let typeString = type == .expenditure ? "-" : "+"
        let amount = currentMonthTransactions[arrayIndex].amount
        let amountString = amount.toFormattedString
        let finalString = typeString + Constants.currencySymbol + (amountString ?? Constants.defaultAmountString)
        cell.closedAmountView.text = finalString
        cell.openAmountView.text = finalString

        let category = currentMonthTransactions[arrayIndex].category
        let categoryString = category.rawValue
        cell.closedCategoryView?.text = categoryString
        cell.openCategoryView?.text = categoryString

        let codableLocation = currentMonthTransactions[arrayIndex].location
        if let location = codableLocation?.location {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    cell.locationView?.text = String(place)
                }
            }
        }

        let description = currentMonthTransactions[arrayIndex].description
        if description == Constants.defaultDescription {
            cell.descriptionView?.text = Constants.defaultDescriptionToDisplay
        } else {
            cell.descriptionView?.text = description
        }

        let imageView = cell.viewWithTag(Constants.imageViewTag) as? UIImageView
        let codableImgae = currentMonthTransactions[arrayIndex].image
        if let image = codableImgae?.image {
            imageView?.image = image
        } else {
            imageView?.image = Constants.defaultImage
        }

        //  icon is not set yet
        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let rawCell = tableView.cellForRow(at: indexPath)
        guard let cell = rawCell as? FoldingCell else {
            return
        }

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.currentMonthTransactions[indexPath.row].delete(successCallback: {
                self.currentMonthTransactions.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.4)
            }, failureCallback: { errorMessage in
                self.alertUser(title: Constants.warningTitle, message: errorMessage)
            })
        }
    }

    // swiftlint:disable attributes
    @objc func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // swiftlint:enable attributes

}
