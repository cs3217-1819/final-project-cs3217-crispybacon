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

    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        }
    }
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
        let closedNumberView = cell.viewWithTag(13) as? UILabel
        let openNumberView = cell.viewWithTag(5) as? UILabel
        closedNumberView?.text = String(displayedIndex)
        openNumberView?.text = String(displayedIndex)

        let closedDateView = cell.viewWithTag(14) as? UILabel
        let openDateView = cell.viewWithTag(9) as? UILabel
        let openTimeView = cell.viewWithTag(10) as? UILabel
        let date = currentMonthTransactions[arrayIndex].date
        closedDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        openDateView?.text = Constants.getDateOnlyFormatter().string(from: date)
        openTimeView?.text = Constants.getTimeOnlyFormatter().string(from: date)

        let closedAmountView = cell.viewWithTag(15) as? UILabel
        let openAmountView = cell.viewWithTag(7) as? UILabel
        let type = currentMonthTransactions[arrayIndex].type
        let typeString = type == .expenditure ? "-" : "+"
        let amount = currentMonthTransactions[arrayIndex].amount
        let amountString = amount.toFormattedString
        let finalString = typeString + Constants.currencySymbol + (amountString ?? Constants.defaultAmountString)
        closedAmountView?.text = finalString
        openAmountView?.text = finalString

        let closedCategoryView = cell.viewWithTag(4) as? UILabel
        let openCategoryView = cell.viewWithTag(12) as? UILabel
        let category = currentMonthTransactions[arrayIndex].category
        let categoryString = category.rawValue
        closedCategoryView?.text = categoryString
        openCategoryView?.text = categoryString

        let locationView = cell.viewWithTag(11) as? UILabel
        let codableLocation = currentMonthTransactions[arrayIndex].location
        if let location = codableLocation?.location {
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    locationView?.text = String(place)
                }
            }
        }

        let imageView = cell.viewWithTag(6) as? UIImageView
        let codableImgae = currentMonthTransactions[arrayIndex].image
        if let image = codableImgae?.image {
            imageView?.image = image
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

}
