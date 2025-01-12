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

  // collectionView 표시를 위한 식단 리스트
  var dietList: BehaviorRelay<[DietEntity]> = BehaviorRelay<[DietEntity]>(value: [])
  
  // 개별 식단 데이터
  var dietData: DietEntity? = nil
  
  // 식단 관리를 위한 데이터 - 추가, 편집
  var managementDietData: DietManagementModel? = nil
  
  init() {
    self.dietList.accept(RealmManager.shared.fetchSomeDateDiet())
  }
  
  func navigate(to step: AppStep){
    self.steps.accept(step)
  }
  
  
  /// 현재날짜 가져오기
  func getCurrentDate() -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
  
  // 변경사항 체크
  func updateNewData() -> NotificationToken {
    let realm = try! Realm()
    
    // 데이터베이스 변경을 감지하는 토큰 (강한 참조 유지 필요)
    return realm.observe { notification, realm in
      switch notification {
      case .didChange:
        print("Realm 데이터가 변경되었습니다.")
        // 예: UI 업데이트 또는 데이터 재로딩
        self.dietList.accept(RealmManager.shared.fetchSomeDateDiet())
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
                                    dietDate: getCurrentDate())
    
    steps.accept(AppStep.dismissIsRequired)
    steps.accept(AppStep.popupIsRequired(popupType: .confirmAdd))
  }
  
  /// 식단 수정
  func editDiet(){
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
    if let deletingDietID = dietData?.dietID {
      RealmManager.shared.deleteCurrentDiet(dietUUID: deletingDietID)
      
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
