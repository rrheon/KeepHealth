//
//  DietEntity.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/8/25.
//

import Foundation

import RealmSwift


/// 식단 Entity
class DietEntity: Object {
  @Persisted(primaryKey: true) var dietID: ObjectId
  @Persisted var imagesPathArray: List<String>
  @Persisted var dietType: String?
  @Persisted var dietContent: String? = ""
  @Persisted var dietRate: String? = ""
  @Persisted var dietDate: String? = ""
  
  convenience init(dietType: String? = nil,
                   dietContent: String? = nil,
                   dietRate: String? = nil,
                   dietDate: String? = nil) {
    self.init()
    
    self.dietType = dietType
    self.dietContent = dietContent
    self.dietRate = dietRate
    self.dietDate = dietDate
  }
}
