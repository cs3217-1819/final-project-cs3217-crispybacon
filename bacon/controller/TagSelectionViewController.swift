//
//  TagSelectionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class TagSelectionViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: UIButton!

    var core: CoreLogic?
    var tags = [Tag: [Tag]]()
    var parentTags = [Tag]()
    var selectedTags = Set<Tag>()
    var canEdit = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate tags with the previously stored ones
        loadTags()

        // Display according to editing/non-editing mode
        if canEdit {
            confirmButton.alpha = 0.0
        } else {
            confirmButton.alpha = 1.0
        }
    }

    func loadTags() {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        tags = core.getAllTags()
        parentTags = core.getAllParentTags()
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.tagSelectionToAdd, sender: nil)
    }

    @IBAction func addParentTagButtonPressed(_ sender: UIButton) {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        promptUserForTagName(title: Constants.tagNameInputTitle) { userInput in
            do {
                try core.addParentTag(userInput)
                self.loadTags()
                self.tableView.reloadData()
            } catch {
                self.handleError(error: error, customMessage: Constants.tagAddFailureMessage)
            }
        }
    }

    func promptUserForTagName(title: String, successHandler: @escaping (String) -> Void) {
        self.promptUserForInput(title: title, message: Constants.tagNameInputMessage,
                                inputValidator: { userInput in
                                    return userInput.trimmingCharacters(in: CharacterSet.whitespaces) != ""
        }, successHandler: successHandler, failureHandler: { _ in
            self.alertUser(title: Constants.warningTitle, message: Constants.InvalidTagNameWarning)
        })
    }
}

extension TagSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parentTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "ParentTagCell", for: indexPath)
        guard let parentCell = rawCell as? ParentTagCell else {
            return rawCell
        }
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return rawCell
        }

        // Send necessary data to parent tag cell
        let currentParentTag = parentTags[indexPath.row]
        parentCell.parentTagLabel.text = currentParentTag.value
        parentCell.childTags = tags[currentParentTag] ?? [Tag]()
        parentCell.canEdit = canEdit

        // Reload the sub table of parent tag cell to prevent from reusing issue
        parentCell.subTable.reloadData()

        // Define sub table behaviours
        parentCell.addChildAction = { cell in
            self.promptUserForTagName(title: Constants.tagNameInputTitle) { userInput in
                do {
                    try core.addChildTag(userInput, to: currentParentTag.value)
                    self.loadTags()
                    cell.childTags = self.tags[currentParentTag] ?? [Tag]()
                    cell.subTable.reloadData()
                    self.tableView.reloadData()
                } catch {
                    self.handleError(error: error, customMessage: Constants.tagAddFailureMessage)
                }
            }
        }
        parentCell.selectChildAction = { tag in
            self.selectTag(tag: tag)
        }
        parentCell.unselectChildAction = { tag in
            self.unselectTag(tag: tag)
        }
        return parentCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.info("""
            TagSelectionViewController.didSelectRowAt():
            row=\(indexPath.row))
            """)
        selectTag(tag: parentTags[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        log.info("""
            TagSelectionViewController.didDeselectRowAt():
            row=\(indexPath.row))
            """)
        unselectTag(tag: parentTags[indexPath.row])
    }

    private func selectTag(tag: Tag) {
        if canEdit {
            renameTag(tag: tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func unselectTag(tag: Tag) {
        if canEdit {
            renameTag(tag: tag)
        } else {
            selectedTags.remove(tag)
        }
    }

    private func renameTag(tag: Tag) {
        guard let core = core else {
            self.alertUser(title: Constants.warningTitle, message: Constants.coreFailureMessage)
            return
        }
        promptUserForTagName(title: Constants.tagRenameInputTitle) { userInput in
            do {
                try core.renameTag(for: tag, to: userInput)
                self.tableView.reloadData()
            } catch {
                self.handleError(error: error, customMessage: Constants.tagEditFailureMessage)
            }
        }
    }
}
