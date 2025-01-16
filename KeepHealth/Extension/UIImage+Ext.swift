//
//  UIImage+Ext.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/16/25.
//

import UIKit

extension UIImage {
  
  /// UIImage 생성 with color
  /// - Parameters:
  ///   - color: 생성할 색상
  ///   - size: 생성할 사이즈
  convenience init(color: UIColor, size: CGSize) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
    color.set()
    
    let context = UIGraphicsGetCurrentContext()!
    context.fill(CGRect(origin: .zero, size: size))
    
    
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    self.init(data: image.pngData()!)!
  }
}
