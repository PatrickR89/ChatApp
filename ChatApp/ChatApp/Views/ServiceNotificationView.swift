//
//  ServiceNotificationView.swift
//  ChatApp
//
//  Created by Patrick on 02.03.2023..
//

import UIKit

class ServiceNotificationView: UIView {

    let notificationLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = UIConstants.darkMainBackground
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIConstants.inactiveAccentColor.cgColor
        label.layer.borderWidth = 2
        label.clipsToBounds = true
        label.textAlignment = .center
        label.textColor = UIConstants.accentColor
        label.numberOfLines = 0

        return label
    }()

    init(frame: CGRect, message: String) {
        super.init(frame: frame)

        notificationLabel.text = message
        setupUI()
        removeSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            notificationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            notificationLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            notificationLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }

    func removeSelf() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.removeFromSuperview()
        }
    }
}
