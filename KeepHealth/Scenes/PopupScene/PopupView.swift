//
//  PopupView.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/9/25.
//

import UIKit

import SnapKit
import Then

/// 팝업 종류
enum PopupCase {
  case add           // 추가 팝업
  case edit          // 수정 팝업
  case confirmAdd    // 추가확인 팝업
  case confirmDelte  // 삭제확인 팝업
  case confirmEdit   // 수정확인 팝업
  case delete        // 삭제 팝업
  case dietImage     // 이미지 권한설정 팝업
  
  
  /// 팝업 title
  var titleContent: String {
    switch self {
    case .add:          return NSLocalizedString("PopupTitle_Add", comment: "")
    case .edit:         return NSLocalizedString("PopupTitle_Edit", comment: "")
    case .confirmAdd:   return NSLocalizedString("PopupTitle_Confirm_Add", comment: "")
    case .confirmDelte: return NSLocalizedString("PopupTitle_Confirm_Delete", comment: "")
    case .confirmEdit:  return NSLocalizedString("PopupTitle_Confirm_Edit", comment: "")
    case .delete:       return NSLocalizedString("PopupTitle_Delete", comment: "")
    case .dietImage:    return NSLocalizedString("PopupTitle_Confirm_Access", comment: "")
    }
  }
  
  
  /// 버튼 title
  var buttonContent: String {
    switch self {
    case .add:      return NSLocalizedString("PopupTitle_Button_Add", comment: "")
    case .edit:     return NSLocalizedString("PopupTitle_Button_Eidt", comment: "")
    case .delete:   return NSLocalizedString("PopupTitle_Button_Delete", comment: "")
    default:        return NSLocalizedString("PopupTitle_Button_Confirm", comment: "")
    }
  }
}


/// 팝업 뷰
class PopupView: UIView {
  
  var popupType: PopupCase? = nil
  
  // 팝업 컨테이너 뷰
  private lazy var containerView = UIView().then {
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .white
  }

  // 팝업제목 라벨
  private lazy var popupTitleLabel = UILabel().then {
    $0.text = PopupCase.add.buttonContent
    $0.textColor = .black
    $0.font = .boldSystemFont(ofSize: 18)
  }
  
  // 버튼 스택뷰
  private lazy var buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 10
  }
  
  // 팝업 왼쪽 버튼
  private lazy var popupLeftButton = UIButton().then {
    $0.setTitle(NSLocalizedString("PopupTitle_Button_Cancle", comment: ""), for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = KHColorList.mainGreen.color.cgColor
  }
  
  // 팝업 오른쪽 버튼
  private lazy var popupRightButton = UIButton().then {
    $0.setTitle(NSLocalizedString("PopupTitle_Button_Add", comment: ""), for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = KHColorList.mainGreen.color
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = KHColorList.mainGreen.color.cgColor
  }
  
  convenience init(frame: CGRect, popupCase: PopupCase) {
    self.init(frame: frame)
    
    self.backgroundColor = .clear
    
    self.popupType = popupCase
    
    self.popupTitleLabel.text = popupCase.titleContent
    self.popupRightButton.setTitle(popupCase.buttonContent, for: .normal)
    
    
    popupLeftButton.addAction(UIAction { _ in
      DietViewModel.shared.steps.accept(AppStep.dismissIsRequired)
    }, for: .touchUpInside)
    
    setupLayout()
    setupPopupUI(popupType: popupCase)
    
    popupRightButton.addTarget(self, action: #selector(setupButtonAction), for: .touchUpInside)
  }
  
  /// layout 설정
  func setupLayout(){
    self.addSubview(containerView)
    
    [popupTitleLabel, buttonStackView]
      .forEach { containerView.addSubview($0) }
    
    [popupLeftButton, popupRightButton]
      .forEach {
        buttonStackView.addArrangedSubview($0)
        
        $0.snp.makeConstraints {
          $0.height.equalTo(50)
        }
      }
    
    // 컨테이너 뷰
    containerView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.height.equalTo(150)
      $0.width.equalToSuperview().multipliedBy(0.8)
    }
    
    // 팝업제목 라벨
    popupTitleLabel.snp.makeConstraints {
      $0.top.equalTo(containerView.snp.top).offset(20)
      $0.centerX.equalTo(containerView.snp.centerX)
    }
    
    // 버튼 스택뷰
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(popupTitleLabel.snp.bottom).offset(30)
      $0.leading.equalTo(containerView.snp.leading).offset(20)
      $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
    }
  }
  
  /// 팝업 타입별로 UI 설정
  /// - Parameter popupType: popupCase
  func setupPopupUI(popupType: PopupCase){
    popupTitleLabel.text = popupType.titleContent
    popupRightButton.setTitle(popupType.buttonContent, for: .normal)
    
    // 팝업 타입이 확인인 경우 왼쪽 버튼 숨김처리
    if popupType == .confirmAdd || popupType == .confirmEdit || popupType == .confirmDelte  {
      popupLeftButton.isHidden = true
    }
  }
  
  
  /// 버튼 Actions 설정
  @objc func setupButtonAction(){
    guard let _popupType = popupType else { return }
    setupButtonActions(popupType: _popupType)
  }
  
  
  /// 버튼 Actions 설정
  /// - Parameter popupType: 팝업종류 - PopupCase
  func setupButtonActions(popupType: PopupCase){
    switch popupType {
    case .add:    return DietViewModel.shared.makeNewDiet()
    case .edit:   return DietViewModel.shared.editDiet()
    case .delete: return DietViewModel.shared.deleteDiet()
    default:      return DietViewModel.shared.confirmButtonAction()
    }
  }
}
