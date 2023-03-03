//
//  MessageView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit

class MessageView: UIView {

    var contentLabel: UILabel = {
        let label = UILabel().createMsgContentLabel()
        return label
    }()
    var timestampLabel: UILabel = {
        let label = UILabel().createMsgTimestampLabel()
        return label
    }()
    let margin: CGFloat = 5

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.addSubview(contentLabel)
        self.addSubview(timestampLabel)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        layer.borderWidth = 1
        layer.cornerRadius = 5
        backgroundColor = .clear

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            timestampLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            contentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            timestampLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            contentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margin)
        ])
    }

    func presentText(sender: Sender, content: String, time: String) {
        contentLabel.text = content
        timestampLabel.text = time

        switch sender {
        case .myself:
            contentLabel.textAlignment = .right
            timestampLabel.textAlignment = .right
            layer.borderColor = ColorConstants.lightMain.cgColor
        case .other:
            contentLabel.textAlignment = .left
            timestampLabel.textAlignment = .left
            layer.borderColor = ColorConstants.inactiveAccentColor.cgColor
        }
    }

    func toggleTimestamp(_ isExpanded: Bool) {

        UIView.transition(with: self, duration: 0.4, options: .transitionFlipFromTop, animations: {
            self.timestampLabel.isHidden = !isExpanded
            let bottomConstraints = self.constraints.filter { constraint in
                constraint.secondAttribute == NSLayoutConstraint.Attribute.bottom
                && (constraint.firstItem as? UILabel == self.contentLabel
                    || constraint.firstItem as? UILabel == self.timestampLabel)
            }
            self.removeConstraints(bottomConstraints)
            switch isExpanded {
            case false:
                NSLayoutConstraint.activate([
                    self.contentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.margin)
                ])
            case true:
                NSLayoutConstraint.activate([
                    self.timestampLabel.topAnchor.constraint(
                        equalTo: self.contentLabel.bottomAnchor,
                        constant: self.margin),
                    self.timestampLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.margin)
                ])
            }
        }, completion: nil)

        layoutIfNeeded()
    }
}
