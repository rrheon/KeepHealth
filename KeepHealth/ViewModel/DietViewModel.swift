//
//  DietViewModel.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import Foundation

import RxFlow
import RxCocoa
import RxSwift
import RxRelay
import RealmSwift


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
  
  /// 식단리스트화면 - collectionView 표시를 위한 식단 리스트
  var dietList: BehaviorRelay<[DietEntity]> = BehaviorRelay<[DietEntity]>(value: [])
  
  /// 식단관리화면 - 개별 식단 데이터
  var dietData: DietEntity? = nil
  
  /// 식단관리화면 - 식단 관리를 위한 데이터 - 추가, 편집
  var managementDietData: DietManagementModel? = nil
  
  /// 캘린더 화면 -  캘린더에서 선택된 날짜
  var selectedDate: BehaviorRelay<String> = BehaviorRelay(value: "Today")
  
  init() {
    self.dietList.accept(RealmManager.shared.fetchSomeDateDiet())
    
    self.chartRate.accept(RealmManager.shared.fetchDietScoreEntity())
    
    bindToChartCount()
  }
  
  func navigate(to step: AppStep){
    self.steps.accept(step)
  }
  

  /// 차트에 바인딩
  func bindToChartCount() {
    let chartRate = chartRate.value
    
    let good = Double(chartRate?.countGood ?? 0)
    let normal = Double(chartRate?.countNormal ?? 0)
    let bad = Double(chartRate?.countBad ?? 0)
    
    self.chartCount.accept([good, normal, bad])
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

}

extension DietViewModel: DateHelper {}
