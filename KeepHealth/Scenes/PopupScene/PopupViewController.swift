//
//  PopupViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/9/25.
//

import UIKit

import Then
import SnapKit


/// 팝업 VC
class PopupViewController: UIViewController {
  
  // rx로 이벤트처리하기
  
  // add - 취소 추가
  // edit - 취소 수정
  // conrfirm - 확인
  // delete - 삭제
  
  private lazy var popupView: PopupView? = nil
  
  init(popupType: PopupCase){
    super.init(nibName: nil, bundle: nil)
    
    self.popupView = PopupView(frame: .zero, popupCase: popupType)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .black.withAlphaComponent(0.3)
    
    setupLayout()
  }// viewDidLoad
  
  /// layout 설정
  func setupLayout(){
    guard let _popupView = popupView else { return }
    view.addSubview(_popupView)
    _popupView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
