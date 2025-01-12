//
//  Notification+Name.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

extension Notification.Name {
  
  /// 식단 추가 화면으로 이동
  static let navToAddDietEvent = Notification.Name("navToAddDietEvent")
  
  /// 식단 수정화면으로 이동
  static let navToEditDietEvent = Notification.Name("navToEditDietEvent")
  
  /// 캘린더화면 띄우기
  static let present = Notification.Name("navToEditDietEvent")
}
