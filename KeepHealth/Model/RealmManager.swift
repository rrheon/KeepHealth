//
//  RealmManager.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/8/25.
//

import Foundation

import RealmSwift
import UIKit

/// 식단 CRUD Manager
class RealmManager {
  static let shared = RealmManager()
  
  let realm = try! Realm()
  
  init(){
    self.createDietScoreEntityIfNeeded()
  }
  
  // CREATE
  
  /// 새로운 식단 생성
  /// - Parameters:
  ///   - dietImage: 식단 이미지(선택)
  ///   - dietType: 식단 종류(아침,점심,저녁)
  ///   - dietContent: 직단 내용
  ///   - dietRate: 식단 평가
  ///   - dietDate: 식단 날짜
  func makeNewDiet(dietImages: [UIImage?]? = [],
                   dietType: String?,
                   dietContent: String?,
                   dietRate: String?,
                   dietDate: String?)  {
    guard let dietRateString = dietRate,
          let rate = RateTitle(rawValue: dietRateString) else { return }
    
    // 새로운 식단 항목 생성
    let newDiet = DietEntity(dietType: dietType,
                             dietContent: dietContent,
                             dietRate: dietRate,
                             dietDate: dietDate)

    // 점수 업데이트
    updateDietScoreEntity(changeDietRate: rate)
    
    // 이미지 디렉토리에 저장, 이미지 경로 List<String>으로 변경 후 추가
    if let _images = dietImages {
      newDiet.imagesPathArray = Utils.convertArrayToList(wtih: getImagePaths(with: _images,
                                                                             dietID: newDiet.dietID))
    }
    
    // 새로운 식단 항목 추가
    try! realm.write {
      realm.add(newDiet)
    }
  }
  
  
  // READ
  
  /// 식단데이터 읽어오기
  /// - Parameter dietDate: 원하는 식단 날짜 / 미 입력 시 오늘 날짜
  /// - Returns: [DietEntity]
  func fetchSomeDateDiet(dietDate: String = "Today") -> [DietEntity]{
    let dietEntity = realm.objects(DietEntity.self)
    
    let specificDate: String = dietDate == "Today" ? getConvertedDate() : dietDate
    
    return dietEntity.where { $0.dietDate == specificDate}.map { $0 }
  }
  
  // UPDATE
  
  
  /// 식단 수정
  /// - Parameters:
  ///   - dietUUID: 식단 UUID
  ///   - dietImage: 식단 이미지
  ///   - dietType: 식단 유형
  ///   - dietContent: 식단 내용
  ///   - dietRate: 식단 평가
  func editCurrentDiet(dietUUID: ObjectId?,
                       dietImage: [UIImage?]?,
                       dietType: String?,
                       dietContent: String?,
                       dietRate: String?){
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
      
      // 수정된 이미지 다시 넣어주기
      if let _dietImages = dietImage, let _dietUUID = dietUUID {
        updatingEntitiy?.imagesPathArray = Utils.convertArrayToList(
          wtih: getImagePaths(with: _dietImages, dietID: _dietUUID)
        )
      }
    }
  }
  
  // DELETE
  
  /// 식단 삭제
  /// - Parameter dietUUID: 삭제할 식단 UUID
  func deleteCurrentDiet(dietUUID: ObjectId, rateTitle: RateTitle){
    guard let deleteEntitiy = realm.object(ofType: DietEntity.self, forPrimaryKey: dietUUID) else { return }
    
    // 점수 업데이트
    updateDietScoreEntity(dietRate: rateTitle)
    
    try! realm.write {
      realm.delete(deleteEntitiy)
    }
  }
  
  
  /// 이미지 저장 후 경로반환
  /// - Parameters:
  ///   - images: 식단이미지들
  ///   - dietID: 식단ID
  /// - Returns: 이미지 경로들
  func getImagePaths(with images: [UIImage?], dietID: ObjectId) -> [String]{
    // 식단 엔티티에 사진정보를 따로 저장 x, pk + 1~3 으로 찾기
    var imagesPathArray: [(String, UIImage)] = []
    var pathArray: [String] = []
    
    // 식단 순서, 경로 추가
    for (index, image) in images.compactMap({ $0 }).enumerated() {
      let path: String = "\(dietID)\(index).png"
      imagesPathArray.append((path, image))
      pathArray.append(path)
    }
  
    // 이미지 디렉토리에 저장
    DietImagesManager.saveImagesToDocumentDirectory(images: imagesPathArray)
   
    return pathArray
  }
  
  /// 점수 Entity 생성
  func createDietScoreEntityIfNeeded() {
    if realm.objects(DietScoreEntity.self).isEmpty {
      // 객체가 없다면 새로 생성
      let dietScore = DietScoreEntity(countGood: 0, countNormal: 0, countBad: 0, totalScore: 0)
      
      try! realm.write {
        realm.add(dietScore)
      }
    }
  }
  
  /// 점수 Entity 가져오기
  func fetchDietScoreEntity() -> DietScoreEntity? {
    return realm.objects(DietScoreEntity.self).first.map { $0 }
  }
  
  /// 식단 점수 업데이트
  /// - Parameters:
  ///   - dietRate: 기존의 식단 평가
  ///   - changeDietRate: 변경 식단 평가
  func updateDietScoreEntity(dietRate: RateTitle? = nil, changeDietRate: RateTitle? = nil){
    let updatingEntitiy = realm.objects(DietScoreEntity.self).map { $0 }
    
    // 카운트 - 기존 유형 카운트에서 -1 새로운 유형 카운트에서 + 1
    // 기존 카운트랑 확인 - 같으면 냅두고
    try! realm.write {
      // 두 평가에 해당하는 값을 하나의 배열로 처리
      let rateMap: [RateTitle: (Int) -> Void] = [
        .good: { value in updatingEntitiy.first?.countGood += value },
        .normal: { value in updatingEntitiy.first?.countNormal += value },
        .bad: { value in updatingEntitiy.first?.countBad += value }
      ]
      
      // 기존 rate는 감소시키고, 새로운 rate는 증가시킴
      if let _dietRate = dietRate {
        rateMap[_dietRate]?(-1)
      }
      
      if let _changeDietRate = changeDietRate {
        rateMap[_changeDietRate]?(1)
      }
    }
    
    // 차트 및 점수 업데이트
    if let entity = updatingEntitiy.first {
      DietViewModel.shared.updateDietChartAndScore(entity: entity)
    }
  }
  
}

extension RealmManager: DateHelper {}
