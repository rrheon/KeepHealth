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
  
  var cellNumber: Int? = nil
  
  /// 식단 사진
  private lazy var dietImageView: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 10
  }
  
  /// 식단사진 제거 버튼
  private lazy var deleteDietImageButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .black
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.black.cgColor
    $0.addTarget(self, action: #selector(onDeleteImageBtnTapped), for: .touchUpInside)
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
      $0.trailing.equalTo(dietImageView.snp.trailing)
      $0.height.width.equalTo(25)
    }
  }
  
  /// 식단사진 설정
  func bindImage(with image: UIImage, index: Int, deleteImageBtn: Bool = false){
    dietImageView.image = image
    cellNumber = index
    deleteDietImageButton.isHidden = deleteImageBtn
  }
  
  
  /// 셀 지우기 - 등록한 사진 지우기
  /// - Parameter sender: UIButton
  @objc func onDeleteImageBtnTapped(_ sender: UIButton){
    guard let _cellNumber = cellNumber else { return }
    DietViewModel.shared.deleteDietImage(with: _cellNumber)
  }
}
