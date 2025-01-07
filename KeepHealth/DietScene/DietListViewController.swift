//
//  ViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/6/25.
//

import UIKit

import Then
import RxCocoa

/// 식단목록 VC
class DietListViewController: UIViewController, UICollectionViewDelegate {

  
  /// 날짜 선택 버튼
  private lazy var selectDateButton = UIButton.makeKFMainButton(
    buttonTitle: "Today",
    backgroundColor: UIColor(hexCode: KHColorList.mainGreen.rawValue),
    buttonImageName: "chevron.down"
  )

  
  /// 식단 리스트
  private var dietCollectionView: UICollectionView {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = 10
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = .white
    view.clipsToBounds = false
    
    return view
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor(hexCode: KHColorList.backgroundGray.rawValue)
    self.title = "식단 목록"
    
    setupLayout()
    
    dietCollectionView.delegate = self
    dietCollectionView.register(
      DietListCell.self,
      forCellWithReuseIdentifier: DietListCell.cellID
    )
  } // viewDidLoad

  
  /// layout 설정
  func setupLayout(){
    view.addSubview(selectDateButton)
    selectDateButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      selectDateButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
      selectDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      selectDateButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      selectDateButton.heightAnchor.constraint(equalToConstant: 40),
      selectDateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
    ])
  }
}

extension DietListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: self.view.bounds.width / 2 - 10, height: 50)
  }
}



// 전처리
#if DEBUG

import SwiftUI
@available(iOS 13.0, *)

// UIViewControllerRepresentable을 채택
struct ViewControllerRepresentable: UIViewControllerRepresentable {
  // update
  // _ uiViewController: UIViewController로 지정
  func updateUIViewController(_ uiViewController: UIViewController , context: Context) {
    
  }
  // makeui
  func makeUIViewController(context: Context) -> UIViewController {
    // Preview를 보고자 하는 Viewcontroller 이름
    // e.g.)
    
    return DietListViewController()
  }
}

struct ViewController_Previews: PreviewProvider {
  
  @available(iOS 13.0, *)
  static var previews: some View {
    // UIViewControllerRepresentable에 지정된 이름.
    ViewControllerRepresentable()
    
    // 테스트 해보고자 하는 기기
      .previewDevice("iPhone 11")
  }
}
#endif


