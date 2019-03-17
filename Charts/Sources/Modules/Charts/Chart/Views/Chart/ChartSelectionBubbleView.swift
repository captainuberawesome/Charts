//
//  ChartSelectionBubbleView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartSelectionBubbleView: UIView {
  private let bubbleView = BubbleView()
  private let verticalLineView = UIView()
  private var tapXCoordinate: CGFloat = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    verticalLineView.frame = CGRect(x: tapXCoordinate - 0.5, y: bubbleView.frame.maxY - 5, width: 0.5,
                                    height: bounds.height - bubbleView.frame.maxY + 5)
  }
  
  func configure(time: TimeInterval, tapData: [YAxisTapData], tapXCoordinate: CGFloat) {
    self.tapXCoordinate = tapXCoordinate
    bubbleView.configure(time: time, values: tapData.compactMap { $0.value })
    bubbleView.layoutIfNeeded()
    verticalLineView.frame = CGRect(x: tapXCoordinate - 0.5, y: bubbleView.frame.maxY - 5, width: 0.5,
                                    height: bounds.height - bubbleView.frame.maxY + 5)
  }
  
  private func setup() {
    addSubview(verticalLineView)
    verticalLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    addSubview(bubbleView)
    bubbleView.translatesAutoresizingMaskIntoConstraints = false
    bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    bubbleView.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 245 / 255, alpha: 1)
    bubbleView.layer.cornerRadius = 5
  }
}

private class BubbleView: UIView {
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
  
  private func setup() {
    addSubview(dayMonthLabel)
    dayMonthLabel.translatesAutoresizingMaskIntoConstraints = false
    dayMonthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
    dayMonthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    dayMonthLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    dayMonthLabel.textColor = .darkGray
    
    addSubview(yearLabel)
    yearLabel.translatesAutoresizingMaskIntoConstraints = false
    yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    yearLabel.topAnchor.constraint(equalTo: dayMonthLabel.bottomAnchor, constant: 5).isActive = true
    yearLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
    let constraint = yearLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
    constraint.priority = .defaultLow
    constraint.isActive = true
    yearLabel.textColor = .darkGray
    yearLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 5
  }
}
