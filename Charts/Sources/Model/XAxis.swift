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
  
  var onSegmentationChanged: (() -> Void)?
  
  init(values: [TimeInterval]) {
    self.rawValues = values
    allValues = Array(0..<values.count).map {
      XValue(percentageValue: Double($0) / Double(values.count - 1), actualValue: values[$0] )
    }
    segmentedValues = allValues
    rightSegmentationIndex = allValues.count
  }
  
  func updateSegmentation(leftSegmentationIndex: Int, rightSegmentationIndex: Int) {
    let filteredValues = rawValues.enumerated().filter({
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }).compactMap({ $0.element })
    segmentedValues = Array(0..<filteredValues.count).map {
      XValue(percentageValue: Double($0) / Double(filteredValues.count - 1), actualValue: filteredValues[$0])
    }
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
        updateSegmentation(leftSegmentationIndex: leftSegmentationIndex, rightSegmentationIndex: rightSegmentationIndex)
        onSegmentationChanged?()
      }
    }
  }
  
  var leftSegmentationIndex: Int = 0
  var rightSegmentationIndex: Int
}
