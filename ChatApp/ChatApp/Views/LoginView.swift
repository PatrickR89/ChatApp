//
//  LoginView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit
import Combine

protocol LoginViewDelegate: AnyObject {
    func loginView(didRequestLoginFor user: LoginRequest)
}

class LoginView: UIView {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "envelope.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: UIImage.SymbolWeight.thin, scale: UIImage.SymbolScale.large))
        imageView.image = image
        imageView.tintColor = .black
        return imageView
    }()

    let firstNameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your first name")
        return inputField
    }()

    let lastNameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your last name")
        return inputField
    }()

    let usernameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your chat name")
        return inputField
    }()

    let confirmButton: UIButton = {
        let button = UIButton()

        button.layer.cornerRadius = 22
        button.backgroundColor = .systemBlue
        button.setTitle("Register", for: .normal)
        button.tintColor = .white

        return button
    }()

    var observers = [AnyCancellable]()

    var loginButtonController: LoginButtonController

    var delegate: LoginViewDelegate?

    init(with buttonController: LoginButtonController) {
        self.loginButtonController = buttonController
        super.init(frame: .zero)
        setupInputBindings()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.observers = []
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        let textFields = [usernameInput, firstNameInput, lastNameInput]
        let views: [UIView] = [imageView, confirmButton] + textFields

        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }

        textFields.forEach { textField in
            textField.delegate = self
            loginButtonController.addInputValidation(textField)
        }

        confirmButton.addTarget(self, action: #selector(register), for: .touchUpInside)

        NSLayoutConstraint.activate([

            usernameInput.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            firstNameInput.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 20),
            lastNameInput.topAnchor.constraint(equalTo: firstNameInput.bottomAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: usernameInput.topAnchor, constant: -100),
            confirmButton.topAnchor.constraint(equalTo: lastNameInput.bottomAnchor, constant: 20),
            usernameInput.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
            confirmButton.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            firstNameInput.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            lastNameInput.widthAnchor.constraint(equalTo: usernameInput.widthAnchor),
            usernameInput.heightAnchor.constraint(equalToConstant: 40),
            firstNameInput.heightAnchor.constraint(equalToConstant: 40),
            lastNameInput.heightAnchor.constraint(equalToConstant: 40),
            confirmButton.heightAnchor.constraint(equalTo: usernameInput.heightAnchor)

        ])
    }

    @objc func register() {
        guard let username = usernameInput.text else {return}
        guard let firstName = firstNameInput.text else {return}
        guard let lastName = lastNameInput.text else {return}
        let loginRequest = LoginRequest(username: username, name: firstName, surname: lastName)
        delegate?.loginView(didRequestLoginFor: loginRequest)
    }

    private func setupInputBindings() {
        loginButtonController.$inputsAreValid.sink(receiveValue: { [weak self] input in
            if input.values.contains(where: { valid in
                valid == false
            }) {
                self?.confirmButton.setTitle("Enter at least 4 characters in each field", for: .disabled)
                self?.confirmButton.isEnabled = false
                self?.confirmButton.backgroundColor = .lightGray
            } else {
                self?.confirmButton.isEnabled = true
                self?.confirmButton.backgroundColor = .systemBlue
            }
        })
        .store(in: &observers)

        loginButtonController.$isWaiting.sink(receiveValue: { [weak self] isWaiting in
            if isWaiting {
                self?.confirmButton.setTitle("Please wait...", for: .disabled)
                self?.confirmButton.isEnabled = false
                self?.confirmButton.backgroundColor = .lightGray
            } else {
                self?.confirmButton.isEnabled = true
                self?.confirmButton.backgroundColor = .systemBlue
            }
        })
        .store(in: &observers)
    }
}

extension LoginView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.firstNameInput.endEditing(true)
        self.lastNameInput.endEditing(true)
        self.usernameInput.endEditing(true)
    }
}

extension LoginView: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        loginButtonController.validateInput(textField)
    }
}
