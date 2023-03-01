//
//  MessageViewCell.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class MessageViewCell: UITableViewCell {

    var viewModel: MessageViewModel? {
        didSet {
            setupContent()
        }
    }

    var messageView = MessageView()
    let margin: CGFloat = 5

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.frame = frame

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            messageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -10)
        ])
    }

    func setupContent() {
        guard let viewModel = viewModel else {
            messageView.presentText(sender: .me, content: "", time: "")
            return
        }

        messageView.presentText(sender: viewModel.sender, content: viewModel.content, time: viewModel.timestamp)
        setupUIBySender(viewModel.sender)
    }

    func setupUIBySender(_ sender: Sender) {
        let leadingConstraint = messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin * 2)
        let trailingConstraint = messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin * 2)
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if let constraint = contentView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.leading}) {
            contentView.removeConstraint(constraint)
        }

        if let constraint = contentView.constraints.first(where: {$0.firstAttribute == NSLayoutConstraint.Attribute.trailing}) {
            contentView.removeConstraint(constraint)
        }


        switch sender {
        case .me:
            trailingConstraint.isActive = true

        case .other(_):
            leadingConstraint.isActive = true
        }
    }
}
