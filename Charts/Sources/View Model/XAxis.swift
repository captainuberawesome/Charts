//
//  XAxis.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

struct XValue {
  var percentageValue: Double
  var actualValue: TimeInterval
}

class XAxis {
  // MARK: - Properties
  
  private let rawValues: [TimeInterval]
  private (set) var allValues: [XValue]
  private var ignoreSegmentationChange = false
  var leftSegmentationIndex: Int = 0
  var rightSegmentationIndex: Int
  
  var windowSize: Double {
    return rightSegmentationLimit - leftSegmentationLimit
  }
  
  var leftSegmentationLimit: Double = 0 {
    didSet {
      guard allValues.count > 1 else { return }
      if let leftIndex = allValues.enumerated().first(where: {
        return $0.element.percentageValue >= leftSegmentationLimit
      })?.offset {
        leftSegmentationIndex = leftIndex
        guard !ignoreSegmentationChange else { return }
        onSegmentationChanged?()
      }
    }
  }
  
  var rightSegmentationLimit: Double = 1 {
    didSet {
      guard allValues.count > 1 else { return }
      
      if let rightIndex = allValues.reversed().enumerated().first(where: {
        return $0.element.percentageValue <= rightSegmentationLimit
      })?.offset {
        rightSegmentationIndex = (allValues.count - 1) - rightIndex
        if rightSegmentationIndex <= leftSegmentationIndex {
          rightSegmentationIndex = leftSegmentationIndex + 1
        }
        guard !ignoreSegmentationChange else { return }
        onSegmentationChanged?()
      }
    }
  }
  
  var onSegmentationChanged: (() -> Void)?
  
  // MARK: - Initializer
  
  init(values: [TimeInterval]) {
    self.rawValues = values
    allValues = Array(0..<values.count).map {
      XValue(percentageValue: Double($0) / Double(values.count - 1), actualValue: values[$0] )
    }
    rightSegmentationIndex = allValues.count
  }
  
  convenience init(xAxis: XAxis) {
    let values = xAxis.allValues.map { $0.actualValue }
    self.init(values: values)
  }
  
  // MARK: - Public methods
  
  func updateBothSegmentationLimits(leftLimit: Double, rightLimit: Double) {
    ignoreSegmentationChange = true
    leftSegmentationLimit = leftLimit
    rightSegmentationLimit = rightLimit
    ignoreSegmentationChange = false
    onSegmentationChanged?()
  }
  
  func nextValueAndIndex(for percentageValue: Double) -> (value: XValue, index: Int)? {
    if let value = allValues.enumerated().first(where: {
      return $0.element.percentageValue >= percentageValue
    }) {
      return (value: value.element, index: value.offset)
    }
    return nil
  }
  
  func interpolatedValue(for percentageValue: Double) -> TimeInterval? {
    guard let firstValue = allValues.first?.actualValue,
      let lastValue = allValues.last?.actualValue else { return nil }
    return firstValue + (lastValue - firstValue) * percentageValue
  }
}
