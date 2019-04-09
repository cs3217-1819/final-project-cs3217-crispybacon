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
    private let formatter = Constants.getDateOnlyFormatter()
    private var referenceDate = Date()
    private var selectedDate = Date()

    @IBOutlet private weak var timePicker: UIDatePicker!
    @IBOutlet private weak var calendarView: JTAppleCalendarView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var yaerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the calendar to show the reference date (default to current date)
        calendarView.scrollToDate(referenceDate, animateScroll: false)
        calendarView.selectDates([referenceDate])

        // Set up year and month labels for the first loaded page
        calendarView.visibleDates { visibleDates in
            self.setUpYearAndMonthLabels(from: visibleDates)
        }
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let date = captureDateFromCalender()
        let time = captureTimeFromPicker()
        selectedDate = combineDateTime(date: date, time: time)
        performSegue(withIdentifier: "timeToAddSuccess", sender: nil)
    }

    private func captureDateFromCalender() -> Date {
        return calendarView.selectedDates.first ?? referenceDate
    }

    private func captureTimeFromPicker() -> Date {
        return timePicker.date
    }

    private func combineDateTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        let components = DateComponents(year: year, month: month, day: day,
                                        hour: hour, minute: minute, second: 0)
        return calendar.date(from: components) ?? date
    }

    func setUpYearAndMonthLabels(from visibleDates: DateSegmentInfo) {
        let firstDate = visibleDates.monthDates.first?.date ?? referenceDate
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
        let start = Constants.minDate
        let end = Constants.maxDate
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

extension DateTimeSelectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timeToAddSuccess" {
            guard let addController = segue.destination as? AddTransactionViewController else {
                return
            }
            addController.dateTime = selectedDate
        }
    }
}
