//
//  MessageView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit

class MessageView: UIView {

    var contentLabel = UILabel()
    var timestampLabel = UILabel()
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

        contentLabel.numberOfLines = 0
        timestampLabel.numberOfLines = 1
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 15
        backgroundColor = .clear

        contentLabel.textColor = UIConstants.lightColor
        timestampLabel.textColor = UIConstants.lightMain
        timestampLabel.font = UIFont.systemFont(ofSize: 12)

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: margin),
            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            timestampLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            contentLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            timestampLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            timestampLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
        ])
    }

    func presentText(sender: Sender, content: String, time: String) {
        contentLabel.text = content
        timestampLabel.text = time

        switch sender {
        case .me:
            contentLabel.textAlignment = .right
            timestampLabel.textAlignment = .right
            layer.borderColor = UIConstants.lightMain.cgColor
        case .other(_):
            contentLabel.textAlignment = .left
            timestampLabel.textAlignment = .left
            layer.borderColor = UIConstants.inactiveAccentColor.cgColor
        }
    }
}
