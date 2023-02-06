//
//  LoginController.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine

class LoginController {

    @Published private(set) var inputsAreValid: [Int: Bool] = [:]

    func addInputValidation(_ input: UITextField) {
        inputsAreValid[input.hashValue, default: false] = false
    }

    func validateInput(_ input: UITextField) {
        if input.text?.count ?? 0 > 3 {
            inputsAreValid[input.hashValue, default: false] = true
        } else {
            inputsAreValid[input.hashValue, default: false] = false
        }
    }
    
}
