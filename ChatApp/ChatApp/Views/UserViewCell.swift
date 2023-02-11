//
//  UserViewCell.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class UserViewCell: UITableViewCell {

    lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(_ model: User) {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = model.username

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])
    }
}
