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
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            messageView.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width - 10.0)
        ])
    }

    func setupContent() {
        guard let viewModel = viewModel else {
            messageView.inputText(sender: .me, content: "", time: "")
            return
        }

        messageView.inputText(sender: viewModel.sender, content: viewModel.content, time: viewModel.timestamp)

        switch viewModel.sender {
        case .me:
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        case .other(_):
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        }

    }
}
