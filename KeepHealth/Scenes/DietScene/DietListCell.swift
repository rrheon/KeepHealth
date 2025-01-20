//
//  DietListCell.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/6/25.
//

import UIKit

import Then


/// 식단리스트 셀
class DietListCell: UICollectionViewCell {

  private lazy var dietImageView = UIImageView().then {
    $0.image = UIImage(systemName: "")
    $0.backgroundColor = .black
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
  }
  
  private lazy var dietTypeLabel = UILabel().then {
    $0.text = "아침"
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
  }

  private lazy var dietContentLabel = UILabel().then {
    $0.text = "내용"
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .gray
  }
  
  private lazy var rateButton = UIButton.makeKFMainButton(
    buttonTitle: RateTitle.good.rawValue,
    backgroundColor: UIColor(hexCode: KHColorList.mainGreen.rawValue),
    cornerRadius: 20
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .white
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 15
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// layout 설정
  func setupLayout(){
    [
      dietImageView,
      dietTypeLabel,
      dietContentLabel,
      rateButton
    ].forEach {
      self.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      // 식단 이미지
      dietImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      dietImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      dietImageView.widthAnchor.constraint(equalToConstant: 50),
      dietImageView.heightAnchor.constraint(equalToConstant: 50),
      
      // 식단타입 라벨
      dietTypeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      dietTypeLabel.leadingAnchor.constraint(equalTo: dietImageView.trailingAnchor, constant: 10),
      dietTypeLabel.trailingAnchor.constraint(lessThanOrEqualTo: rateButton.leadingAnchor, constant: 10),
      
      // 식단내용 라벨
      dietContentLabel.topAnchor.constraint(equalTo: dietTypeLabel.bottomAnchor, constant: 10),
      dietContentLabel.leadingAnchor.constraint(equalTo: dietImageView.trailingAnchor, constant: 10),
      dietContentLabel.trailingAnchor.constraint(lessThanOrEqualTo: rateButton.leadingAnchor, constant: 10),
      
      // 식단평가 버튼
      rateButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      rateButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      rateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
      rateButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
  
  
  /// cell UI 업데이트
  func updateCellUI(with cellData: DietEntity){

    if let dietType = cellData.dietType {
      dietTypeLabel.text = DietType(rawValue: dietType)?.localizedString
    }
   
    dietContentLabel.text = cellData.dietContent
    rateButton.setTitle(cellData.dietRate, for: .normal)
    rateButton.backgroundColor = DietRateColor.color(from: cellData.dietRate ?? "Good")
    
    // 셀 사진 설정
    if let imagePath: String = cellData.imagesPathArray.first,
       let dietImage: UIImage = DietImagesManager.loadImageFromDocumentDirectory(imageName: imagePath){
      dietImageView.image = dietImage
      dietImageView.layer.cornerRadius = 25
    }else {
      dietImageView.image = UIImage(systemName: "fork.knife")
    }
  }
  
}
