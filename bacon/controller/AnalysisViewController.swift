//
//  AnalysisViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {

    var core: CoreLogic?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension AnalysisViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.analysisToTagBreakDown {
            guard let tagAnalysisController = segue.destination as? TagAnalysisViewController else {
                return
            }
            tagAnalysisController.core = core
        }
    }

}
