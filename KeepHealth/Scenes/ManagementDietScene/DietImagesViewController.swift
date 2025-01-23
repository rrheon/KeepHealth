//
//  DietImagesViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/22/25.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

/// 식단이미지 VC
class DietImagesViewController: UIViewController {
  
  let disposeBag: DisposeBag = DisposeBag()
  
  
  /// collectionView / cell 높이
  var imageheight: CGFloat = 0.0
  
  /// 식단 사진 제목 라벨
  private lazy var titleLabel = UILabel().then {
    $0.text = NSLocalizedString("DietDetailImage_Title", comment: "")
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .white
  }
  
  /// 식단 이미지 collecionview
  private lazy var dietImageCollectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.isPagingEnabled = true
    view.showsHorizontalScrollIndicator = false
    
    return view
  }()
  
  /// 이미지 카운트 라벨
  private lazy var imageCountLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .white
  }
  
  /// 화면 닫기버튼
  private lazy var dissmissScreenButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .white
    $0.addTarget(self, action: #selector(onDismissScreenBtnTapped), for: .touchUpInside)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    
    self.imageheight = view.bounds.height / 2
    setupLayout()
    
    registerCollectionViewCell()
    
  
  }// viewDidLoad
  
  
  /// UI 설정
  func setupLayout(){
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.snp.top).offset(80)
    }
    
    view.addSubview(imageCountLabel)
    imageCountLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(20)
      $0.centerX.equalTo(titleLabel)
    }
    
    view.addSubview(dissmissScreenButton)
    dissmissScreenButton.snp.makeConstraints {
      $0.centerY.equalTo(titleLabel)
      $0.trailing.equalTo(view.snp.trailing).offset(-20)
      $0.size.equalTo(50)
    }
    
    view.addSubview(dietImageCollectionView)
    dietImageCollectionView.snp.makeConstraints {
      $0.top.equalTo(imageCountLabel.snp.bottom).offset(50)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(imageheight)
    }
  }
  
  
  /// 식단 이미지 셀 등록
  func registerCollectionViewCell(){
    dietImageCollectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    dietImageCollectionView.register(
      DietImageCollectionViewCell.self,
      forCellWithReuseIdentifier: DietImageCollectionViewCell.cellID
    )
    
    // 이미지 바인딩
    
    DietViewModel.shared.dietImages
      .asDriver()
      .drive(dietImageCollectionView.rx.items(
        cellIdentifier: DietImageCollectionViewCell.cellID,
        cellType: DietImageCollectionViewCell.self)) { index, content, cell in
          cell.bindImage(with: content, index: index, deleteImageBtn: true)
        }
      .disposed(by: disposeBag)
  }


  /// 화면 닫기버튼 탭
  /// - Parameter sender: UIButton
  @objc func onDismissScreenBtnTapped(_ sender: UIButton){
    DietViewModel.shared.steps.accept(AppStep.dismissIsRequired)
  }
}

// collectionView cell의 크기
extension DietImagesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width, height: imageheight)
  }
}
