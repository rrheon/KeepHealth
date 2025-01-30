//
//  ScoreFlow.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift
import RxRelay

enum ScoreStep: Step {
  case socreIsRequired
  case howToUseIsRequired
}


/// 점수 Flow
class ScoreFlow: Flow, ShowBottomSheet {
  var viewModel: DietViewModel

  var root: Presentable {
    return self.rootViewController
  }
  
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
    guard let step = step as? ScoreStep else { return .none }

    switch step {
    case .socreIsRequired:
      return setScoreScreen()
    case .howToUseIsRequired:
      return presentHowTouseScreen()
    }
  }
  
  
  /// 점수화면 셋팅
  /// - Returns: FlowContributors
  private func setScoreScreen() -> FlowContributors {
    let vc = ScoreViewController()
    vc.dietVM = self.viewModel
    self.rootViewController.pushViewController(vc, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: viewModel))
  }
  
  func presentHowTouseScreen() -> FlowContributors {
    let vc = HowToUseViewController()
    showBottomSheet(bottomSheetVC: vc, size: 300)
    rootViewController.present(vc, animated: true)
    return .none
  }
}
