//
//  LineAnimating.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let animationDuration: TimeInterval = 0.2
}

protocol LineAnimating: class {
  var isAnimating: Bool { get set }
  var shapeLayer: CAShapeLayer { get }
  var displayLink: CADisplayLink? { get set }
  var startTime: CFAbsoluteTime? { get set }
  var intermediatePoints: [CGPoint] { get set }
  var points: [CGPoint] { get }
  var oldPoints: [CGPoint] { get set }
  
  func path(points: [CGPoint]) -> UIBezierPath
  func animate(with displayLink: CADisplayLink)
  func stopAnimation()
}

extension LineAnimating where Self: UIView {
  func stopAnimation() {
    displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
    isAnimating = false
  }
  
  func path(points: [CGPoint]) -> UIBezierPath {
    let path = UIBezierPath()
    path.lineJoinStyle = .round
    path.lineCapStyle = .butt
    for (index, point) in points.enumerated() {
      if index == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
      }
    }
    return path
  }
  
  private func path(between first: [CGPoint], second: [CGPoint], percentage: Double) -> UIBezierPath {
    var points: [CGPoint] = []
    for index in 0..<min(first.count, second.count) {
      let firstPoint = first[index]
      let secondPoint = second[index]
      let xCoordinate = firstPoint.x + CGFloat(percentage) * (secondPoint.x - firstPoint.x)
      let yCoordinate = firstPoint.y + CGFloat(percentage) * (secondPoint.y - firstPoint.y)
      points.append(CGPoint(x: xCoordinate, y: yCoordinate))
    }
    intermediatePoints = points
    return path(points: points)
  }
  
  func animate(with displayLink: CADisplayLink) {
    guard let startTime = startTime else { return }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    let percent = elapsed / Constants.animationDuration
    
    guard percent < 1 else {
      shapeLayer.path = path(points: points).cgPath
      displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      self.displayLink = nil
      isAnimating = false
      self.startTime = nil
      return
    }
    
    let newPath = path(between: oldPoints, second: points, percentage: percent)
    shapeLayer.path = newPath.cgPath
  }
}
