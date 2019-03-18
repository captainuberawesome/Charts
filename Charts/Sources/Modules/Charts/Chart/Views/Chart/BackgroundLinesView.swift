//
//  BackgroundLinesView.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let lineCount = 6
  static let animationDuration: TimeInterval = 0.2
}

class BackgroundLinesView: UIView {
  private var shapeLayers: [CAShapeLayer] = []
  private let verticalLineView = UIView()
  private var displayLink: CADisplayLink?
  private var startTime: CFAbsoluteTime?
  private var stepPercentage: Double = 0
  private var lineStartingPoints: [CGPoint] = []
  private var isAnimating = false
  private var animationCompletionClosure: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(yAxis: YAxis) {
    stepPercentage = yAxis.step.percentageValue
    lineStartingPoints = []
    for index in 0..<Constants.lineCount {
      let shapeLayer = shapeLayers[index]
      shapeLayer.path = path(index: index, stepPercentage: stepPercentage).cgPath
    }
  }
  
  func addVerticalLine(atXCoordinate xCoordinate: CGFloat) {
    verticalLineView.removeFromSuperview()
    addSubview(verticalLineView)
    verticalLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    verticalLineView.frame = CGRect(x: xCoordinate - 0.5, y: 5, width: 1,
                                    height: bounds.height - 5)
  }
  
  func removeVerticalLine() {
    verticalLineView.removeFromSuperview()
  }
  
  func animate(yAxis: YAxis) {
    guard !isAnimating else {
      animationCompletionClosure = { [weak self, yAxis] in
        self?.animate(yAxis: yAxis)
      }
      return
    }
    guard fabs(stepPercentage - yAxis.step.percentageValue) > 1e-4 else {
      return
    }
    isAnimating = true
    stepPercentage = yAxis.step.percentageValue
    startTime = CFAbsoluteTimeGetCurrent()
    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
    displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
  }
  
  private func setup() {
    for index in 0..<Constants.lineCount {
      let shapeLayer = CAShapeLayer()
      shapeLayer.fillColor = UIColor.clear.cgColor
      shapeLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
      shapeLayer.lineWidth = index == 0 ? 1 : 0.2
      shapeLayer.frame = bounds
      shapeLayers.append(shapeLayer)
      layer.addSublayer(shapeLayer)
    }
  }
  
  private func path(index: Int, stepPercentage: Double) -> UIBezierPath {
    let path = UIBezierPath()
    let start = CGPoint(x: 0, y: bounds.height - CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    lineStartingPoints.append(start)
    path.move(to: start)
    let end = CGPoint(x: bounds.width, y: bounds.height - CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    path.addLine(to: end)
    return path
  }
  
  private func path(index: Int, stepPercentage: Double, oldStartingPoint: CGPoint, percentage: Double) -> UIBezierPath {
    let newStartingPoint = CGPoint(x: 0, y: bounds.height - CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    let newEndingPoint = CGPoint(x: bounds.width, y: bounds.height - CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    let oldEndingPoint = CGPoint(x: bounds.width, y: oldStartingPoint.y)
    
    let x1 = oldStartingPoint.x + CGFloat(percentage) * (newStartingPoint.x - oldStartingPoint.x)
    let y1 = oldStartingPoint.y + CGFloat(percentage) * (newStartingPoint.y - oldStartingPoint.y)
    
    let x2 = oldEndingPoint.x + CGFloat(percentage) * (newEndingPoint.x - oldEndingPoint.x)
    let y2 = oldEndingPoint.y + CGFloat(percentage) * (newEndingPoint.y - oldEndingPoint.y)
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: x1, y: y1))
    path.addLine(to: CGPoint(x: x2, y: y2))
    return path
  }
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    guard let startTime = startTime else { return }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    let percent = elapsed / Constants.animationDuration
    
    guard percent < 1 else {
      displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      isAnimating = false
      self.startTime = nil
      return
    }
    
    for index in 0..<Constants.lineCount {
      let shapeLayer = shapeLayers[index]
      shapeLayer.path = path(index: index, stepPercentage: stepPercentage,
                             oldStartingPoint: lineStartingPoints[index], percentage: percent).cgPath
    }
  }
}
