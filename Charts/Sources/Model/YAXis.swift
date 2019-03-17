//
//  YAXis.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

private struct Constants {
  static let numberOfSteps = 6
}

struct YValue {
  var percentageValue: Double
  var actualValue: Int
}

class YAxis {
  private let rawValues: [Int]
  private var maxValueAcrossY: Int
  private var minValueAcrossY: Int
  
  private (set) var allValues: [YValue]
  private (set) var allValuesNormalized: [YValue]
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
    allValuesNormalized = allValues
    maxValueAcrossYSegmented = maxValueAcrossY
    minValueAcrossYSegmented = minValueAcrossY
  }
  
  func segmentedUnnormalizedValues(leftSegmentationIndex: Int, rightSegmentationIndex: Int) -> [Int] {
    let unnormalizedValues = rawValues.enumerated().filter({
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }).compactMap({ $0.element })
    return unnormalizedValues
  }
  
  func updateSegmentation(unnormalizedValues: [Int], minValue: Int, maxValue: Int) {
    let (minValueAcrossY, maxValueAcrossY, step) = YAxis.calculateSpan(yMin: minValue, yMax: maxValue)
    maxValueAcrossYSegmented = maxValueAcrossY
    minValueAcrossYSegmented = minValueAcrossY
    self.step = YValue(percentageValue: Double(step) / Double(maxValueAcrossY - minValueAcrossY),
                       actualValue: step)
    allValuesNormalized = rawValues.map {
      YValue(percentageValue: Double($0 - minValueAcrossY) / Double(maxValueAcrossY - minValueAcrossY), actualValue: $0)
    }
  }
  
  static func calculateSpan(yMin: Int, yMax: Int) -> (minY: Int, maxY: Int, step: Int) {
    var step = calculateStep(yMin: yMin, yMax: yMax)
    
    var minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    var maxValueAcrossY = Int(ceil(ceil(Double(yMax)) / Double(step))) * step
    
    if yMax == maxValueAcrossY {
      maxValueAcrossY += Int(ceil(0.75 * Double(step)))
    }
    
    step = calculateStep(yMin: minValueAcrossY, yMax: maxValueAcrossY)
    
    minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    maxValueAcrossY = Int(ceil(ceil(Double(yMax)) / Double(step))) * step
    
    if maxValueAcrossY == minValueAcrossY + step * (Constants.numberOfSteps - 1) || yMax == maxValueAcrossY {
      maxValueAcrossY += Int(ceil(0.75 * Double(step)))
    }

    return (minValueAcrossY, maxValueAcrossY, step)
  }
  
  static private func calculateStep(yMin: Int, yMax: Int) -> Int {
    let span = yMax - yMin
    var step = span / Constants.numberOfSteps
    
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
    } else if step < 5000 {
      step = Int(ceil(Double(step) / 500) * 500)
    } else {
      step = Int(ceil(Double(step) / 1000) * 1000)
    }
    
    return step
  }
}
