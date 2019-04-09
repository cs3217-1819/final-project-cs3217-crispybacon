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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        /*
        if testCalendar.isDateInToday(date) {
            myCustomCell.backgroundColor = red
        } else {
            myCustomCell.backgroundColor = white
        }
        */
    }

}
