//
//  ChartElementView.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartElementView: UIView {
  // MARK: - Properties
  
  private let checkMarkIconImageView = UIImageView(image: #imageLiteral(resourceName: "checkmark"))
  private let colorView = UIView()
  private let titleLabel = UILabel()
  
  var isSelected: Bool = true {
    didSet {
      checkMarkIconImageView.isHidden = !isSelected
    }
  }
  
  // MARK: - Callbacks
  
  var onTap: (() -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func configure(color: UIColor, name: String, selected: Bool) {
    colorView.backgroundColor = color
    titleLabel.text = name
    isSelected = selected
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(colorView)
    colorView.layer.cornerRadius = 3
    colorView.translatesAutoresizingMaskIntoConstraints = false
    colorView.heightAnchor.constraint(equalToConstant: 12).isActive = true
    colorView.widthAnchor.constraint(equalToConstant: 12).isActive = true
    colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    colorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    addSubview(titleLabel)
    titleLabel.font = UIFont.systemFont(ofSize: 14)
    titleLabel.textColor = .black
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 16).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    addSubview(checkMarkIconImageView)
    checkMarkIconImageView.translatesAutoresizingMaskIntoConstraints = false
    checkMarkIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    checkMarkIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    checkMarkIconImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
    checkMarkIconImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
    checkMarkIconImageView.contentMode = .scaleAspectFit
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
  }
  
  // MARK: - Actions
  
  @objc private func handleTap() {
    onTap?()
  }
}
