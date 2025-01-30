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
import PhotosUI

/// 화면 이동
enum AppStep: Step {
  
  /// 점수화면 , 식단 리스트 화면
  enum SceneType: Int {
    case score          = 0
    case dietList       = 1
    case managementDiet = 2
      
    
    /// 탭바 아이템
    var tabItem: UITabBarItem {
      switch self {
      case .score:
        return UITabBarItem(title: NSLocalizedString("Score_Navigation_title", comment: ""),
                            image: UIImage(systemName: "house"),
                            selectedImage: UIImage(systemName: "house.fill"))
      default:
        return UITabBarItem(title: NSLocalizedString("DietList_Navigation_title", comment: ""),
                            image: UIImage(systemName: "fork.knife"),
                            selectedImage: UIImage(systemName: "housefork.knife.circle.fill"))
      }
    }
    
    /// 네비게이션 바 타이틀
    var navTitle: String {
      switch self {
      case .score: return NSLocalizedString("Score_Navigation_title", comment: "")
      default:     return NSLocalizedString("DietList_Navigation_title", comment: "")
      }
    }

    /// 이용방법  내용
    var howToUseContent: String {
      switch self {
      case .score:          return NSLocalizedString("Score_HowToUse_Content", comment: "")
      case .dietList:       return NSLocalizedString("DietList_HowToUse_Content", comment: "")
      case .managementDiet: return NSLocalizedString("DietManagement_HowToUse_Content", comment: "")
      }
    }
  }
  
  
  case mainTabIsRequired                                      // 메인인화면
  case dietAddIsRequired                                      // 식단 추가화면
  case dietEditIsRequired(dietData: DietEntity)               // 식단 편집화면
  case popupIsRequired(popupType: PopupCase)                  // 팝업화면
  case dismissIsRequired                                      // 현재화면 dismiss
  case popIsRequired                                          // 현재화면 pop
  case managementDietImageIsRequired                          // 식단이미지 bottomSheet
  case cameraIsRequired                                       // 카메라 사용
  case photoIsRequired                                        //  앨범 사용
  case dietImageDetailIsRequired(imageIndex: Int)             // 식단 상세화면

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
    case .popupIsRequired(let popupType):
      return presentPopupScreen(popupType: popupType)
    case .dismissIsRequired:
      return dismissCurrnetScene()
    case .popIsRequired:
      return popCurrnetScene()
    case .managementDietImageIsRequired:
      return presentManagementDietImageBottomSheet()
    case .cameraIsRequired:
      return presentCameraScreen()
    case .photoIsRequired:
      return presentPhotoScreen()
    case .dietImageDetailIsRequired(let index):
      return presentDietImageDetailScreen(imageIndex: index)
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
      
      root1.tabBarItem = AppStep.SceneType.score.tabItem
      root1.title = AppStep.SceneType.score.navTitle
      
      root2.tabBarItem = AppStep.SceneType.dietList.tabItem
      root2.title = AppStep.SceneType.dietList.navTitle

      tabBarController.viewControllers = [root1, root2]
      tabBarController.tabBar.backgroundColor = .white
      tabBarController.tabBar.tintColor = KHColorList.mainGreen.color
      tabBarController.tabBar.unselectedItemTintColor = KHColorList.mainGray.color
      
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

    let vc = ManagementViewController()
    viewModel.dietData = dietData
    vc.dietVM = self.viewModel
    self.rootViewController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: self.viewModel))
  }

  
  /// 팝업뷰 띄우기
  /// - Parameter popupType: 팝업 뷰 타입 /  추가(add), 수정(edit), 확인(confrim), 삭제(delete)
  /// - Returns:none
  func presentPopupScreen(popupType: PopupCase) -> FlowContributors {
    let vc = PopupViewController(popupType: popupType)
    vc.modalPresentationStyle = .overFullScreen
    vc.modalTransitionStyle = .crossDissolve
    rootViewController.present(vc, animated: false)
    return .none
  }
  
  
  /// 현재 위치에서 dismiss
  /// - Returns: none
  func dismissCurrnetScene() -> FlowContributors{
    rootViewController.dismiss(animated: true)
    return .none
  }
  
  /// 현재 위치에서 pop
  /// - Returns: none
  func popCurrnetScene() -> FlowContributors{
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  
  /// 식단 사진 선택 bottomSheet 띄우기
  /// - Returns: none
  func presentManagementDietImageBottomSheet() -> FlowContributors{
    let vc = ManagementDietImageViewController()
    showBottomSheet(bottomSheetVC: vc, size: 300)
    rootViewController.present(vc, animated: true)
    return .none
  }
  
  
  /// 앨범 띄우기
  /// - Returns: none
  func presentPhotoScreen() -> FlowContributors {
    var config: PHPickerConfiguration = PHPickerConfiguration()
    // 최대 3개까지 선택가능
    config.selectionLimit = 3
    config.filter = .images
    
    let photoPicker = PHPickerViewController(configuration: config)
    
    let vc = rootViewController.viewControllers.compactMap { $0 as? ManagementViewController }.first
    photoPicker.delegate = vc
    
    rootViewController.present(photoPicker, animated: true)
    return .none
  }
  
  
  /// 카메라 회면으로 이동
  /// - Returns: description
  func presentCameraScreen() -> FlowContributors {
    let camera: UIImagePickerController = UIImagePickerController()
    camera.sourceType = .camera
    camera.allowsEditing = true
    camera.cameraDevice = .rear
    camera.cameraCaptureMode = .photo
    
    let vc = rootViewController.viewControllers.compactMap { $0 as? ManagementViewController }.first
    camera.delegate = vc
    camera.modalPresentationStyle = .overFullScreen
    rootViewController.present(camera, animated: true)
    
    print(#fileID, #function, #line," - \(rootViewController.viewControllers)")
    return .none
  }
  
  
  /// 식단 이미지 상세화면으로 이동
  /// - Returns: .none
  func presentDietImageDetailScreen(imageIndex: Int) -> FlowContributors {
    let vc = DietImagesViewController(index: imageIndex)
    vc.modalTransitionStyle = .crossDissolve
    vc.modalPresentationStyle = .overFullScreen
    rootViewController.present(vc, animated: true)
    return .none
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

extension AppFlow: ShowBottomSheet {}
