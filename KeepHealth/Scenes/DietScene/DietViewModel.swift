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
import UIKit
import RealmSwift

/// 식단 ViewModel
class DietViewModel: Stepper {
  static let shared = DietViewModel()
  var steps: PublishRelay<Step> = PublishRelay()

  var dietList: BehaviorRelay<[DietEntity]> = BehaviorRelay<[DietEntity]>(value: [])
  var dietData: DietEntity? = nil
  
  init() {
    self.dietList.accept(RealmManager.shared.fetchSomeDateDiet())
  }
  
  func navigate(to step: AppStep){
    self.steps.accept(step)
  }
  
  
  /// 현재날짜 가져오기
  func getCurrentDate() -> String{
    var formatter = DateFormatter()
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
}
