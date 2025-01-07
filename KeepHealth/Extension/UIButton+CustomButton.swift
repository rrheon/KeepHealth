//
//  UIButton+CustomButton.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/6/25.
//

import UIKit

/// 평가 제목 enum
enum RateTitle: String {
  case good     = "Good"
  case normal   = "Normal"
  case bad      = "Bad"
  
  var rateTitle: String {
    return self.rawValue
  }
}

extension UIButton {
  
  /// KFButton 생성
  /// - Parameters:
  ///   - buttonTitle: 버튼 제목
  ///   - backgroundColor: 버튼 배경색
  ///   - buttonImageName: 버튼 이미지
  ///   - tintColor: tintColor
  /// - Returns: KFButton
  static func makeKFMainButton(
    buttonTitle: String,
    backgroundColor: UIColor,
    buttonImageName: String = "",
    tintColor: UIColor = .white
  ) -> UIButton {
    let button = UIButton()
    button.setTitle(buttonTitle, for: .normal)
    button.backgroundColor = backgroundColor
    button.layer.cornerRadius = 10
    button.setImage(UIImage(systemName: buttonImageName), for: .normal)
    button.semanticContentAttribute = .forceRightToLeft
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    button.tintColor = tintColor
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }
}
