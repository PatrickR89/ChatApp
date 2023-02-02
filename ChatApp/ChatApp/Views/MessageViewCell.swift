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
    let margin: CGFloat = 5

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
        timestampLabel.textColor = .placeholderText
        contentView.layer.borderColor = UIColor.label.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 15

        NSLayoutConstraint.activate([
            senderLable.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: margin),
            contentLabel.topAnchor.constraint(equalTo: senderLable.bottomAnchor, constant: margin),
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: margin),
            senderLable.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: margin),
            contentLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: margin),
            timestampLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: margin),
            senderLable.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            contentLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            timestampLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
            timestampLabel.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -margin)
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
