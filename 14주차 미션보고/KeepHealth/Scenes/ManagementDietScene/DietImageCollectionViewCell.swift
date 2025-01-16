//
//  DietImageCollectionViewCell.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/15/25.
//

import UIKit

import SnapKit
import Then

/// 식단 이미지 셀
class DietImageCollectionViewCell: UICollectionViewCell {
  
  /// 식단 사진
  private lazy var dietImageView: UIImageView = UIImageView()
  
  /// 식단사진 제거 버튼
  private lazy var deleteDietImageButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .black
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /// UI 설정
  func setupUI(){
    [dietImageView, deleteDietImageButton]
      .forEach { self.addSubview($0) }
    
    // 식단이미지
    dietImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    // 이미지삭제 버튼
    deleteDietImageButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalTo(dietImageView.snp.trailing).offset(-10)
      $0.height.width.equalTo(15)
    }
  }
  
  /// 식단사진 설정
  func bindImage(with image: UIImage){
    dietImageView.image = image
  }
}
