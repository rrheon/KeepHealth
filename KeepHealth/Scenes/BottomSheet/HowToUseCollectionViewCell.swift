//
//  HowToUseCollectionViewCell.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/30/25.
//

import UIKit

import SnapKit
import Then


/// 식단 이미지 셀
class HowToUseCollectionViewCell: UICollectionViewCell {
  
  var cellNumber: Int? = nil
  
  /// 식단 사진
  private lazy var dietImageView: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 10
  }
  
  private lazy var contentLabel: UILabel = UILabel().then {
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
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
    [contentLabel, dietImageView]
      .forEach { self.addSubview($0) }
    
    // 이용방법 내용 라벨
    contentLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.centerX.equalTo(self.snp.centerX)
    }
    
    // 식단이미지
    dietImageView.snp.makeConstraints {
      $0.top.equalTo(contentLabel.snp.bottom).offset(10)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  /// 이용방법 사진 및 내용
  func bindImage(with image: UIImage, content: String){
    dietImageView.image = image
    contentLabel.text = content
  }
}
