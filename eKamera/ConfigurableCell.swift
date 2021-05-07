//
//  ConfigurableCell.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 07.05.2021.
//

import UIKit


protocol ConfigurableCell: UITableViewCell {
    func configure(_ item: Any)
}
