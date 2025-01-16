//
//  DateProtocol.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/13/25.
//

import Foundation


/// 날짜 관련 프로토콜 / 현재날짜 가져오기, date to string
protocol DateHelper{
  func getConvertedDate(date: Date) -> String
}

extension DateHelper {
  /// yyyy-MM-dd 형식으로 날짜변환 / 현재날짜 가져오기
  /// - Parameter date: 변경하려는 날짜 / 없으면 현재날짜
  /// - Returns: convertedDate
  func getConvertedDate(date: Date = Date()) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}


