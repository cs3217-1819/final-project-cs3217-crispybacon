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

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }

    private func update() {
        getBreakdown()
        setChart()
    }

    private func getBreakdown() {
        // For testing
        let formatter = Constants.getDateFormatter()
        fromDate = formatter.date(from: "2019-01-01 00:00:00")!
        toDate = formatter.date(from: "2020-01-01 00:00:00")!

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
    }
}
