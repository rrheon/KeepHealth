//
//  DietCellModel.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

/// 식단 타입 enum
enum DietType: String, CaseIterable {
  case morning = "아침"
  case lunch   = "점심"
  case dinner  = "저녁"
  
  /// Localized string for the enum case
  var localizedString: String {
    switch self {
    case .morning:
      return NSLocalizedString("ManagementDiet_DietType_title_Morning", comment: "")
    case .lunch:
      return NSLocalizedString("ManagementDiet_DietType_title_Lunch", comment: "")
    case .dinner:
      return NSLocalizedString("ManagementDiet_DietType_title_Dinner", comment: "")
    }
  }
  
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


/// 식단 평가 색상
enum DietRateColor: String {
  case good = "Good"
  case normal = "Normal"
  case bad = "Bad"
  
  var color: UIColor {
    switch self {
    case .good:   return KHColorList.mainGreen.color
    case .normal: return KHColorList.mainGray.color
    case .bad:    return KHColorList.mainRed.color
    }
  }
  
  
  /// 문자열 to 색상
  /// - Parameter rate: 평가 / Good , Normal, Bad
  /// - Returns: 색상
  static func color(from rate: String) -> UIColor? {
    return DietRateColor(rawValue: rate)?.color
  }
}
