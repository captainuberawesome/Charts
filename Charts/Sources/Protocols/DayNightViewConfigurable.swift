//
//  DayNightViewConfigurable.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

protocol DayNightViewConfigurable: class {
  func configure(dayNightModeToggler: DayNightModeToggler)
}
