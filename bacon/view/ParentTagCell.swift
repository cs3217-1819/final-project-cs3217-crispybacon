//
//  ParentTagCell.swift
//  bacon
//
//  Created by Lizhi Zhang on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class ParentTagCell: UITableViewCell {

    var dataArr: [String] = []

    // swiftlint:disable private_outlet
    @IBOutlet weak var parentTagLabel: UILabel!
    // swiftlint:enable private_outlet
    @IBOutlet private weak var subTable: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            parentTagLabel.textColor = UIColor.green
        } else {
            parentTagLabel.textColor = UIColor.black
        }
    }

    func setUpTable() {
        subTable?.delegate = self
        subTable?.dataSource = self
    }

}

extension ParentTagCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "ChildTagCell", for: indexPath)
        guard let childTagCell = rawCell as? ChildTagCell else {
            return rawCell
        }
        childTagCell.childTagLabel.text = dataArr[indexPath.row]
        return childTagCell
    }
}
