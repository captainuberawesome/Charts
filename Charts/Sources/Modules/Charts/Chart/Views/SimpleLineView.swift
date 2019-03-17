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

class SimpleLineView: UIView {
  private var points: [CGPoint]
  private let color: UIColor
  private let lineWidth: CGFloat
  private var shapeLayer = CAShapeLayer()
  private var displayLink: CADisplayLink?
  private var startTime: CFAbsoluteTime?
  private var oldPoints: [CGPoint]
  private var isAnimating = false
  private var animationCompletionClosure: (() -> Void)?
  
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.frame = bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func animate(to points: [CGPoint]) {
    guard !isAnimating else {
      animationCompletionClosure = { [weak self, points] in
        self?.animate(to: points)
      }
      return
    }
    isAnimating = true
    oldPoints = self.points
    self.points = points
    startTime = CFAbsoluteTimeGetCurrent()
    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
    displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
  }
  
  private func path(points: [CGPoint]) -> UIBezierPath {
    let path = UIBezierPath()
    for (index, point) in points.enumerated() {
      if index == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
        path.move(to: point)
      }
    }
    return path
  }
  
  private func path(between first: [CGPoint], second: [CGPoint], percentage: Double) -> UIBezierPath {
    var points: [CGPoint] = []
    for index in 0..<min(first.count, second.count) {
      let firstPoint = first[index]
      let secondPoint = second[index]
      let x = firstPoint.x + CGFloat(percentage) * (secondPoint.x - firstPoint.x)
      let y = firstPoint.y + CGFloat(percentage) * (secondPoint.y - firstPoint.y)
      points.append(CGPoint(x: x, y: y))
    }
    return path(points: points)
  }
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    guard let startTime = startTime else { return }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    let percent = elapsed / Constants.animationDuration
    
    guard percent < 1 else {
      oldPoints = points
      shapeLayer.path = path(points: points).cgPath
      displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      isAnimating = false
      self.startTime = nil
      return
    }
    
    let newPath = path(between: oldPoints, second: points, percentage: percent)
    shapeLayer.path = newPath.cgPath
  }
}
