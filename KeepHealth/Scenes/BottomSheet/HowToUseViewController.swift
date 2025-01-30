//
//  HowToUseViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/30/25.
//

import UIKit

import SnapKit
import Then

/// bottomSheet - 사용방법 VC
class HowToUseViewController: UIViewController {
  
  let images: [UIImage?] = [
    UIImage(named: "ScoreImage"),
    UIImage(named: "DietListImage"),
    UIImage(named: "ManagementImage")
  ]
  
  private lazy var howToUseCollectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var skipButton = UIButton().then {
    $0.setTitle("다시 보지 않기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
  }
  
  private lazy var closeButton = UIButton().then {
    $0.setTitle("닫기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    setupLayout()
    
    howToUseCollectionView.register(HowToUseCollectionViewCell.self,
                                    forCellWithReuseIdentifier: HowToUseCollectionViewCell.cellID)
    howToUseCollectionView.dataSource = self
    howToUseCollectionView.delegate = self
    
  }// viewDidLoad
  
  func setupLayout(){
    [howToUseCollectionView, skipButton, closeButton]
      .forEach { view.addSubview($0) }
    
    howToUseCollectionView.snp.makeConstraints {
      $0.top.equalTo(view.snp.top).offset(20)
      $0.width.equalToSuperview()
      $0.height.equalTo(150)
    }
    
    skipButton.snp.makeConstraints {
      $0.top.equalTo(howToUseCollectionView.snp.bottom).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.equalTo(100)
    }
    
    closeButton.snp.makeConstraints {
      $0.top.equalTo(skipButton)
      $0.trailing.equalToSuperview().offset(-10)
      $0.size.equalTo(50)
    }
  }
}

extension HowToUseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HowToUseCollectionViewCell.cellID,
                                                  for: indexPath) as? HowToUseCollectionViewCell
    if let image = images[indexPath.row] {
      cell?.bindImage(with: image, content: AppStep.SceneType.dietList.howToUseContent)
      return cell ?? UICollectionViewCell()
    }
    return UICollectionViewCell()
  }
}

extension HowToUseViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width, height: 200)
  }
}
