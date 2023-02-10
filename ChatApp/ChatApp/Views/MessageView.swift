//
//  MessageView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit

class MessageView: UIView {

    var senderLable = UILabel()
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
        self.addSubview(senderLable)
        self.addSubview(contentLabel)
        self.addSubview(timestampLabel)

        senderLable.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false

        senderLable.numberOfLines = 1
        contentLabel.numberOfLines = 0
        timestampLabel.numberOfLines = 1
        timestampLabel.textColor = .placeholderText
        self.layer.borderColor = UIColor.label.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 15

        NSLayoutConstraint.activate([
            senderLable.topAnchor.constraint(equalTo: self.topAnchor, constant: margin),
            contentLabel.topAnchor.constraint(equalTo: senderLable.bottomAnchor, constant: margin),
            timestampLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: margin),
            senderLable.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: margin),
            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            timestampLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            senderLable.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -margin),
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
