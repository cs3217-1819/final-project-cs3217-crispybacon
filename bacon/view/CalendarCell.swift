//
//  CalendarCell.swift
//  bacon
//
//  Created by Lizhi Zhang on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    // swiftlint:disable private_outlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    // swiftlint:enable private_outlet
}
