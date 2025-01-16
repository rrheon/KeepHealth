//
//  UIsegmentControl+Ext.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/16/25.
//

import UIKit

extension UISegmentedControl {
  
  /// segment layout 설정
  /// - Parameters:
  ///   - backgorundColor: 배경색상
  ///   - titleColor: 제목색상
  func setLayout(backgorundColor: UIColor, titleColor: UIColor = .black) {
    if #available(iOS 13, *) {
      let background = UIImage(color: KHColorList.selectedGreen.color, size: CGSize(width: 2, height: 30))
      let selectedBackground = UIImage(color: KHColorList.mainGreen.color, size: CGSize(width: 2, height: 30))
      let divider = UIImage(color: .black, size: CGSize(width: 2, height: 30))
      self.setBackgroundImage(background, for: .normal, barMetrics: .default)
      self.setBackgroundImage(selectedBackground, for: .selected, barMetrics: .default)
      self.setDividerImage(divider, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
      self.layer.borderWidth = 2
      self.layer.borderColor = UIColor.black.cgColor
      
      self.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
      self.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    } else {
      self.tintColor = tintColor
    }
  }
}
