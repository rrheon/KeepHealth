//
//  DietModelForSupabase.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/15/25.
//

import Foundation

struct Country: Codable, Identifiable {
  let id: Int
  let name: String
}


/// 식단 Entity for supabase
struct DietEntityToServer: Codable {
  var dietID: String? = ""
  var dietImage: String? = ""
  var dietType: String?
  var dietContent: String? = ""
  var dietRate: String? = ""
  var dietDate: String? = ""
  
  init(dietID: String? = nil,
       dietImage: String? = nil,
       dietType: String? = nil,
       dietContent: String? = nil,
       dietRate: String? = nil,
       dietDate: String? = nil
  ) {
    self.dietID = dietID
    self.dietImage = dietImage
    self.dietType = dietType
    self.dietContent = dietContent
    self.dietRate = dietRate
    self.dietDate = dietDate
  }
}
