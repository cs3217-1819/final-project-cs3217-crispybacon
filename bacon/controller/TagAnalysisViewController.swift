//
//  TagAnalysisViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 19/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import Charts

class TagAnalysisViewController: UIViewController {

    @IBOutlet private weak var toLabel: UILabel!
    @IBOutlet private weak var fromLabel: UILabel!
    @IBOutlet private weak var barChart: BarChartView!

    var core: CoreLogic?
    var tags = [Tag]()
    var amount = [Double]()
    var selectedTags = Set<Tag>()
    var fromDate = Date()
    var toDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up display for no data case
        barChart.noDataText = Constants.noDataMessage
        barChart.noDataTextColor = UIColor.black.withAlphaComponent(0.7)
        if let font = UIFont(name: "Futura", size: 20) {
            barChart.noDataFont = font
        }

        // Set up labels to display time
        displayTime()
    }

    private func displayTime() {
        let formatter = Constants.getDateOnlyFormatter()
        fromLabel.text = "From: " + formatter.string(from: fromDate)
        toLabel.text = "To: " + formatter.string(from: toDate)
    }

    private func update() {
        displayTime()
        getBreakdown()
        setChart()
    }

    private func getBreakdown() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        do {
            let results = try core.getBreakdownByTag(from: fromDate, to: toDate, for: selectedTags)
            tags = results.0
            amount = results.1
        } catch {
            self.handleError(error: error, customMessage: Constants.analysisFailureMessage)
        }
    }

    private func setChart() {
        var chartDataSets = [ChartDataSet]()
        for index in 0..<tags.count {
            let dataEntry = BarChartDataEntry(x: Double(index), y: amount[index])
            let chartDataSet = BarChartDataSet(values: [dataEntry], label: tags[index].toString())
            chartDataSet.colors = generatereRandomColorForBar(for: index)
            chartDataSets.append(chartDataSet)
        }
        let chartData = BarChartData(dataSets: chartDataSets)
        barChart.data = chartData
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        if let font = UIFont(name: "Futura", size: 17) {
            barChart.legend.font = font
        }
        barChart.notifyDataSetChanged()
    }

    // A utility method to hack around generating different colors for each bar
    // as the library itself does not seem to provide a method for this
    private func generatereRandomColorForBar(for index: Int) -> [UIColor] {
        return [UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)]
    }
}

extension TagAnalysisViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.tagAnalysisToChooseTag {
            guard let tagSelectionController = segue.destination as? TagSelectionViewController else {
                return
            }
            tagSelectionController.core = core
            tagSelectionController.canEdit = false
            tagSelectionController.shouldUnwindToAdd = false
        }
        if segue.identifier == Constants.tagAnalysisToCalendarFrom {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.referenceDate = fromDate
            calendarController.isSelectingFromDate = true
        }
        if segue.identifier == Constants.tagAnalysisToCalendarTo {
            guard let calendarController = segue.destination as? DateTimeSelectionViewController else {
                return
            }
            calendarController.shouldUnwindToAdd = false
            calendarController.referenceDate = toDate
            calendarController.isSelectingFromDate = false
        }
    }

    @IBAction func unwindToTagAnlysis(segue: UIStoryboardSegue) {
        if let tagSelectionController = segue.source as? TagSelectionViewController {
            selectedTags = tagSelectionController.selectedTags
            update()
        }
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
