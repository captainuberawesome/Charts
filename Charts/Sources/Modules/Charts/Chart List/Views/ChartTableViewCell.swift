//
//  ChartTableViewCell.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell, DayNightViewConfigurable {
  // MARK: - Properties
  
  private let separatorView = UIView()
  private let label = UILabel()
  
  static var reuseIdentifier: String {
    return String(describing: self)
  }
  
  // MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = nil
    separatorView.isHidden = true
  }
  
  // MARK: - Public methods
  
  func configure(title: String, showSeparator: Bool) {
    label.text = title
    separatorView.isHidden = showSeparator
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    backgroundColor = dayNightModeToggler.lightBackgroundColor
    contentView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    separatorView.backgroundColor = dayNightModeToggler.separatorColor
    label.textColor = dayNightModeToggler.brightTextColor
  }
  
  // MARK: - Setup
  
  private func setup() {
    contentView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
    label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    label.font = UIFont.systemFont(ofSize: 14)
    
    contentView.addSubview(separatorView)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
    separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    separatorView.isHidden = true
  }
}
