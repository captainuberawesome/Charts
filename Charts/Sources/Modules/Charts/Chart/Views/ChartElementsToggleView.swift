//
//  ChartElementsToggleView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartElementsToggleView: UIView, DayNightViewConfigurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private var chartElementViews: [ChartElementView] = []
  private var separators: [UIView] = []
  
  // MARK: - Callbacks
  
  var onToggledYAxis: ((YAxis) -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func configure(yAxes: [YAxis]) {
    for subview in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(subview)
      subview.removeFromSuperview()
    }
    
    chartElementViews = []
    separators = []
    
    for (index, yAxis) in yAxes.enumerated() {
      let chartElementView = createChartElementView(color: UIColor(hexString: yAxis.colorHex), name: yAxis.name, selected: true)
      stackView.addArrangedSubview(chartElementView)
      chartElementView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      chartElementView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      chartElementViews.append(chartElementView)
      chartElementView.onTap = { [weak self, yAxis, unowned chartElementView] in
        guard let self = self else { return }
        if yAxis.isEnabled && self.chartElementViews.filter({ $0.isSelected }).count == 1 {
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
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    for chartElementView in chartElementViews {
      chartElementView.configure(dayNightModeToggler: dayNightModeToggler)
    }
    for separator in separators {
      separator.backgroundColor = dayNightModeToggler.separatorColor
    }
  }
  
  // MARK: - Setup
  
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
  
  // MARK: - Private methods
  
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
    separators.append(separator)
    return separatorContainer
  }
  
  private func createChartElementView(color: UIColor, name: String, selected: Bool) -> ChartElementView {
    let chartElementView = ChartElementView()
    chartElementView.translatesAutoresizingMaskIntoConstraints = false
    chartElementView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    chartElementView.configure(color: color, name: name, selected: true)
    return chartElementView
  }
}
