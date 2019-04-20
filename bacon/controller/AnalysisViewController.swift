//
//  AnalysisViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import Charts

class AnalysisViewController: UIViewController {

    var core: CoreLogic?
    var months = [(Int, Int)]()
    var amounts = [Double]()
    var fromDate = Date()
    var toDate = Date()

    @IBOutlet private weak var lineChart: LineChartView!
    @IBOutlet private weak var toLabel: UILabel!
    @IBOutlet private weak var fromLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up display for no data case
        lineChart.noDataText = Constants.trendNoDataMessage
        lineChart.noDataTextColor = UIColor.black.withAlphaComponent(0.7)
        if let font = UIFont(name: "Futura", size: 20) {
            lineChart.noDataFont = font
        }

        // Set up labels to display time
        displayTime()
    }

    private func update() {
        displayTime()
        getBreakdown()
        setChart()
    }

    private func displayTime() {
        let formatter = Constants.getYearMonthFormatter()
        fromLabel.text = "From: " + formatter.string(from: fromDate)
        toLabel.text = "To: " + formatter.string(from: toDate)
    }

    private func getBreakdown() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            let results = try core.getBreakdownByTime(from: fromDate, to: toDate)
            months = results.0
            amounts = results.1
        } catch {
            self.handleError(error: error, customMessage: Constants.analysisFailureMessage)
        }
    }

    private func setChart() {
        var chartDataEntries = [ChartDataEntry]()
        for index in 0..<months.count {
            chartDataEntries.append(ChartDataEntry(x: Double(index), y: amounts[index]))
        }
        let line = LineChartDataSet(values: chartDataEntries, label: Constants.trendLegend)
        let data = LineChartData(dataSet: line)
        lineChart.data = data
        lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        if let font = UIFont(name: "Futura", size: 17) {
            lineChart.legend.font = font
        }
        lineChart.notifyDataSetChanged()
    }
}

extension AnalysisViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.analysisToTagBreakDown {
            guard let tagAnalysisController = segue.destination as? TagAnalysisViewController else {
                return
            }
            tagAnalysisController.core = core
        }
        if segue.identifier == Constants.analysisToCalendarFrom {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.unwindDestination = self
            calendarController.referenceDate = fromDate
            calendarController.isSelectingFromDate = true
        }
        if segue.identifier == Constants.analysisToCalendarTo {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.unwindDestination = self
            calendarController.referenceDate = toDate
            calendarController.isSelectingFromDate = false
        }
    }

    @IBAction func unwindToAnalysis(segue: UIStoryboardSegue) {
        if let calendarController = segue.source as? DateTimeSelectionViewController {
            if calendarController.isSelectingFromDate {
                fromDate = calendarController.selectedDate
            } else {
                toDate = calendarController.selectedDate
            }
            update()
        }
    }
}
