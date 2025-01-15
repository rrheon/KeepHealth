//
//  DietViewModel.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift
import RxRelay
import RealmSwift
import Photos
import Supabase

/// 식단 ViewModel
class DietViewModel: Stepper {
  static let shared = DietViewModel()
  
  var steps: PublishRelay<Step> = PublishRelay()
  
  /// 점수화면 - 차트 라벨
  var chartLabel: [String] = RateTitle.allCases.map { $0.rawValue }
  
  /// 점수화면 - 라벨 별 평가 갯수
  var chartCount: BehaviorRelay<[Double]> = BehaviorRelay<[Double]>(value: [])
  
  /// 점수화면 - 차트 평가 entity
  var chartRate: BehaviorRelay<DietScoreEntity?> = BehaviorRelay<DietScoreEntity?>(value: nil)
  
  /// 점수화면 - 식단 점수
  var totalDietScore: BehaviorRelay<Int?> = BehaviorRelay<Int?>(value: nil)
  
  /// 식단리스트화면 - collectionView 표시를 위한 식단 리스트
  var dietList: BehaviorRelay<[DietEntity]> = BehaviorRelay<[DietEntity]>(value: [])
  
  /// 식단관리화면 - 개별 식단 데이터
  var dietData: DietEntity? = nil
  
  /// 식단관리화면 - 식단 관리를 위한 데이터 - 추가, 편집
  var managementDietData: DietManagementModel? = nil
  
  /// 캘린더 화면 -  캘린더에서 선택된 날짜
  var selectedDate: BehaviorRelay<String> = BehaviorRelay(value: "Today")
  
  /// 식단관리화면 - 촬영 , 선택된 이미지들
  var dietImages: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
  
  init() {
    self.dietList.accept(RealmManager.shared.fetchSomeDateDiet())
    self.chartRate.accept(RealmManager.shared.fetchDietScoreEntity())
    
    bindToChartCount()
    
    
    // 비동기 함수 호출을 위해 Task 사용
    Task {
      do {
        try await SupabaseManager.shared.deleteDataFromSupabase()
        try await SupabaseManager.shared.fetchFromSupabase()
      }catch {
        dump(error)
      }
      
    }
  }

  func navigate(to step: AppStep){
    self.steps.accept(step)
  }
  

  /// 차트에 바인딩
  func bindToChartCount() {
    let chartRate: DietScoreEntity? = chartRate.value
    
    let good: Double = Double(chartRate?.countGood ?? 0)
    let normal: Double = Double(chartRate?.countNormal ?? 0)
    let bad: Double = Double(chartRate?.countBad ?? 0)
    
    self.chartCount.accept([good, normal, bad])
  }
  
  /// 차트 및 점수 업데이트
  /// - Parameter entity: 식단
  func updateDietChartAndScore(entity: DietScoreEntity) {
    let updatedChartCount = [
      Double(entity.countGood),
      Double(entity.countNormal),
      Double(entity.countBad)
    ]
    // 차트 업데이트
    DietViewModel.shared.chartCount.accept(updatedChartCount)
    
    // 점수 업데이트
    updateDietScore(entity)
  }

  
  /// 식단 점수 업데이트
  func updateDietScore(_ entity: DietScoreEntity){
    let totalScore: Int = Int((entity.countGood * 3 + entity.countNormal) - entity.countBad)
    DietViewModel.shared.totalDietScore.accept(totalScore)
  }
  
  /// 데이터 변경사항 체크
  /// - Returns: NotificationToken
  func updateNewData() -> NotificationToken {
    let realm = try! Realm()
    
      return realm.observe { notification, realm in
      switch notification {
      case .didChange:
        print("Realm 데이터가 변경되었습니다.")
        
        let date: String = self.selectedDate.value
  
        self.dietList.accept(RealmManager.shared.fetchSomeDateDiet(dietDate: date))

        return
      case .refreshRequired:
        print("Realm 데이터가 새로고침되었습니다.")
        return
      }
    }
  }
  
  
  /// 팝업 케이스 가져오기
  /// - Parameter title: vc 제목
  /// - Returns: PopupCase - 팝업종류
  func getPopupCase(_ title: String) -> PopupCase {
    switch title {
    case ManageDietVCType.add.vcTitle:
      return PopupCase.add
    case ManageDietVCType.edit.vcTitle:
      return PopupCase.edit
    default:
      return PopupCase.delete
    }
  }
  
  
  /// 식단 이미지 관리 - 3개 제한
  /// - Parameter images: 식단이미지배열
  func managementImages(with images: [UIImage]){
    // 기존 이미지, 카메라에서 찍으면 기존에 선택한 사진들이 유지가 안됨 , 사진이 중복해서 들어감
    var storedImages: [UIImage] = dietImages.value
    print(#fileID, #function, #line," - \(storedImages.count)")

    
    storedImages.append(contentsOf: images)
    
    // 3개 초과시 맨 앞에서 부터 제거
    while storedImages.count > 3 {
      storedImages.remove(at: 0)
    }
    
    dietImages.accept(storedImages)
  }
  
  // MARK: - 식단 CRUD 후 화면이동
  
  /// 식단 생성
  func makeNewDiet(){
    RealmManager.shared.makeNewDiet(dietImage: managementDietData?.dietImage,
                                    dietType: managementDietData?.dietType,
                                    dietContent: managementDietData?.dietContent,
                                    dietRate: managementDietData?.dietRate,
                                    dietDate: getConvertedDate())
    
    steps.accept(AppStep.dismissIsRequired)
    steps.accept(AppStep.popupIsRequired(popupType: .confirmAdd))
  }
  
  /// 식단 수정
  func editDiet(){
    // 점수 업데이트
    if let dietRate = self.dietData?.dietRate,
       let changedDietRate = self.managementDietData?.dietRate {
      RealmManager.shared.updateDietScoreEntity(
        dietRate: RateTitle(rawValue: dietRate) ?? RateTitle.good,
        changeDietRate: RateTitle(rawValue: changedDietRate) ?? RateTitle.good
      )
    }
    
    RealmManager.shared.editCurrentDiet(dietUUID: dietData?.dietID,
                                        dietImage: managementDietData?.dietImage,
                                        dietType: managementDietData?.dietType,
                                        dietContent: managementDietData?.dietContent,
                                        dietRate: managementDietData?.dietRate)
    
    steps.accept(AppStep.dismissIsRequired)
    steps.accept(AppStep.popupIsRequired(popupType: .confirmEdit))
  }

  
  /// 식단 삭제
  func deleteDeit(){
    if let deletingDietID = dietData?.dietID,
       let dietRate = RateTitle(rawValue: dietData?.dietRate ?? "Good"){
      RealmManager.shared.deleteCurrentDiet(dietUUID: deletingDietID, rateTitle: dietRate)
      
      steps.accept(AppStep.dismissIsRequired)
      steps.accept(AppStep.popupIsRequired(popupType: .confirmDelte))
    }
  }
  
  
  /// 확인버튼 액션 - 팝업닫고 push된 화면 닫기
  func confirmButtonAction(){
    steps.accept(AppStep.dismissIsRequired)
    steps.accept(AppStep.popIsRequired)
  }
  
#warning("사진 작업 - 찍거나 선택하면 배열에 넣고 vc에 띄우기 - 버튼으로 제거 가능, 저장하면 배열채로 realm에 저장 , 라이트모드 설정")
  // TODO: 카메라 및 앨범 델리게이트 받아서 추가 화면에 띄우기, realm으로 CRUD 구현, collectionView에 사진 띄우기
  /// 갤러리 접근 허용여부에 따른 action
  /// - Returns: none
  func checkAuthBeforePresentPhotoScreen() {
    PHPhotoLibrary.requestAuthorization { [weak self] status in
      switch status {
      case .authorized:
        // 카메라 혹은 앨범 띄우기
        DietViewModel.shared.steps.accept(AppStep.photoIsRequired)
      case .denied, .restricted, .notDetermined:
        // 접근권한 설정 팝업 띄우기
        DietViewModel.shared.steps.accept(AppStep.popupIsRequired(popupType: .dietImage))
      default:
        break
      }
    }
  }
}

extension DietViewModel: DateHelper {}
