//
//  Utils.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/19/25.
//

import UIKit

import RealmSwift

class Utils {
  // 패치 시: List<String> -> [String] / 저장 시: [String] -> List<String>
  
  /// List 를 Array로 변경
  /// - Parameter datas: Realm의 List
  /// - Returns: Array
  static func convertListToArray<T>(wtih datas: List<T>) -> [T]{
    return datas.map { $0 }
  }
  
  
  /// Array를 List로 변경
  /// - Parameter datas: Array
  /// - Returns: Realm의 List
  static func convertArrayToList<T>(wtih datas: [T]) -> List<T>{
    let convertedDatas: List<T> = List<T>()
    convertedDatas.append(objectsIn: datas.map({ $0 }))
    return convertedDatas
  }
}
