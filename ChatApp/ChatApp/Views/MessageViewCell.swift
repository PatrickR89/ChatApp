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

    var senderLable = UILabel()
    var contentLabel = UILabel()
    var timestampLabel = UILabel()
    let margin: CGFloat = 2

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.contentView.addSubview(senderLable)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(timestampLabel)

        senderLable.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        senderLable.numberOfLines = 1
        contentLabel.numberOfLines = 0
        timestampLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            senderLable.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: margin),
            contentLabel.topAnchor.constraint(equalTo: senderLable.bottomAnchor, constant: margin),
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: margin),
            senderLable.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            senderLable.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            timestampLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: margin)
        ])
    }

    func setupContent() {
        guard let viewModel = viewModel else {
            senderLable.text = ""
            contentLabel.text = ""
            timestampLabel.text = ""
            return
        }

        contentLabel.text = viewModel.content
        timestampLabel.text = viewModel.timestamp

        switch viewModel.sender {
        case .me:
            senderLable.text = "Me"
            senderLable.textAlignment = .right
            contentLabel.textAlignment = .right
            timestampLabel.textAlignment = .right

        case .other(let name):
            senderLable.text = name
            senderLable.textAlignment = .left
            contentLabel.textAlignment = .left
            timestampLabel.textAlignment = .left
        }

    }
}
