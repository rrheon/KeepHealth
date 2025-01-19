//
//  BottomSheetProtocol.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/19/25.
//

import UIKit

protocol ShowBottomSheet {
  
  /// bottomSheet 띄우기
  /// - Parameters:
  ///   - bottomSheetVC: bottomSheet에 띄울 vc
  ///   - size: bottomSheet 사이즈
  func showBottomSheet(bottomSheetVC: UIViewController, size: Double)
}

extension ShowBottomSheet {
  func showBottomSheet(bottomSheetVC: UIViewController, size: Double){
    if #available(iOS 15.0, *) {
      if let sheet = bottomSheetVC.sheetPresentationController {
        if #available(iOS 16.0, *) {
          sheet.detents = [.custom(resolver: { context in
            return size
          })]
        } else {
          // Fallback on earlier versions
        }
        sheet.largestUndimmedDetentIdentifier = nil
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        sheet.preferredCornerRadius = 20
      }
    } else {
      // Fallback on earlier versions
      bottomSheetVC.modalPresentationStyle = .overFullScreen
      bottomSheetVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: size)
    }
  }
}
