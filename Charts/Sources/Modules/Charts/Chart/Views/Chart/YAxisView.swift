//
//  YAxisView.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let labelCount = 6
}

private enum AnimationDirection {
  case up, down
}

class YAxisView: UIView {
  // MARK: - Properties
  
  private var labels: [UILabel] = []
  private var currentMinValue: Int = 0
  private var currentStepValue: Int = 0
  private var currentStepPercentage: Double = 0
  private var isAnimating = false
  private var configuredForBounds: CGRect = .zero
  private var animationCompletionClosure: (() -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    clipsToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if bounds != configuredForBounds {
      for (index, label) in labels.enumerated() {
        let origin = CGPoint(x: 0, y: bounds.height - CGFloat(index) * CGFloat(currentStepPercentage) * bounds.height)
        label.frame.origin = CGPoint(x: origin.x, y: origin.y - label.frame.size.height - 3)
        configuredForBounds = bounds
      }
    }
  }
  
  // MARK: - Public methods
  
  func configure(yAxis: YAxis, animateIfNeeded: Bool = false) {
    guard !isAnimating else {
      animationCompletionClosure = { [weak self] in
        self?.configure(yAxis: yAxis, animateIfNeeded: animateIfNeeded)
      }
      return
    }
    
    if animateIfNeeded, currentMinValue != yAxis.minValueAcrossYSegmented
      || currentStepValue != yAxis.step.actualValue || currentStepPercentage != yAxis.step.percentageValue {
      let oldMaxValue = Double(currentMinValue) + Double(Constants.labelCount - 1) * Double(currentStepValue)
      currentMinValue = yAxis.minValueAcrossYSegmented
      currentStepValue = yAxis.step.actualValue
      currentStepPercentage = yAxis.step.percentageValue
      let newMaxValue = Double(currentMinValue) + Double(Constants.labelCount - 1) * Double(currentStepValue)
      var animationDirection = AnimationDirection.up
      if newMaxValue < oldMaxValue {
        animationDirection = .down
      }
      animateLabelChange(animationDirection: animationDirection)
      return
    }
    
    currentMinValue = yAxis.minValueAcrossYSegmented
    currentStepValue = yAxis.step.actualValue
    currentStepPercentage = yAxis.step.percentageValue
    
    for index in 0..<Constants.labelCount {
      let label = labels[index]
      
      label.text = "\(currentMinValue + currentStepValue * index)"
      label.sizeToFit()
      let origin = CGPoint(x: 0, y: bounds.height - CGFloat(index) * CGFloat(currentStepPercentage) * bounds.height)
      let newLabelOrigin = CGPoint(x: origin.x, y: origin.y - label.frame.size.height - 3)
      
      if animateIfNeeded, label.frame.origin.y != newLabelOrigin.y {
        animateLabelPositionChange()
        break
      }
      label.frame.origin = newLabelOrigin
    }
    
    configuredForBounds = bounds
  }
  
  func location(forValue yValue: YValue, xCoordinate: CGFloat) -> CGPoint {
    let yCoordinate = bounds.height - bounds.height * CGFloat(yValue.percentageValue)
    return CGPoint(x: xCoordinate, y: yCoordinate)
  }
  
  // MARK: - Private methods
  
  private func animateLabelPositionChange() {
    guard !isAnimating else {
      animationCompletionClosure = { [weak self] in
        self?.animateLabelPositionChange()
      }
      return
    }
    isAnimating = true

    UIView.animate(withDuration: 0.2, animations: {
      for index in 0..<Constants.labelCount {
        let label = self.labels[index]
        let origin = CGPoint(x: 0,
                             y: self.bounds.height - CGFloat(index) * CGFloat(self.currentStepPercentage) * self.bounds.height)
        let newLabelOrigin = CGPoint(x: origin.x, y: origin.y - label.frame.size.height - 3)
        let newLabelText = "\(self.currentMinValue + self.currentStepValue * index)"
        label.text = newLabelText
        label.sizeToFit()
        label.frame.origin = newLabelOrigin
      }
    }, completion: { _ in
      self.isAnimating = false
      self.animationCompletionClosure?()
    })
  }
  
  private func animateLabelChange(animationDirection: AnimationDirection) {
    guard !isAnimating else {
      animationCompletionClosure = { [weak self] in
        self?.animateLabelChange(animationDirection: animationDirection)
      }
      return
    }
    isAnimating = true
    
    let animatedOffset: CGFloat = animationDirection == .up ? 50 : -50
    
    var newLabels: [UILabel] = []
    for index in 0..<Constants.labelCount {
      let label = UILabel()
      addSubview(label)
      label.textColor = UIColor.gray
      label.font = UIFont.systemFont(ofSize: 11, weight: .light)
      label.alpha = 0
      let origin = CGPoint(x: 0, y: bounds.height - CGFloat(index) * CGFloat(currentStepPercentage) * bounds.height)
      label.text = "\(currentMinValue + currentStepValue * index)"
      label.sizeToFit()
      label.frame.origin = CGPoint(x: origin.x,
                                   y: origin.y - label.frame.size.height - 3 + animatedOffset)
      newLabels.append(label)
    }
    
    UIView.animate(withDuration: 0.2, animations: {
      for label in self.labels {
        label.alpha = 0
        label.frame.origin.y -= animatedOffset
      }
      
      for label in newLabels {
        label.alpha = 1
        label.frame.origin.y -= animatedOffset
      }
    }, completion: { _ in
      self.labels.forEach { $0.removeFromSuperview() }
      self.labels = newLabels
      self.isAnimating = false
      self.animationCompletionClosure?()
    })
  }
  
  // MARK: - Setup
  
  private func setup() {
    for _ in 0..<Constants.labelCount {
      let label = UILabel()
      addSubview(label)
      label.textColor = UIColor.gray
      label.font = UIFont.systemFont(ofSize: 11, weight: .light)
      labels.append(label)
    }
  }
}
