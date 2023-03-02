//
//  ActiveUserViewCell.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class ActiveUserViewCell: UITableViewCell {

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: SupremeFont.medium, size: 20)
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupUI(_ model: User) {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = model.username
        label.textColor = UIConstants.accentColor
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])

        convertLabelToPassive()
    }

    func convertLabelToPassive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.transition(
                with: self.label,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: {self.label.textColor = UIConstants.lightColor},
                completion: nil)
        }
    }
}
