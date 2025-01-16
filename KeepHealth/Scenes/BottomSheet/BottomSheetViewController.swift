//
//  BottomSheetViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/14/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import Then


/// bottomSheet VC - 사진 선택 및 촬영
class BottomSheetViewController: UIViewController{
  
  let disposeBag: DisposeBag = DisposeBag()
  
  /// 사진촬영 버튼
  private lazy var selectCamearButton = UIButton().then {
    $0.setTitle("사진 촬영하기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
  }
  
  /// 앨범에서 선택 버튼
  private lazy var selectPhotoButton = UIButton().then {
    $0.setTitle("앨범에서 선택하기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
  }
  
  /// 닫기
  private lazy var dismissButton = UIButton().then {
    $0.setTitle("닫기", for: .normal)
    $0.setTitleColor(KHColorList.mainGreen.color, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
  }
  
  /// 버튼스택뷰
  private lazy var buttonStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 1
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = KHColorList.backgroundGray.color
    
    setupLayout()
    setupActions()
  } // viewDidLoad
  
  
  /// UI설정
  func setupLayout(){
    view.addSubview(buttonStackView)
    
    [selectCamearButton, selectPhotoButton, dismissButton]
      .forEach { buttonStackView.addArrangedSubview($0) }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(30)
      $0.leading.trailing.equalToSuperview().inset(10)
      $0.height.equalTo(250)
    }
  }
  
  
  /// acionts 설정
  func setupActions(){
    // 카메라 선택버튼 action
    selectCamearButton.rx.tap
      .asDriver()
      .drive(onNext: {
        DietViewModel.shared.steps.accept(AppStep.dismissIsRequired)
        DietViewModel.shared.steps.accept(AppStep.cameraIsRequired)
      })
      .disposed(by: disposeBag)
    
    selectPhotoButton.rx.tap
      .asDriver()
      .drive(onNext: {
        DietViewModel.shared.steps.accept(AppStep.dismissIsRequired)
        DietViewModel.shared.checkAuthBeforePresentPhotoScreen()
      })
      .disposed(by: disposeBag)
    
    // 닫기 버튼 action
    dismissButton.rx.tap
      .asDriver()
      .drive(onNext: {
        DietViewModel.shared.steps.accept(AppStep.dismissIsRequired)
      })
      .disposed(by: disposeBag)
  }
}
