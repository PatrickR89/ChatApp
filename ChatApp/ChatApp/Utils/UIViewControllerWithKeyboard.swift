//
//  KeyboardLayoutProtocol.swift
//  ChatApp
//
//  Created by Patrick on 09.02.2023..
//

import UIKit

class UIViewControllerWithKeyboard: UIViewController {
    var keyboardLayoutGuide = UILayoutGuide()

    func addLayoutGuide(_ bottomView: UIView, _ constant: CGFloat) {
        view.addLayoutGuide(keyboardLayoutGuide)
        NSLayoutConstraint.activate([
            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardLayoutGuide.heightAnchor.constraint(equalToConstant: 0),
            bottomView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: constant)
        ])
    }

    func keyboardDidUpdate(with height: Double, for duration: Double) {
        let constraint = keyboardLayoutGuide.constraintsAffectingLayout(for: .vertical).first { constraintAttribute in
            constraintAttribute.firstAttribute == .height
        }

        constraint?.constant = height
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: duration, delay: 0, options: .allowAnimatedContent) {
            self.view.layoutIfNeeded()
        }
    }
}
