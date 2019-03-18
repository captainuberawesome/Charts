//
//  BubbleView.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class BubbleView: UIView, DayNightViewConfigurable {

  // MARK: - Properties
  
  private let dayMonthLabel = UILabel()
  private let yearLabel = UILabel()
  private let stackView = UIStackView()
  private var valueLabels: [UILabel] = []
  private let dayNightModeToggler: DayNightModeToggler
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
  
  var calculatedWidth: CGFloat {
    var maxLabelWidth: CGFloat = 0
    for label in valueLabels {
      let frame = label.frame
      label.sizeToFit()
      if label.frame.width > maxLabelWidth {
        maxLabelWidth = label.frame.width
      }
      label.frame = frame
    }
    dayMonthLabel.sizeToFit()
    let dayMonthLabelWidth = dayMonthLabel.frame.width
    return max(100, maxLabelWidth + dayMonthLabelWidth + 24)
  }
  
  // MARK: - Init
  
  init(dayNightModeToggler: DayNightModeToggler, frame: CGRect = .zero) {
    self.dayNightModeToggler = dayNightModeToggler
    super.init(frame: frame)
    setup()
    backgroundColor = dayNightModeToggler.bubbleBackgroundColor
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
    
    valueLabels = []
    
    for value in values {
      let label = UILabel()
      label.textColor = UIColor(hexString: value.colorHex)
      label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
      label.text = "\(value.actualValue)"
      label.textAlignment = .right
      stackView.addArrangedSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
      label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
      valueLabels.append(label)
    }
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    dayMonthLabel.textColor = dayNightModeToggler.dullerTextColor
    yearLabel.textColor = dayNightModeToggler.dullerTextColor
    backgroundColor = dayNightModeToggler.bubbleBackgroundColor
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(dayMonthLabel)
    dayMonthLabel.translatesAutoresizingMaskIntoConstraints = false
    dayMonthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    dayMonthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    dayMonthLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    dayMonthLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    dayMonthLabel.textColor = dayNightModeToggler.dullerTextColor
    
    addSubview(yearLabel)
    yearLabel.translatesAutoresizingMaskIntoConstraints = false
    yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    yearLabel.topAnchor.constraint(equalTo: dayMonthLabel.bottomAnchor, constant: 2).isActive = true
    yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5).isActive = true
    yearLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    let constraint = yearLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
    constraint.priority = .defaultLow
    constraint.isActive = true
    yearLabel.textColor = dayNightModeToggler.dullerTextColor
    yearLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    let stackConstraint = stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
    stackConstraint.priority = .defaultHigh
    stackConstraint.isActive = true
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 2
  }
}
