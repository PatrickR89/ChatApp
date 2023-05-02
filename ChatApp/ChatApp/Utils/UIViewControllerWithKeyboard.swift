//
//  KeyboardLayoutProtocol.swift
//  ChatApp
//
//  Created by Patrick on 09.02.2023..
//

import UIKit

/// Class conforms to `UIViewController`,
/// and contains required methods to observe keyboard layout,
/// triggering UI changes on changes followed by keyboard.
class UIViewControllerWithKeyboard: UIViewController {
    var keyboardLayoutGuide = UILayoutGuide()

    /// Method defines new constraints on keyboard changes.
    /// - Parameters:
    ///   - bottomView: Lowest view which has to move in order to give place for keyboard.
    ///   - constant: Constant given as `CGFloat` value,
    ///    with required distance between lowest view's bottom anchor and keyboard layout's top anchor.
    func addLayoutGuide(_ bottomView: UIView, _ constant: CGFloat) {
        view.addLayoutGuide(keyboardLayoutGuide)
        NSLayoutConstraint.activate([
            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardLayoutGuide.heightAnchor.constraint(equalToConstant: 0),
            bottomView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: constant)
        ])
    }

    /// Method triggered by appearance of keyboard, changing constraints and adding animated effect,
    /// - Parameters:
    ///   - height: `Double` value, which is the actuall height of the keyboard.
    ///   - duration: `Double` value, oresenting the required time for the keyboard to (dis)appear
    ///   as the presented view follows that time for required changes.
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
