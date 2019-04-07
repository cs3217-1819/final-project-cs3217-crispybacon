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
    var rowsCount: Int {
        return currentMonthTransactions.count
    }

    @IBOutlet private weak var tableView: UITableView! // not being used yet

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentMonthTransactions()
        setUpTableView()
    }

    private func loadCurrentMonthTransactions() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            let calendar = Calendar.current
            let currentDate = Date()
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)
            try currentMonthTransactions = core.loadTransactions(month: currentMonth, year: currentYear)
        } catch {
            self.handleError(error: error, customMessage: Constants.transactionLoadFailureMessage)
        }
    }

    private func setUpTableView() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        //tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
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
        guard let cell = rawCell as? FoldingCell else {
            return rawCell
        }
        let arrayIndex = indexPath.row
        let displayedIndex = arrayIndex + 1

        // FoldingCell-specific congigurations
        let durations: [TimeInterval] = Constants.animatoinDuration
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations

        // Configure views to show data
        let closedNumberView = cell.viewWithTag(Constants.closedNumberView) as? UILabel
        let openNumberView = cell.viewWithTag(Constants.openNumberView) as? UILabel
        closedNumberView?.text = String(displayedIndex)
        openNumberView?.text = String(displayedIndex)

        let closedDateView = cell.viewWithTag(Constants.closedDateView) as? UILabel
        let openDateView = cell.viewWithTag(Constants.openDateView) as? UILabel
        let openTimeView = cell.viewWithTag(Constants.openTimeView) as? UILabel
        let date = currentMonthTransactions[arrayIndex].date
        closedDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        openDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        openTimeView?.text = Constants.getTimeOnlyFormatter().string(from: date)

        let closedAmountView = cell.viewWithTag(Constants.closedAmountView) as? UILabel
        let openAmountView = cell.viewWithTag(Constants.openAmountView) as? UILabel
        let type = currentMonthTransactions[arrayIndex].type
        let typeString = type == .expenditure ? "-" : "+"
        let amount = currentMonthTransactions[arrayIndex].amount
        let amountString = amount.toFormattedString
        let finalString = typeString + Constants.currencySymbol + (amountString ?? Constants.defaultAmountString)
        closedAmountView?.text = finalString
        openAmountView?.text = finalString

        let closedCategoryView = cell.viewWithTag(Constants.closedCategoryView) as? UILabel
        let openCategoryView = cell.viewWithTag(Constants.openCategoryView) as? UILabel
        let category = currentMonthTransactions[arrayIndex].category
        let categoryString = category.rawValue
        closedCategoryView?.text = categoryString
        openCategoryView?.text = categoryString

        let locationView = cell.viewWithTag(Constants.locationView) as? UILabel
        let codableLocation = currentMonthTransactions[arrayIndex].location
        if let location = codableLocation?.location {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    locationView?.text = String(place)
                }
            }
        }

        let imageView = cell.viewWithTag(Constants.imageView) as? UIImageView
        let codableImgae = currentMonthTransactions[arrayIndex].image
        if let image = codableImgae?.image {
            imageView?.image = image
        } else {
            imageView?.image = Constants.defaultImage
        }

        let descriptionView = cell.viewWithTag(Constants.descriptionView) as? UILabel
        let description = currentMonthTransactions[arrayIndex].description
        if description == Constants.defaultDescription {
            descriptionView?.text = Constants.defaultDescriptionToDisplay
        } else {
            descriptionView?.text = description
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
