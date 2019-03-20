//
//  Throttler.swift
//  Charts
//
//  Created by iOS Developer on 20/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

class Throttler {
  private var workItem: DispatchWorkItem?
  private var lastRunDate: Date?
  private let mustRunOnceInInterval: TimeInterval
  private let additionalDelay: TimeInterval
  
  init(mustRunOnceInInterval: TimeInterval, additionalDelay: TimeInterval = 0) {
    self.mustRunOnceInInterval = mustRunOnceInInterval
    self.additionalDelay = additionalDelay
  }
  
  func addWork( _ work: @escaping (() -> Void)) {
    workItem?.cancel()
    let newWorkItem = DispatchWorkItem { [weak self] in
      work()
      self?.lastRunDate = Date()
    }
    var after: TimeInterval = 0
    if let date = lastRunDate {
      after = Date().timeIntervalSince(date) > mustRunOnceInInterval ? additionalDelay : mustRunOnceInInterval
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: newWorkItem)
    workItem = newWorkItem
  }
  
  func cancel() {
    workItem?.cancel()
  }
}
