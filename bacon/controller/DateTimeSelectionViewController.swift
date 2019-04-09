//
//  DateTimeSelectionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateTimeSelectionViewController: UIViewController {
    let formatter = Constants.getDateOnlyFormatter()

    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var yaerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up year and month labels for the first loaded page
        calendarView.visibleDates { visibleDates in
            self.setUpYearAndMonthLabels(from: visibleDates)
        }
    }

    func setUpYearAndMonthLabels(from visibleDates: DateSegmentInfo) {
        let firstDate = visibleDates.monthDates.first?.date ?? Constants.defaultDate // could it be current?
        yaerLabel.text = Constants.getYearOnlyFormatter().string(from: firstDate)
        monthLabel.text = Constants.getMonthStringOnlyFormatter().string(from: firstDate)
    }

    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell else {
            return
        }
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.white
        } else {
            cell.dateLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }

    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell else {
            return
        }
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
}

extension DateTimeSelectionViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let start = formatter.date(from: "2017-01-01")! // Note
        let end = formatter.date(from: "2017-12-31")! // Note
        let parameters = ConfigurationParameters(startDate: start, endDate: end)
        return parameters
    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let calendarCell = cell as? CalendarCell else {
            return
        }
        sharedFunctionToConfigureCell(calendarCell: calendarCell, cellState: cellState, date: date)
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let rawCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath)
        guard let cell = rawCell as? CalendarCell else {
            return rawCell
        }
        sharedFunctionToConfigureCell(calendarCell: cell, cellState: cellState, date: date)
        return cell
    }

    func sharedFunctionToConfigureCell(calendarCell: CalendarCell, cellState: CellState, date: Date) {
        calendarCell.dateLabel.text = cellState.text

        // Reset cell to avoid reusing problem
        handleCellSelection(view: calendarCell, cellState: cellState)
        handleCellTextColor(view: calendarCell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setUpYearAndMonthLabels(from: visibleDates)
    }
}
