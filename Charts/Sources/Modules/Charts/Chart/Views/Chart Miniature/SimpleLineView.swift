//
//  SimpleLineView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let animationDuration: TimeInterval = 0.2
}

class SimpleLineView: UIView, LineAnimating {
  // MARK: - Properties
  
  private let color: UIColor
  private let lineWidth: CGFloat
  private var isVisible = true
  
  var oldPoints: [CGPoint]
  var intermediatePoints: [CGPoint] = []
  var points: [CGPoint]
  var shapeLayer = CAShapeLayer()
  var displayLink: CADisplayLink?
  var startTime: CFAbsoluteTime?
  var isAnimating = false
  var animationCompletionClosure: (() -> Void)?
  
  // MARK: - Init
  
  init(frame: CGRect, points: [CGPoint], color: UIColor, lineWidth: CGFloat = 1.0) {
    self.points = points
    self.color = color
    self.lineWidth = lineWidth
    self.oldPoints = points
    super.init(frame: frame)
    isOpaque = false
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.frame = bounds
    layer.addSublayer(shapeLayer)
    shapeLayer.path = path(points: points).cgPath
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.frame = bounds
  }
  
  // MARK: - Public methods
  
  func animate(to points: [CGPoint], isEnabled: Bool) {
    if isAnimating {
      oldPoints = intermediatePoints
    } else {
      oldPoints = self.points
    }
    
    self.points = points
    startTime = CFAbsoluteTimeGetCurrent()
    
    if !isAnimating {
      displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
      displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    isAnimating = true
    
    let animationClosure: ((_ hide: Bool) -> Void) = { hide in
      UIView.animate(withDuration: 0.2) {
        self.alpha = hide ? 0.0 : 1.0
      }
    }
    if !isEnabled, isVisible {
      animationClosure(true)
    } else if isEnabled, !isVisible {
      animationClosure(false)
    }
    isVisible = isEnabled
  }
  
  // MARK: - Actions
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    animate(with: displayLink)
  }
}
