//
//  TransactionCell.swift
//  bacon
//
//  Created by Lizhi Zhang on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class TransactionCell: FoldingCell {

    // swiftlint:disable private_outlet
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var openTagView: UILabel!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var openTimeView: UILabel!
    @IBOutlet weak var openDateView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var openAmountView: UILabel!
    @IBOutlet weak var closedTagView: UILabel!
    @IBOutlet weak var closedAmountView: UILabel!
    @IBOutlet weak var closedDateView: UILabel!
    @IBOutlet weak var closedNumberView: UILabel!
    // swiftlint:enable private_outlet

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type: AnimationType) -> TimeInterval {
        // timing animation for each view
        // durations count equal it itemCount
        let durations = Constants.animatoinDuration
        return durations[itemIndex]
    }
}
