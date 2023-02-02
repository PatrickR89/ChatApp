//
//  MessageInputView.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(didSend message: String)
}

class MessageInputView: UIView {

    var inputField = UITextField()
    let sendButton = UIButton()
    let margin: CGFloat = 5.0
    weak var delegate: MessageInputViewDelegate?

    required init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.addSubview(inputField)
        self.addSubview(sendButton)

        inputField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonImage = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))

        sendButton.setImage(buttonImage, for: .normal)

        sendButton.tintColor = .white
        sendButton.backgroundColor = .systemBlue

        sendButton.layer.cornerRadius = 22

        inputField.backgroundColor = .lightGray
        inputField.textColor = .white
        inputField.text = ""
        inputField.isUserInteractionEnabled = true
        inputField.delegate = self
        inputField.layer.cornerRadius = 22
        inputField.autocorrectionType = .no
        let placeholder = try! NSAttributedString(markdown: "Enter your message...")
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputField.frame.height))
        inputField.leftViewMode = .always
        inputField.attributedPlaceholder = NSAttributedString(attributedString: placeholder)

        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            inputField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margin),
            inputField.heightAnchor.constraint(equalToConstant: 44),
            sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -margin),
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -margin),
            inputField.topAnchor.constraint(equalTo: self.topAnchor, constant: margin)
        ])
    }

    @objc func sendMessage() {
        guard let message = inputField.text, !message.isEmpty else {return}
        delegate?.messageInputView(didSend: message)
        inputField.text = ""
    }
}

extension MessageInputView: UITextFieldDelegate {}
