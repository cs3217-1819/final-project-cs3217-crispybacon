//
//  PreviewImageView.swift
//  bacon
//
//  Created by Lizhi Zhang on 7/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class PreviewImageView: UIImageView {
    var enlargedView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepare()
    }

    func prepare() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enlarge)))
        self.isUserInteractionEnabled = true
    }

    // swiftlint:disable attributes
    @objc func enlarge() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        enlargedView = UIImageView(image: self.image)
        enlargedView?.alpha = 0
        enlargedView?.frame = window.frame
        enlargedView?.contentMode = .scaleAspectFit
        enlargedView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        enlargedView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reduce)))
        enlargedView?.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.enlargedView?.alpha = 1.0
        }
        guard let view = enlargedView else {
            return
        }
        window.addSubview(view)
    }

    @objc func reduce() {
        UIView.animate(withDuration: 0.3, animations: {
            self.enlargedView?.alpha = 0
        }, completion: { _ in
            self.enlargedView?.removeFromSuperview()
            self.enlargedView = nil
        })
    }
    // swiftlint:enable attributes
}
