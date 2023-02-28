//
//  LoginView.swift
//  ChatApp
//
//  Created by Patrick on 02.02.2023..
//

import UIKit
import Combine

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
        inputField.textColor = UIConstants.accentColor
        return inputField
    }()

    let lastNameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your last name")
        inputField.textColor = UIConstants.accentColor
        return inputField
    }()

    let usernameInput: UITextField = {
        let inputField = UITextField().createInputField("Enter your chat name")
        
        return inputField
    }()

    let firstNameWarning: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIConstants.accentColor
        label.text = "Enter at least 4 characters"
        return label
    }()

    let lastNameWarning: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIConstants.accentColor
        label.text = "Enter at least 4 characters"
        return label
    }()

    let usernameWarning: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIConstants.accentColor
        label.text = "Enter at least 4 characters"
        return label
    }()

    let confirmButton: UIButton = {
        let button = UIButton()

        button.layer.cornerRadius = 22
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIConstants.accentColor, for: .normal)
        button.setTitleColor(UIConstants.darkMain, for: .disabled)
        button.tintColor = .white

        return button
    }()

    let gradient = CAGradientLayer()

    var observers: Set<AnyCancellable> = []

    var loginController: LoginController

    init(with buttonController: LoginController) {
        self.loginController = buttonController
        super.init(frame: .zero)
//        setupUI()
        setupInputBindings()
        loginController.validateInput()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.observers = []
    }
    
    private func setupUI() {
        let textFields = [usernameInput, firstNameInput, lastNameInput]
        let views: [UIView] = [imageView, confirmButton] + textFields

        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }

        textFields.forEach { textField in
            textField.delegate = self
        }

        confirmButton.addTarget(self, action: #selector(register), for: .touchUpInside)

        addNameWarning()
        addLastNameWarning()
        addUsernameWarning()

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

        setupBackground()
    }

    func setFrame(frame: CGRect) {
        self.frame = frame
        setupUI()
        setupBackground()
    }

    private func setupBackground() {
        gradient.colors = [UIConstants.backgroundColorDark.cgColor, UIConstants.backgroundColorLight.cgColor]
        gradient.frame = self.bounds
        gradient.startPoint = .init(x: 0.5, y: 0.5)
        gradient.endPoint = .init(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)

    }

    @objc func register() {
        loginController.sendLoginRequest()
    }

    private func setupInputBindings() {

        loginController.$inputIsValid.sink(receiveValue: { [weak self] input in
            if input == false {
                self?.confirmButton.isEnabled = false
                self?.confirmButton.backgroundColor = UIConstants.lightMain
            } else {
                self?.confirmButton.isEnabled = true
                self?.confirmButton.backgroundColor = UIConstants.darkMain
            }
        })
        .store(in: &observers)

        loginController.$isWaiting.sink(receiveValue: { [weak self] isWaiting in
            if isWaiting {
                self?.confirmButton.isEnabled = false
                self?.confirmButton.backgroundColor = UIConstants.lightMain
            } else {
                self?.confirmButton.isEnabled = true
                self?.confirmButton.backgroundColor = UIConstants.darkMain
            }
        })
        .store(in: &observers)

        loginController.$loginRequest.sink { [weak self] loginRequest in
            if loginRequest.name.count < 4 {
                self?.firstNameWarning.isHidden = false
                self?.firstNameInput.layer.borderColor = UIConstants.accentColor.cgColor
            } else {
                self?.firstNameWarning.isHidden = true
                self?.firstNameInput.layer.borderColor = UIConstants.lightMain.cgColor
            }

            if loginRequest.surname.count < 4 {
                self?.lastNameWarning.isHidden = false
                self?.lastNameInput.layer.borderColor = UIConstants.accentColor.cgColor
            } else {
                self?.lastNameWarning.isHidden = true
                self?.lastNameInput.layer.borderColor = UIConstants.lightMain.cgColor
            }

            if loginRequest.username.count < 4 {
                self?.usernameWarning.isHidden = false
                self?.usernameInput.layer.borderColor = UIConstants.accentColor.cgColor
            } else {
                self?.usernameWarning.isHidden = true
                self?.usernameInput.layer.borderColor = UIConstants.lightMain.cgColor
            }
        }
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
        switch textField {
        case usernameInput:
            loginController.setLoginRequest(textField.text ?? "", .username)
        case firstNameInput:
            loginController.setLoginRequest(textField.text ?? "", .firstName)
        case lastNameInput:
            loginController.setLoginRequest(textField.text ?? "", .lastName)
        default:
            break
        }
    }
}
