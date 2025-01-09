//
//  DietCellModel.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import Foundation


/// 식단 타입 enum
enum DietType: String, CaseIterable {
  case morning = "아침"
  case lunch   = "점심"
  case dinner  = "저녁"
  
  
  /// 숫자 to 문자열
  /// - Parameter index: 문자열
  /// - Returns: 숫자
  static func fromIndex(_ index: Int) -> String {
    return DietType.allCases[index].rawValue
  }
  
  
  /// 문자열 to 숫자
  /// - Parameter value: 문자열
  /// - Returns: 숫자
  static func fromString(_ value: String) -> Int? {
    return DietType.allCases.firstIndex(where: { $0.rawValue == value })
  }
}
