//
//  ConversationViewCell.swift
//  ChatApp
//
//  Created by Patrick on 11.02.2023..
//

import UIKit

class ConversationViewCell: UITableViewCell {

    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIConstants.accentColor
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textColor = UIConstants.lightMain
        label.textAlignment = .right
        return label
    }()

    let margin: CGFloat = 5

    func setupUI() {
        contentView.addSubview(userLabel)
        contentView.addSubview(timeLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        userLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            userLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin)
        ])
    }

    func setupCell(_ conversation: Conversation) {
        setupUI()
        userLabel.text = conversation.withUser
        timeLabel.text = "Last message: \(conversation.lastActivity)"
        convertLabelToPassive()
    }

    func convertLabelToPassive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.transition(with: self.userLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {self.userLabel.textColor = UIConstants.lightColor}, completion: nil)
        }
    }
}
