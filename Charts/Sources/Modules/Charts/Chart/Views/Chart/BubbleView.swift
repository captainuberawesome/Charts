//
//  BubbleView.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class BubbleView: UIView {
  // MARK: - Properties
  
  private let dayMonthLabel = UILabel()
  private let yearLabel = UILabel()
  private let stackView = UIStackView()
  private lazy var dayMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  private lazy var yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
  }()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func configure(time: TimeInterval, values: [YValue]) {
    let date = Date(timeIntervalSince1970: time)
    dayMonthLabel.text = dayMonthFormatter.string(from: date)
    yearLabel.text = yearFormatter.string(from: date)
    
    for subview in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(subview)
      subview.removeFromSuperview()
    }
    
    for value in values {
      let label = UILabel()
      label.textColor = UIColor(hexString: value.colorHex)
      label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
      label.text = "\(value.actualValue)"
      label.textAlignment = .right
      stackView.addArrangedSubview(label)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(dayMonthLabel)
    dayMonthLabel.translatesAutoresizingMaskIntoConstraints = false
    dayMonthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    dayMonthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    dayMonthLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    dayMonthLabel.textColor = .darkGray
    
    addSubview(yearLabel)
    yearLabel.translatesAutoresizingMaskIntoConstraints = false
    yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    yearLabel.topAnchor.constraint(equalTo: dayMonthLabel.bottomAnchor, constant: 2).isActive = true
    yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
    let constraint = yearLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
    constraint.priority = .defaultLow
    constraint.isActive = true
    yearLabel.textColor = .darkGray
    yearLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 2
  }
}
