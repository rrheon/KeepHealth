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
  static var cellID: String {
    String(describing: Self.self)
  }
  
  private lazy var dietImageView = UIImageView().then {
    $0.image = UIImage(systemName: "")
    $0.backgroundColor = .black
    $0.layer.cornerRadius = 10
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
    buttonTitle: RateTitle.good.rateTitle,
    backgroundColor: UIColor(hexCode: KHColorList.mainGreen.rawValue)
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .white
  
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
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      dietImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      dietImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      dietImageView.widthAnchor.constraint(equalToConstant: 50),
      dietImageView.heightAnchor.constraint(equalToConstant: 50),
      
      dietTypeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      dietTypeLabel.leadingAnchor.constraint(equalTo: dietImageView.trailingAnchor, constant: 10),
      dietTypeLabel.trailingAnchor.constraint(lessThanOrEqualTo: rateButton.leadingAnchor, constant: 10),
      
      dietContentLabel.topAnchor.constraint(equalTo: dietTypeLabel.bottomAnchor, constant: 10),
      dietContentLabel.leadingAnchor.constraint(equalTo: dietImageView.trailingAnchor, constant: 10),
      dietContentLabel.trailingAnchor.constraint(lessThanOrEqualTo: rateButton.leadingAnchor, constant: 10),
      
      rateButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      rateButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      rateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
      rateButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
  }
  
}
