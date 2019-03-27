//
//  ViewController.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController {

    var isUpdateNeeded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func coinSwipedUp(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "mainToAddTransactionEx", sender: nil)
    }

    @IBAction func coinSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "mainToAddTransactionIn", sender: nil)
    }
}

extension MainPageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainToAddTransactionEx" {
            guard let addController = segue.destination as? AddTransactionViewController else {
                return
            }
            addController.mode = .expenditure
        }
        if segue.identifier == "mainToAddTransactionIn" {
            guard let addController = segue.destination as? AddTransactionViewController else {
                return
            }
            addController.mode = .income
        }
    }
}
