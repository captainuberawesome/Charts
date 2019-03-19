//
//  CircleView.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class CircleView: UIView, DayNightViewConfigurable {
  
  // MARK: - Properties
  
  private let dayNightModeToggler: DayNightModeToggler
  private let innerCircleView = UIView()
  
  // MARK: - init
  
  init(frame: CGRect, color: UIColor, dayNightModeToggler: DayNightModeToggler) {
    self.dayNightModeToggler = dayNightModeToggler
    super.init(frame: frame)
    backgroundColor = color
    layer.cornerRadius = bounds.width * 0.5
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    innerCircleView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
  }
  
  // MARK: - Public functions
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    innerCircleView.backgroundColor = dayNightModeToggler.lightBackgroundColor
  }

  // MARK: - Setup
  
  private func setup() {
    addSubview(innerCircleView)
    innerCircleView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    innerCircleView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    innerCircleView.layer.cornerRadius = innerCircleView.bounds.width * 0.5
  }
}
