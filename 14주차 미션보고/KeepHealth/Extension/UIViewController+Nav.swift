//
//  UIViewController+Nav.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/16/25.
//

import UIKit

/// 페이지 종류
enum ManageDietVCType {
  case dietScore
  case dietList
  case addDiet
  case editDiet
  
  var vcTitle: String {
    switch self {
    case .dietScore: return "식단 점수"
    case .dietList:  return "식단 목록"
    case .addDiet:   return "식단 추가"
    case .editDiet:  return "식단 수정"
    }
  }
}

extension UIViewController {
  
  /// 네비게이션 바 제목 설정
  /// - Parameter title: 제목
  func settingNavigationTitle(title: String) {
    self.navigationItem.title = title
    
    if let appearance = self.navigationController?.navigationBar.standardAppearance {
      appearance.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
      ]
      
      self.navigationController?.navigationBar.standardAppearance = appearance
    }
  }
}
