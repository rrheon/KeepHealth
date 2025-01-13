//
//  RealmManager.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/8/25.
//

import Foundation

import RealmSwift

/// 식단 CRUD Manager
class RealmManager {
  static let shared = RealmManager()
 
  // CREATE
  
  /// 새로운 식단 생성
  /// - Parameters:
  ///   - dietImage: 식단 이미지(선택)
  ///   - dietType: 식단 종류(아침,점심,저녁)
  ///   - dietContent: 직단 내용
  ///   - dietRate: 식단 평가
  ///   - dietDate: 식단 날짜
  func makeNewDiet(dietImage: String?,
                   dietType: String?,
                   dietContent: String?,
                   dietRate: String?,
                   dietDate: String?){
    
    let newDiet = DietEntity(dietImage: dietImage,
                             dietType: dietType,
                             dietContent: dietContent,
                             dietRate: dietRate,
                             dietDate: dietDate)
    
    let realm = try! Realm()
    try! realm.write {
      realm.add(newDiet)
    }
  }
  
  // READ
  
  /// 식단데이터 읽어오기
  /// - Parameter dietDate: 원하는 식단 날짜 / 미 입력 시 오늘 날짜
  /// - Returns: [DietEntity]
  func fetchSomeDateDiet(dietDate: String = "Today") -> [DietEntity]{
    let realm = try! Realm()
    let dietEntity = realm.objects(DietEntity.self)

    let specificDate: String = dietDate == "Today" ? getConvertedDate() : dietDate
  
    return dietEntity.where { $0.dietDate == specificDate}.map { $0 }
  }
  
  // UPDATE
  
  func editCurrentDiet(dietUUID: ObjectId?,
                       dietImage: String?,
                       dietType: String?,
                       dietContent: String?,
                       dietRate: String?){
    let realm = try! Realm()
    let updatingEntitiy = realm.object(ofType: DietEntity.self, forPrimaryKey: dietUUID)

    try! realm.write {
      if let _dietType = dietType {
        updatingEntitiy?.dietType = _dietType
      }
      
      if let _dietContent = dietContent {
        updatingEntitiy?.dietContent = _dietContent
      }
      
      if let _dietRate = dietRate {
        updatingEntitiy?.dietRate = _dietRate
      }
    }
  }
  
  // DELETE
  func deleteCurrentDiet(dietUUID: ObjectId){
    let realm = try! Realm()
    guard let deleteEntitiy = realm.object(ofType: DietEntity.self, forPrimaryKey: dietUUID) else { return }
    
    try! realm.write {
        realm.delete(deleteEntitiy)
    }
  }
}

extension RealmManager: DateHelper {}
