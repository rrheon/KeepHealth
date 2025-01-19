//
//  ManagementDietImages.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/19/25.
//

import UIKit


/// 식단사진 관리
class DietImagesManager {
  
  /// 이미지 디렉토리에 저장
  /// - Parameter images: [이미지이름(PK + index)) : 이미지]
  static func saveImagesToDocumentDirectory(images: [(imageName: String, image: UIImage)]) {
    
    // 이미지 배열 저장
    for (imageName, image) in images {
      // 1. 이미지를 저장할 경로 설정
      guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("ERROR: Failed to access document directory")
        continue
      }
      
      // 2. 이미지 파일 이름 및 최종 경로 설정
      let imageURL = documentDirectory.appendingPathComponent(imageName)
      
      // 3. 이미지 압축
      guard let data = image.pngData() else {
        print("ERROR: Failed to compress image \(imageName)")
        continue
      }
      
      // 4. 기존 파일 삭제
      if FileManager.default.fileExists(atPath: imageURL.path) {
        do {
          try FileManager.default.removeItem(at: imageURL)
          print("Deleted existing image at \(imageURL.path)")
        } catch {
          print("ERROR: Failed to delete existing image \(imageName): \(error.localizedDescription)")
          continue
        }
      }
      
      // 5. 이미지 저장
      do {
        try data.write(to: imageURL)
        print("Saved image: \(imageName) at \(imageURL.path)")
      } catch {
        print("ERROR: Failed to save image \(imageName): \(error.localizedDescription)")
      }
    }
  }
  
  
  // 식단앤티티에 이미지 주소 배열을 만들어서 가져오기
  
  /// 디렉토리에서 이미지 가져오기
  /// - Parameter imageName: 이미지 이름
  /// - Returns: 식단 이미지
  static func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
    
    // 1. 폴더 경로가져오기
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    
    if let directoryPath = path.first {
      // 2. 이미지 URL 찾기
      let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
      // 3. UIImage로 불러오기
      print(#fileID, #function, #line," - 이미지 가져오기 성공")
      
      return UIImage(contentsOfFile: imageURL.path)
    }
    
    return nil
  }
}
