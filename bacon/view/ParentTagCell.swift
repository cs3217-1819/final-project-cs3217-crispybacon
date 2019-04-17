//
//  ParentTagCell.swift
//  bacon
//
//  Created by Lizhi Zhang on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class ParentTagCell: UITableViewCell {

    var canEdit = false
    var childTags: [Tag] = []
    var addChildAction: ((ParentTagCell) -> Void)?
    var selectChildAction: ((Tag) -> Void)?
    var unselectChildAction: ((Tag) -> Void)?

    // swiftlint:disable private_outlet
    @IBOutlet weak var parentTagLabel: UILabel!
    @IBOutlet weak var subTable: UITableView!
    // swiftlint:enable private_outlet

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if canEdit {
            return
        }
        if selected {
            parentTagLabel.textColor = UIColor.green.withAlphaComponent(0.5)
        } else {
            parentTagLabel.textColor = UIColor.black
        }
    }

    func setUpTable() {
        subTable?.delegate = self
        subTable?.dataSource = self
    }

    @IBAction func addChildButtonPressed(_ sender: UIButton) {
        addChildAction?(self)
    }
}

extension ParentTagCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "ChildTagCell", for: indexPath)
        guard let childTagCell = rawCell as? ChildTagCell else {
            return rawCell
        }
        childTagCell.childTagLabel.text = childTags[indexPath.row].value
        childTagCell.canEdit = canEdit
        return childTagCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.info("""
            ParentTagCell.subTable.didSelectRowAt():
            row=\(indexPath.row))
            """)
        selectTag(tag: childTags[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        log.info("""
            ParentTagCell.subTable.didDeselectRowAt():
            row=\(indexPath.row))
            """)
        unselectTag(tag: childTags[indexPath.row])
    }

    private func selectTag(tag: Tag) {
        selectChildAction?(tag)
    }

    private func unselectTag(tag: Tag) {
        unselectChildAction?(tag)
    }
}
