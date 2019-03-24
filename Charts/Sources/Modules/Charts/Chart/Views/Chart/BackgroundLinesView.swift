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

class BackgroundLinesView: UIView, DayNightViewConfigurable {
   // MARK: - Properties
  
  private var shapeLayers: [CAShapeLayer] = []
  private let verticalLineView = UIView()
  private var displayLink: CADisplayLink?
  private var startTime: CFAbsoluteTime?
  private var stepPercentage: Double = 0
  private var lineStartingPoints: [CGPoint] = []
  private var lineStartingPointsDuringAnimation: [CGPoint] = []
  private var isAnimating = false
  private let dayNightModeToggler: DayNightModeToggler
  
   // MARK: - Init
  
  init(dayNightModeToggler: DayNightModeToggler, frame: CGRect = .zero) {
    self.dayNightModeToggler = dayNightModeToggler
    super.init(frame: frame)
    setup()
    configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
   // MARK: - Public methods
  
  func configure(yAxis: YAxis) {
    stepPercentage = yAxis.step.percentageValue
    lineStartingPoints = []
    for index in 0..<Constants.lineCount {
      let shapeLayer = shapeLayers[index]
      shapeLayer.path = path(index: index, stepPercentage: stepPercentage).cgPath
    }
  }
  
  func addVerticalLine(atXCoordinate xCoordinate: CGFloat) {
    verticalLineView.backgroundColor = dayNightModeToggler.selectionBubbleVerticalLineColor
    
    if verticalLineView.isHidden {
      verticalLineView.isHidden = false
      verticalLineView.frame = CGRect(x: xCoordinate - 0.5, y: 5, width: 1,
                                      height: bounds.height - 5)
    } else {
      UIView.animate(withDuration: 0.2) {
        self.verticalLineView.frame = CGRect(x: xCoordinate - 0.5, y: 5, width: 1,
                                             height: self.bounds.height - 5)
      }
      verticalLineView.isHidden = false
    }
    
  }
  
  func removeVerticalLine() {
    verticalLineView.isHidden = true
  }
  
  func stopAnimation() {
    displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
  }
  
  func animate(yAxis: YAxis) {
    guard fabs(stepPercentage - yAxis.step.percentageValue) > 1e-4 else {
      return
    }
    stepPercentage = yAxis.step.percentageValue
    startTime = CFAbsoluteTimeGetCurrent()
    if isAnimating {
      lineStartingPoints = lineStartingPointsDuringAnimation
    } else {
      displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
      displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    isAnimating = true
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    for shapeLayer in shapeLayers {
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      shapeLayer.strokeColor = dayNightModeToggler.chartBackgroundLinesColor.cgColor
      CATransaction.commit()
    }
    verticalLineView.backgroundColor = dayNightModeToggler.separatorColor
  }
  
   // MARK: - Setup
  
  private func setup() {
    addSubview(verticalLineView)
    verticalLineView.isHidden = true
    for index in 0..<Constants.lineCount {
      let shapeLayer = CAShapeLayer()
      shapeLayer.fillColor = UIColor.clear.cgColor
      shapeLayer.strokeColor = dayNightModeToggler.chartBackgroundLinesColor.cgColor
      shapeLayer.lineWidth = index == 0 ? 1 : 0.5
      shapeLayer.frame = bounds
      shapeLayers.append(shapeLayer)
      layer.addSublayer(shapeLayer)
    }
  }
  
   // MARK: - Private methods
  
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
    
    let x1Coordinate = oldStartingPoint.x + CGFloat(percentage) * (newStartingPoint.x - oldStartingPoint.x)
    let y1Coordinate = oldStartingPoint.y + CGFloat(percentage) * (newStartingPoint.y - oldStartingPoint.y)
    
    let x2Coordinate = oldEndingPoint.x + CGFloat(percentage) * (newEndingPoint.x - oldEndingPoint.x)
    let y2Coordinate = oldEndingPoint.y + CGFloat(percentage) * (newEndingPoint.y - oldEndingPoint.y)
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: x1Coordinate, y: y1Coordinate))
    lineStartingPointsDuringAnimation.append(CGPoint(x: x1Coordinate, y: y1Coordinate))
    path.addLine(to: CGPoint(x: x2Coordinate, y: y2Coordinate))
    return path
  }
  
   // MARK: - Actions
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    guard let startTime = startTime else { return }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    let percent = elapsed / Constants.animationDuration
    
    guard percent < 1 else {
      displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      self.displayLink = nil
      isAnimating = false
      self.startTime = nil
      return
    }
    
    lineStartingPointsDuringAnimation = []
    for index in 0..<Constants.lineCount {
      let shapeLayer = shapeLayers[index]
      shapeLayer.path = path(index: index, stepPercentage: stepPercentage,
                             oldStartingPoint: lineStartingPoints[index], percentage: percent).cgPath
    }
  }
}
