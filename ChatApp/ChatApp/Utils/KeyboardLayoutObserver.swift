//
//  KeyboardLayoutObserver.swift
//  ChatApp
//
//  Created by Patrick on 09.02.2023..
//

import UIKit
import Combine

class KeyboardLayoutObserver {

    private var cancellables: Set<AnyCancellable> = []

    /// Method creating `KeyboardFrame` observer, modifying UI layout depending on presence of keyboard,
    /// in order to avoid covering UI elements with keyboard.
    /// - Parameter viewController: Instance of `UIViewController` conforming to ``UIViewControllerWithKeyboard`` class,
    /// in order to make required changes on (dis)appearance of keyboard.
    func startKeyboardObserver(for viewController: UIViewControllerWithKeyboard) {
        NotificationCenter.default.publisher(
            for: UIApplication.keyboardWillShowNotification)
        .sink(receiveValue: { notification in

            guard let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification
                .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }
            viewController.keyboardDidUpdate(with: rect.height, for: duration)

        }).store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: UIApplication.keyboardWillHideNotification)
        .sink(receiveValue: { notification in

            guard let duration = notification
                .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }
            viewController.keyboardDidUpdate(with: 0, for: duration)

        }).store(in: &cancellables)
    }
}
