//
//  DietModel.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/9/25.
//

import Foundation

/// 식단 관리 모델
struct DietManagementModel {
  // 식단 종류 - 아침, 점심 , 저녁 / 식단 평가 - Good, Normal, Bad / 식단 내용
  let dietType, dietRate, dietContent: String
  // 식단 날짜 / 식단 이미지
  let dietDate, dietImage: String?

  init(_ dietType: String,
       _ dietRate: String,
       _ dietContent: String,
       _ dietDate: String?,
       _ dietImage: String?) {
    self.dietType = dietType
    self.dietRate = dietRate
    self.dietContent = dietContent
    self.dietDate = dietDate
    self.dietImage = dietImage
  }
}
