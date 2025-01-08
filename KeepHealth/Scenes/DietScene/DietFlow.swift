//
//  DietFlow.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift
import RxRelay

enum DietStep: Step {
  case dietListIsRequired
}


/// 식단 Flow
class DietFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }
  
  var viewModel: DietViewModel
  
  lazy var rootViewController : UINavigationController = {
    let nav = UINavigationController()
    nav.setNavigationBarHidden(false, animated: false)
    return nav
  }()
  
  
  init() {
    print(#fileID, #function, #line, "- ")
    self.viewModel = DietViewModel.shared
  }
  
  func navigate(to step: any RxFlow.Step) -> RxFlow.FlowContributors {
    guard let step = step as? DietStep else { return .none }

    switch step {
    case .dietListIsRequired:
      return setDietScreen()
    }
  }
  
  
  /// 식단리스트 화면 셋팅
  /// - Returns:FlowContributors
  private func setDietScreen() -> FlowContributors {
    let vc = DietListViewController()
    vc.dietVM = viewModel
    self.rootViewController.pushViewController(vc, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: viewModel))
  }
}
