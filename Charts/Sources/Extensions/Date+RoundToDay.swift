//
//  Date+RoundToDay.swift
//  Charts
//
//  Created by iOS Developer on 20/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

extension Date {
  func nearestDay() -> Date {
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
    var components = calendar.dateComponents([.hour], from: self)
    let hour = components.hour ?? 0
    if hour >= 12 {
      let newComponents = DateComponents(calendar: calendar, timeZone: TimeZone(secondsFromGMT: 0), day: 1)
      return Calendar.current.date(byAdding: newComponents, to: self) ?? self
    }
    return self
  }
}
