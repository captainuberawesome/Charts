//
//  Chart.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

private struct Constants {
  static let normalizationDelay: TimeInterval = 0.033
}

class Chart {
  // MARK: - Properties
  let name: String
  var yAxes: [YAxis]
  var toggledYAxes: [YAxis] {
    return yAxes.filter { $0.isEnabled }
  }
  var xAxis: XAxis
  var delayNormalization = true
  private var normalizationWorkItem: DispatchWorkItem?
  
  var onSegmentationUpdated: (() -> Void)?
  var onNeedsXAxisUpdate: (() -> Void)?
  var onSegmentationNormalizedUpdated: (() -> Void)?
  
  // MARK: - Initializer
  
  init(name: String, xAxis: XAxis, yAxes: [YAxis]) {
    self.xAxis = xAxis
    self.yAxes = yAxes
    self.name = name
    
    xAxis.onSegmentationChanged = { [unowned self] in
      self.updateSegmentation()
    }
  }
  
  convenience init(chart: Chart) {
    let xAxis = XAxis(xAxis: chart.xAxis)
    let yAxes = chart.yAxes.map { YAxis(yAxis: $0) }
    self.init(name: chart.name, xAxis: xAxis, yAxes: yAxes)
  }
  
  // MARK: - Public method
  
  func updateSegmentation(shouldWait: Bool = true) {
    if !shouldWait || !delayNormalization {
       self.normalizationWorkItem?.cancel()
    }
    
    var maxValue: Int = 0
    var minValue: Int = Int.max
    var valuesArray: [[Int]] = []
    let leftIndex = xAxis.leftSegmentationIndex
    let rightIndex = xAxis.rightSegmentationIndex
    for yAxis in yAxes {
      let segmentedUnnormalizedValues = yAxis.segmentedUnnormalizedValues(leftSegmentationIndex: leftIndex,
                                                                          rightSegmentationIndex: rightIndex)
      
      if yAxis.isEnabled {
        let newMax = segmentedUnnormalizedValues.max() ?? 0
        if newMax > maxValue {
          maxValue = newMax
        }
        let newMin = segmentedUnnormalizedValues.min() ?? 0
        if newMin < minValue {
          minValue = newMin
        }
      }
      
      valuesArray.append(segmentedUnnormalizedValues)
    }
    
    if shouldWait && delayNormalization {
      onSegmentationUpdated?()
    }
    
    onNeedsXAxisUpdate?()
    
    if shouldWait && delayNormalization {
      self.normalizationWorkItem?.cancel()
      let work = DispatchWorkItem { [weak self, minValue, maxValue, valuesArray] in
        guard let self = self else { return }
        for (index, yAxis) in self.yAxes.enumerated() {
          yAxis.updateSegmentation(unnormalizedValues: valuesArray[index], minValue: minValue, maxValue: maxValue)
        }
        self.onSegmentationNormalizedUpdated?()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + Constants.normalizationDelay, execute: work)
      normalizationWorkItem = work
    } else {
      let yValuesRaw = toggledYAxes.flatMap { $0.allValues }
      let yValues = yValuesRaw.compactMap { $0.actualValue }
      let yAxisSpan = YAxis.calculateSpan(yMin: yValues.min() ?? 0, yMax: yValues.max() ?? 0)
      
      for (index, yAxis) in yAxes.enumerated() {
        yAxis.updateSegmentation(unnormalizedValues: valuesArray[index], minValue: minValue, maxValue: maxValue)
        yAxis.updateNormalizedValues(minValue: yAxisSpan.minY, maxValue: yAxisSpan.maxY)
      }

      onSegmentationNormalizedUpdated?()
    }
  }
}
