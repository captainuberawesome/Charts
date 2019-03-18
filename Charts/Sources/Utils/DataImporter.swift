//
//  File.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

private enum ColumnCreationError: Error {
  case noType, noColor, noName, noValues
}

private enum ChartCreationError: Error {
  case noXColumn
}

private enum ColumnParsingError: Error {
  case noLabel
}

private enum Column {
  case line(colorHex: String, name: String, values: [Int]), x(values: [TimeInterval])
}

private struct XColumn {
  let values: [TimeInterval]
}

private struct YColumn {
  let colorHex: String
  let name: String
  let values: [Int]
}

private struct ChartColumns {
  let xColumn: XColumn
  let yColumns: [YColumn]
  
  fileprivate init(columns: [Column]) throws {
    var newYColumns: [YColumn] = []
    var newXColumn: XColumn?
    for column in columns {
      switch column {
      case .x(let values):
        newXColumn = XColumn(values: values)
      case .line(let colorHex, let name, let values):
        newYColumns.append(YColumn(colorHex: colorHex, name: name, values: values))
      }
    }
    if let newXColumn = newXColumn {
      xColumn = newXColumn
    } else {
      throw ChartCreationError.noXColumn
    }
    yColumns = newYColumns
  }
}

private struct ColumnData {
  let label: String
  let values: [Any]
  
  init(array: [Any]) throws {
    guard let labelValue = array.first as? String else {
      throw ColumnParsingError.noLabel
    }
    label = labelValue
    values = Array(array.dropFirst())
  }
}

private enum ChartParsingError: Error {
  case noTypes, noNames, noColors, noColumns
}

private struct ChartData {
  let columnDataArray: [ColumnData]
  let types: [String: String]
  let names: [String: String]
  let colors: [String: String]
  
  init(dictionary: [String: Any]) throws {
    var columns: [ColumnData] = []
    if let columnsData = dictionary["columns"] as? [[Any]] {
      for columnData in columnsData {
        do {
          let column = try ColumnData(array: columnData)
          columns.append(column)
        } catch {
          print("Could not parse colums: \(error)")
        }
      }
      columnDataArray = columns
    } else {
      throw ChartParsingError.noColumns
    }
    
    if let typesData = dictionary["types"] as? [String: String] {
      types = typesData
    } else {
      throw ChartParsingError.noTypes
    }
    
    if let namesData = dictionary["names"] as? [String: String] {
      names = namesData
    } else {
      throw ChartParsingError.noNames
    }
    
    if let colorsData = dictionary["colors"] as? [String: String] {
      colors = colorsData
    } else {
      throw ChartParsingError.noColors
    }
  }
  
  func toChartColumns() throws -> ChartColumns {
    var newColumns: [Column] = []
    for index in 0..<columnDataArray.count {
      let columnData = columnDataArray[index]
      guard let typeString = types[columnData.label] else {
        throw ColumnCreationError.noType
      }
      
      switch typeString {
      case "line":
        guard let colorHex = colors[columnData.label] else {
          throw ColumnCreationError.noColor
        }
        guard let name = names[columnData.label] else {
          throw ColumnCreationError.noName
        }
        guard let values = columnData.values as? [Int] else {
          throw ColumnCreationError.noValues
        }
        newColumns.append(.line(colorHex: colorHex, name: name, values: values))
      case "x":
        guard let values = columnData.values as? [Int64] else {
          throw ColumnCreationError.noValues
        }
        let timeIntervals = values.map { TimeInterval(Double($0) / 1000) }
        newColumns.append(.x(values: timeIntervals))
      default:
        throw ColumnCreationError.noType
      }
    }
    return try ChartColumns(columns: newColumns)
  }
}

struct DataImporter {
  static func importData() -> [Chart] {
    guard let path = Bundle.main.path(forResource: "chart_data", ofType: "json") else {
      return []
    }
    var charts: [Chart] = []
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
      let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
      guard let chartRawDataArray = jsonResult as? [[String: Any]] else {
        return []
      }
      for chartRawData in chartRawDataArray {
        let chartData = try ChartData(dictionary: chartRawData)
        let chartColumns = try chartData.toChartColumns()
        
        let yValues = chartColumns.yColumns.flatMap({ $0.values })
        
        let yMin = yValues.min() ?? 0
        let yMax = yValues.max() ?? 0
        
        let (minValueAcrossY, maxValueAcrossY, step) = YAxis.calculateSpan(yMin: yMin, yMax: yMax)
        
        let yAxes = chartColumns.yColumns.map {
          YAxis(values: $0.values, colorHex: $0.colorHex, name: $0.name,
                minValueAcrossY: minValueAcrossY, maxValueAcrossY: maxValueAcrossY, step: step)
        }
        let xAxis = XAxis(values: chartColumns.xColumn.values)
        let chart = Chart(xAxis: xAxis, yAxes: yAxes)
        charts.append(chart)
      }
    } catch {
      print("error while parsing JSON: \(error)")
    }
    return charts
  }
}
