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

    @IBOutlet private weak var barChart: BarChartView!

    var core: CoreLogic?
    var tags = [Tag]()
    var amount = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getBreakdown()
        setChart()
    }

    private func getBreakdown() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        let formatter = Constants.getDateFormatter()
        let date = formatter.date(from: "2019-04-01 00:00:00")!
        let tagSet = Set<Tag>(core.getAllParentTags())

        do {
            let results = try core.getBreakdownByTag(from: date, to: Date(), for: tagSet)
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
        if let font = UIFont(name: "Futura", size: 10) {
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
