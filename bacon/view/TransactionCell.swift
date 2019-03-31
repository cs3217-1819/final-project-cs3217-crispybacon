//
//  TransactionCell.swift
//  bacon
//
//  Created by Lizhi Zhang on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class TransactionCell: FoldingCell {

    @IBOutlet private weak var openLabel: UILabel!

    var number: Int = 0 {
        didSet {
            openLabel.text = String(number)
        }
    }

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type: AnimationType) -> TimeInterval {

        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
}
