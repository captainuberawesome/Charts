//
//  YAXis.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

struct YValue {
  var percentageValue: Double
  var actualValue: Int
}

class YAxis {
  private let rawValues: [Int]
  private var maxValueAcrossY: Int
  private var minValueAcrossY: Int
  
  private (set) var allValues: [YValue]
  private (set) var segmentedValues: [YValue]
  private (set) var minValueAcrossYSegmented: Int
  private (set) var maxValueAcrossYSegmented: Int
  private (set) var step: YValue
  
  let colorHex: String
  let name: String
  
  var isEnabled = true
  
  init(values: [Int], colorHex: String, name: String, minValueAcrossY: Int, maxValueAcrossY: Int, step: Int) {
    self.colorHex = colorHex
    self.name = name
    self.maxValueAcrossY = maxValueAcrossY
    self.minValueAcrossY = minValueAcrossY
    self.step = YValue(percentageValue: Double(step) / Double(maxValueAcrossY - minValueAcrossY),
                       actualValue: step)
    self.rawValues = values
    allValues = values.map {
      YValue(percentageValue: Double($0 - minValueAcrossY) / Double(maxValueAcrossY - minValueAcrossY),
             actualValue: $0)
    }
    segmentedValues = allValues
    maxValueAcrossYSegmented = maxValueAcrossY
    minValueAcrossYSegmented = minValueAcrossY
  }
  
  func segmentedUnnormalizedValues(leftSegmentationIndex: Int, rightSegmentationIndex: Int) -> [Int] {
    let unnormalizedValues = rawValues.enumerated().filter({
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }).compactMap({ $0.element })
    segmentedValues = unnormalizedValues.map {
      YValue(percentageValue: Double($0 - minValueAcrossYSegmented) / Double(maxValueAcrossYSegmented - minValueAcrossYSegmented),
             actualValue: $0)
    }
    return unnormalizedValues
  }
  
  func updateSegmentation(unnormalizedValues: [Int], minValue: Int, maxValue: Int) {
    let (minValueAcrossY, maxValueAcrossY, step) = YAxis.calculateSpan(yMin: minValue, yMax: minValue)
    maxValueAcrossYSegmented = minValueAcrossY
    minValueAcrossYSegmented = maxValueAcrossY
    self.step = YValue(percentageValue: Double(step) / Double(maxValue - minValue),
                       actualValue: step)
    segmentedValues = unnormalizedValues.map {
      YValue(percentageValue: Double($0 - minValue) / Double(maxValue - minValue), actualValue: $0)
    }
  }
  
  static func calculateSpan(yMin: Int, yMax: Int) -> (minY: Int, maxY: Int, step: Int) {
    let span = yMax - yMin
    var step = span / 6
    
    if step == 0 {
      step = 5
    } else if step < 25 {
      step = Int(ceil(Double(step) / 5) * 5)
    } else if step < 100 {
      step = Int(ceil(Double(step) / 10) * 10)
    } else if step < 500 {
      step = Int(ceil(Double(step) / 50) * 50)
    } else if step < 1000 {
      step = Int(ceil(Double(step) / 100) * 100)
    } else {
      step = Int(ceil(Double(step) / 500) * 500)
    }
    let minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    let halfStep = Double(step) * 0.5
    let maxValueAcrossY = Int(ceil(ceil(Double(yMax)) / halfStep) * halfStep + halfStep)
    return (minValueAcrossY, maxValueAcrossY, step)
  }
}
