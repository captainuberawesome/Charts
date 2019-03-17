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
  private let rawValues: [TimeInterval]
  private (set) var allValues: [XValue]
  private (set) var segmentedValues: [XValue]
  private var ignoreSegmentationChange = false
  var leftSegmentationIndex: Int = 0
  var rightSegmentationIndex: Int
  
  var windowSize: Double {
    return rightSegmentationLimit - leftSegmentationLimit
  }
  
  var leftSegmentationLimit: Double = 0 {
    didSet {
      guard allValues.count > 1 else { return }
      let diff = allValues[1].percentageValue - allValues[0].percentageValue
      if let leftIndex = allValues.index(where: {
        let upperDiff = $0.percentageValue - leftSegmentationLimit
        return upperDiff > 0 && upperDiff < diff
      }) {
        leftSegmentationIndex = leftIndex
        guard !ignoreSegmentationChange else { return }
        updateSegmentation(leftSegmentationIndex: leftSegmentationIndex, rightSegmentationIndex: rightSegmentationIndex)
        onSegmentationChanged?()
      }
    }
  }
  
  var rightSegmentationLimit: Double = 1 {
    didSet {
      guard allValues.count > 1 else { return }
      let diff = allValues[1].percentageValue - allValues[0].percentageValue
      if let rightIndex = allValues.index(where: {
        let upperDiff = $0.percentageValue - rightSegmentationLimit
        return upperDiff > 0 && upperDiff < diff
      }) {
        rightSegmentationIndex = rightIndex
        guard !ignoreSegmentationChange else { return }
        updateSegmentation(leftSegmentationIndex: leftSegmentationIndex, rightSegmentationIndex: rightSegmentationIndex)
        onSegmentationChanged?()
      }
    }
  }
  
  var onSegmentationChanged: (() -> Void)?
  
  init(values: [TimeInterval]) {
    self.rawValues = values
    allValues = Array(0..<values.count).map {
      XValue(percentageValue: Double($0) / Double(values.count - 1), actualValue: values[$0] )
    }
    segmentedValues = allValues
    rightSegmentationIndex = allValues.count
  }
  
  func updateBothSegmentationLimits(leftLimit: Double, rightLimit: Double) {
    ignoreSegmentationChange = true
    leftSegmentationLimit = leftLimit
    rightSegmentationLimit = rightLimit
    ignoreSegmentationChange = false
    updateSegmentation(leftSegmentationIndex: leftSegmentationIndex,
                       rightSegmentationIndex: rightSegmentationIndex)
    onSegmentationChanged?()
  }
  
  func updateSegmentation(leftSegmentationIndex: Int, rightSegmentationIndex: Int) {
    let filteredValues = rawValues.enumerated().filter({
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }).compactMap({ $0.element })
    segmentedValues = Array(0..<filteredValues.count).map {
      XValue(percentageValue: Double($0) / Double(filteredValues.count - 1), actualValue: filteredValues[$0])
    }
  }
  
  func interpolatedValue(for percentageValue: Double) -> TimeInterval? {
    guard let firstValue = allValues.first?.actualValue,
      let lastValue = allValues.last?.actualValue else { return nil }
    return firstValue + (lastValue - firstValue) * percentageValue
  }
}
