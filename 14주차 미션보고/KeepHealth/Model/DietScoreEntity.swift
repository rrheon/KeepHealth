//
//  DietScoreEntity.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/13/25.
//

import Foundation

import RealmSwift

/// 식단 점수 Entity
class DietScoreEntity: Object {
  @Persisted var countGood: Int
  @Persisted var countNormal: Int
  @Persisted var countBad: Int
  @Persisted var totalScore: Int
  
  convenience init(countGood: Int, countNormal: Int, countBad: Int, totalScore: Int) {
    self.init()
    
    self.countGood = countGood
    self.countNormal = countNormal
    self.countBad = countBad
    self.totalScore = totalScore
  }
}
