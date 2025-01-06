//
//  UIColor+Ext.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/6/25.
//

import UIKit


/// Keep Health의 color List
enum KHColorList: String {
  case mainGreen        = "14752D"
  case mainGray         = "717970"
  case mainRed          = "B02E3D"
  case selectedGreen    = "D1E5CE"
  case backgroundGray   = "F3F3F3"
  
  var color: UIColor {
    return UIColor(hexCode: self.rawValue)
  }
}


extension UIColor {
  
  /// convert hexcode to UIColor
  /// - Parameters:
  ///   - hexCode: hexCode
  ///   - alpha: 알파값
  convenience init(hexCode: String, alpha: CGFloat = 1.0) {
    var hexFormatted = hexCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexFormatted.hasPrefix("#") {
      hexFormatted.removeFirst()
    }
    
    guard hexFormatted.count == 6, let rgbValue = UInt64(hexFormatted, radix: 16) else {
      fatalError("Invalid hex code used.")
    }
    
    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
}
