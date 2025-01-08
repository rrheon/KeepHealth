//
//  AppFlow.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift
import RxRelay


/// 화면 이동
enum AppStep: Step {
  
  /// 점수화면 , 식단 리스트 화면
  enum TabType: Int {
    case score    = 0
    case dietList = 1
  
    var tabItem: UITabBarItem {
      switch self {
      case .score:
        return UITabBarItem(title: "점수", image: UIImage(systemName: "house"),
                            selectedImage: UIImage(systemName: "house.fill"))
      case .dietList:
        return UITabBarItem(title: "식단", image: UIImage(systemName: "fork.knife"),
                            selectedImage: UIImage(systemName: "housefork.knife.circle.fill"))
      }
    }
    
    var title: String {
      switch self {
      case .score: return "점수"
      case .dietList: return "식단"
      }
    }
  }
  
  
  case mainTabIsRequired                          // 메인인화면
  case dietAddIsRequired                          // 식단 추가화면
  case dietEditIsRequired(dietData: DietEntity)  // 식단 편집화면
  case calenderIsRequired                        // 캘린더화면
  case popupIsRequired                           // 팝업화면
  case howToUseIsRequired                        // 사용방법 화면
}


/// 전체 Flow
class AppFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  lazy var rootViewController: UINavigationController = UINavigationController()
  
  lazy var tabBarController: UITabBarController = UITabBarController()

  let viewModel: DietViewModel
  
  init(){
    print(#fileID, #function, #line," - ")
    self.viewModel = DietViewModel.shared
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    switch step {
      
    case .mainTabIsRequired:
      return setupMainTabBar()
    case .dietAddIsRequired:
      return navToAddDietScreen()
    case .dietEditIsRequired(let dietData):
      return navToAddDietScreen(dietData: dietData)
    default:
      return .none
    }
  }
  
  
  /// 메인 탭바 설정
  /// - Returns: FlowContributors
  func setupMainTabBar() -> FlowContributors{
    let scoreFlow = ScoreFlow()
    let dietListFlow = DietFlow()
    
    Flows.use(scoreFlow, dietListFlow, when: .ready){ [unowned self] (
      root1: UINavigationController, root2: UINavigationController) in
      
      root1.tabBarItem = AppStep.TabType.score.tabItem
      root1.title = AppStep.TabType.score.title
      
      root2.tabBarItem = AppStep.TabType.dietList.tabItem
      root2.title = AppStep.TabType.dietList.title

      tabBarController.viewControllers = [root1, root2]
      
      rootViewController.setViewControllers([tabBarController], animated: false)
      rootViewController.navigationBar.isHidden = true
    }

    return .multiple(flowContributors: [
      .contribute(withNextPresentable: scoreFlow,
                  withNextStepper: OneStepper(withSingleStep: ScoreStep.socreIsRequired)),
      .contribute(withNextPresentable: dietListFlow,
                  withNextStepper: OneStepper(withSingleStep: DietStep.dietListIsRequired))
    ])
  }
  
  
  
  /// 식단 추가화면으로 이동
  /// - Returns: FlowContributors
  func navToAddDietScreen(dietData: DietEntity? = nil) -> FlowContributors {
    print(#fileID, #function, #line," - <#comment#>")

    let vc = AddDietViewController()
    viewModel.dietData = dietData
    vc.dietVM = self.viewModel
    self.rootViewController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: self.viewModel))
  }
}


/// 전체 AppStepper -  리모컨
class AppStepper: Stepper {
  let steps: PublishRelay<Step> = PublishRelay()
  private let disposBag = DisposeBag()
  
  var initialStep: Step {
    return AppStep.mainTabIsRequired
  }
  
  func navigate(to step: AppStep){
    self.steps.accept(step)
  }
  
  func readyToEmitSteps() {
      Observable.merge(
          NotificationCenter.default.rx.notification(.navToAddDietEvent).map { _ in AppStep.dietAddIsRequired },
          NotificationCenter.default.rx.notification(.navToEditDietEvent).map { notification in
            guard let data = notification.userInfo?["dietData"] as? DietEntity else { return AppStep.dietAddIsRequired}
            return AppStep.dietEditIsRequired(dietData: data)
          }
      )
      .bind(to: self.steps)
      .disposed(by: disposBag)
  }
}

