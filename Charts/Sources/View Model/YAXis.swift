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

// MARK: - YValue

struct YValue {
  var percentageValue: Double
  var actualValue: Int
  var colorHex: String
}

// MARK: - YAxisSpan

struct YAxisSpan {
  let minY: Int
  let maxY: Int
  let step: Int
}

// MARK: - YAxis

class YAxis {
  // MARK: - Properties
  private let rawValues: [Int]
  private (set) var allValues: [YValue]
  private (set) var allValuesNormalized: [YValue]
  private (set) var allValuesNormalizedToSegment: [YValue]
  private (set) var minValueAcrossYSegmented: Int
  private (set) var maxValueAcrossYSegmented: Int
  private (set) var step: YValue
  
  let maxValueAcrossY: Int
  let minValueAcrossY: Int
  let initialStep: Int
  let colorHex: String
  let name: String
  
  var isEnabled = true
  
  // MARK: - Initializer

  init(values: [Int], colorHex: String, name: String, minValueAcrossY: Int, maxValueAcrossY: Int, step: Int) {
    self.colorHex = colorHex
    self.name = name
    self.maxValueAcrossY = maxValueAcrossY
    self.minValueAcrossY = minValueAcrossY
    self.step = YValue(percentageValue: Double(step) / Double(maxValueAcrossY - minValueAcrossY),
                       actualValue: step,
                       colorHex: colorHex)
    self.rawValues = values
    allValues = values.map {
      YValue(percentageValue: Double($0 - minValueAcrossY) / Double(maxValueAcrossY - minValueAcrossY),
             actualValue: $0, colorHex: colorHex)
    }
    allValuesNormalizedToSegment = allValues
    allValuesNormalized = allValues
    maxValueAcrossYSegmented = maxValueAcrossY
    minValueAcrossYSegmented = minValueAcrossY
    initialStep = step
  }
  
  convenience init(yAxis: YAxis) {
    let values = yAxis.allValues.map { $0.actualValue }
    let colorHex = yAxis.colorHex
    let name = yAxis.name
    let minValueAcrossY = yAxis.minValueAcrossY
    let maxValueAcrossY = yAxis.maxValueAcrossY
    let step = yAxis.initialStep
    self.init(values: values, colorHex: colorHex, name: name, minValueAcrossY: minValueAcrossY,
              maxValueAcrossY: maxValueAcrossY, step: step)
  }
  
  // MARK: - Public methods
  
  func segmentedUnnormalizedValues(leftSegmentationIndex: Int, rightSegmentationIndex: Int) -> [Int] {
    let unnormalizedValues = rawValues.enumerated().filter {
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }.compactMap { $0.element } 
    return unnormalizedValues
  }
  
  func updateSegmentation(unnormalizedValues: [Int], minValue: Int, maxValue: Int) {
    let yAxisSpan = YAxis.calculateSpan(yMin: minValue, yMax: maxValue)
    maxValueAcrossYSegmented = yAxisSpan.maxY
    minValueAcrossYSegmented = yAxisSpan.minY
    self.step = YValue(percentageValue: Double(yAxisSpan.step) / Double(yAxisSpan.maxY - yAxisSpan.minY),
                       actualValue: yAxisSpan.step, colorHex: colorHex)
    allValuesNormalizedToSegment = rawValues.map {
      YValue(percentageValue: Double($0 - yAxisSpan.minY) / Double(yAxisSpan.maxY - yAxisSpan.minY), actualValue: $0,
             colorHex: colorHex)
    }
  }
  
  func updateNormalizedValues(minValue: Int, maxValue: Int) {
    allValuesNormalized = rawValues.map {
      YValue(percentageValue: Double($0 - minValue) / Double(maxValue - minValue), actualValue: $0, colorHex: colorHex)
    }
  }
  
  // MARK: - Public static methods
  
  static func calculateSpan(yMin: Int, yMax: Int) -> YAxisSpan {
    let increasedYMax = yMin + Int(round(Double(yMax - yMin) * 1.05))
    var maxValueAcrossY = increasedYMax
    
    var step = calculateStep(yMin: yMin, yMax: maxValueAcrossY)
    
    let minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    maxValueAcrossY = Int(ceil(Double(maxValueAcrossY) / Double(step))) * step
    
    if maxValueAcrossY - (minValueAcrossY + step * (Constants.numberOfSteps - 1)) <= Int(ceil(0.2 * Double(step)))
      || yMax == maxValueAcrossY {
      maxValueAcrossY += Int(ceil(0.2 * Double(step)))
    }
    
    step = calculateStep(yMin: minValueAcrossY, yMax: maxValueAcrossY)
    
    maxValueAcrossY = minValueAcrossY + step * (Constants.numberOfSteps - 1) + Int(ceil(0.75 * Double(step)))
    
    if maxValueAcrossY - yMax < Int(ceil(0.25 * Double(step))) {
      maxValueAcrossY += Int(ceil(0.25 * Double(step)))
    }

    return YAxisSpan(minY: minValueAcrossY, maxY: maxValueAcrossY, step: step)
  }
  
  static private func calculateStep(yMin: Int, yMax: Int) -> Int {
    let span = yMax - yMin
    var step = Int(ceil(Double(span) / Double(Constants.numberOfSteps)))
    
    if step == 0 {
      step = 1
    } else if step < 25 {
      step = Int(ceil(Double(step) / 5) * 5)
    } else if step < 100 {
      step = Int(ceil(Double(step) / 10) * 10)
    } else if step < 1000 {
      step = Int(ceil(Double(step) / 100) * 100)
    } else if step < 100000 {
      step = Int(ceil(Double(step) / 1000) * 1000)
    } else {
      step = Int(ceil(Double(step) / 100000) * 100000)
    }
    
    return step
  }
}
