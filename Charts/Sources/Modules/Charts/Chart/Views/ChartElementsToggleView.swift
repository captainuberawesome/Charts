//
//  ChartElementsToggleView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartElementsToggleView: UIView {
  private let stackView = UIStackView()
  private var yAxes: [YAxis] = []
  
  var onToggledYAxis: ((YAxis) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(yAxes: [YAxis]) {
    self.yAxes = yAxes
    for subview in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(subview)
      subview.removeFromSuperview()
    }
    for (index, yAxis) in yAxes.enumerated() {
      let chartElementView = createChartElementView(color: UIColor(hexString:  yAxis.colorHex), name: yAxis.name, selected: true)
      stackView.addArrangedSubview(chartElementView)
      chartElementView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      chartElementView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      
      chartElementView.onTap = { [weak self, yAxis, unowned chartElementView] in
        guard let self = self else { return }
        if yAxis.isEnabled && self.yAxes.filter({ $0.isEnabled }).count == 1 {
          return
        }
        yAxis.isEnabled.toggle()
        chartElementView.isSelected = yAxis.isEnabled
        self.onToggledYAxis?(yAxis)
      }
      
      if index + 1 != yAxes.count {
        let separator = createSeparator()
        stackView.addArrangedSubview(separator)
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      }
    }
  }
  
  private func setup() {
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
  }
  
  private func createSeparator() -> UIView {
    let separatorContainer = UIView()
    separatorContainer.translatesAutoresizingMaskIntoConstraints = false
    
    let separator = UIView()
    separatorContainer.addSubview(separator)
    separator.translatesAutoresizingMaskIntoConstraints = false
    separator.topAnchor.constraint(equalTo: separatorContainer.topAnchor).isActive = true
    separator.bottomAnchor.constraint(equalTo: separatorContainer.bottomAnchor).isActive = true
    separator.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor, constant: 46).isActive = true
    separator.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor).isActive = true
    separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    return separatorContainer
  }
  
  private func createChartElementView(color: UIColor, name: String, selected: Bool) ->  ChartElementView {
    let chartElementView = ChartElementView()
    chartElementView.translatesAutoresizingMaskIntoConstraints = false
    chartElementView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    chartElementView.configure(color: color, name: name, selected: true)
    return chartElementView
  }
}

private class ChartElementView: UIView {
  private let checkMarkIconImageView = UIImageView(image: #imageLiteral(resourceName: "checkmark"))
  private let colorView = UIView()
  private let titleLabel = UILabel()
  
  var isSelected: Bool = true {
    didSet {
      checkMarkIconImageView.isHidden = !isSelected
    }
  }
  
  var onTap: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(color: UIColor, name: String, selected: Bool) {
    colorView.backgroundColor = color
    titleLabel.text = name
    isSelected = selected
  }
  
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
  
  @objc private func handleTap() {
    onTap?()
  }
}
