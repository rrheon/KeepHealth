
//
//  ViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/6/25.
//

import UIKit

import Then
import RxCocoa
import RxSwift
import RxFlow
import RxRelay
import RealmSwift

/// 식단목록 VC
class DietListViewController: UIViewController {
  
  var notificationToken: NotificationToken?
  var dietVM: DietViewModel? = nil

  let disposeBag = DisposeBag()

  /// 날짜 선택 버튼
  private lazy var selectDateButton = UIButton.makeKFMainButton(
    buttonTitle: "Today",
    backgroundColor: UIColor(hexCode: KHColorList.mainGreen.rawValue),
    buttonImageName: "chevron.down"
  )
  
  
  /// 식단 리스트
  private lazy var dietCollectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = 20
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = KHColorList.backgroundGray.color
    view.clipsToBounds = false
    return view
  }()
  
  
  /// 게시글 추가 버튼
  private lazy var addButton: UIButton = {
    let addButton = UIButton(type: .system)
    addButton.setTitle("+", for: .normal)
    addButton.setTitleColor(.white, for: .normal)
    addButton.backgroundColor = KHColorList.mainGreen.color
    addButton.layer.cornerRadius = 35
    addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
    addButton.addTarget(self, action: #selector(navToAddDietScene), for: .touchUpInside)
    return addButton
  }()
  
  /// 식단데이터가 없을 때 라벨
  private lazy var noDataLabel = UILabel().then {
    $0.text = NSLocalizedString("NoMealList", comment: "")
    $0.font = .boldSystemFont(ofSize: 24)
    $0.textColor = .black
  }
  
  // 식단 리스트 화면으로 이동하면 이미지 다 지워주기
  override func viewWillAppear(_ animated: Bool) {
    print(#fileID, #function, #line," - 나타남")
    
    dietVM?.dietImages.accept([])

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor(hexCode: KHColorList.backgroundGray.rawValue)
    settingNavigationTitle(title: NSLocalizedString("DietList_Navigation_title", comment: "") )
    
    setupLayout()
    setupCollectionView()
    setupBinding()
    setupActions()
    
    self.notificationToken = dietVM?.updateNewData()
  } // viewDidLoad
  
  
  // MARK: - functions
  
  /// layout 설정
  func setupLayout(){
    [
      selectDateButton,
      dietCollectionView,
      addButton,
      noDataLabel
    ].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      selectDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      selectDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      selectDateButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      selectDateButton.heightAnchor.constraint(equalToConstant: 40),
      selectDateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
      
      dietCollectionView.topAnchor.constraint(equalTo: selectDateButton.bottomAnchor, constant: 20),
      dietCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      dietCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      dietCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
      
      addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
      addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      addButton.widthAnchor.constraint(equalToConstant: 70),
      addButton.heightAnchor.constraint(equalToConstant: 70),
      
      noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    noDataLabel.isHidden = true
  }
  
  /// 식단 추가 화면으로 이동
  @objc func navToAddDietScene(){
    print(#fileID, #function, #line," - <#comment#>")

    NotificationCenter.default.post(name: .navToAddDietEvent, object: nil)
  }
  
  
  /// 캘린더 띄우기
  @objc func presnetCalendar(){
    dietVM?.steps.accept(DietStep.calenderIsRequired)
  }
  
  /// 식단 collectinoView 설정
  func setupCollectionView(){
    dietCollectionView.register(
      DietListCell.self,
      forCellWithReuseIdentifier: DietListCell.cellID
    )

    dietCollectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  
  /// binding
  func setupBinding(){
    // 선택한 날짜 바인딩
    dietVM?.selectedDate
      .asDriver()
      .drive(with: self, onNext: { vc, selectedDate in
        // 오늘 날짜가 선택된 경우 Today로 타이틀 변경
        let btnTitle: String = selectedDate == self.dietVM?.getConvertedDate() ? "Today" : selectedDate
        self.selectDateButton.setTitle(btnTitle, for: .normal)

        self.dietVM?.dietList.accept(RealmManager.shared.fetchSomeDateDiet(dietDate: selectedDate))
      })
      .disposed(by: disposeBag)
    
    // collectionView에 식단리스트 바인딩
    dietVM?.dietList
      .asDriver()
      .drive(dietCollectionView.rx.items(
        cellIdentifier: DietListCell.cellID,
        cellType: DietListCell.self)) { index, content, cell in
          print(#fileID, #function, #line," - \(content)")

          cell.updateCellUI(with: content)
        }
        .disposed(by: disposeBag)
    
    // 데이터 유무에 따라 UI 변경
    dietVM?.dietList
      .asDriver()
      .drive(onNext: { [weak self] dietData in
        self?.dietCollectionView.isHidden = dietData.isEmpty
        self?.noDataLabel.isHidden = !dietData.isEmpty
      })
      .disposed(by: disposeBag)
  }
  
  
  /// actions 설정
  func setupActions(){
    // collectionView 터치 시 액션
    dietCollectionView.rx.modelSelected(DietEntity.self)
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] item in
        NotificationCenter.default.post(name: .navToEditDietEvent,
                                        object: nil,
                                        userInfo: ["dietData": item])
      })
      .disposed(by: disposeBag)
    
    // 날짜선택버튼 action
    selectDateButton.addTarget(self, action: #selector(presnetCalendar), for: .touchUpInside)
  }
}

// MARK: - CollectionView DelegateFlowLayout

extension DietListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: self.view.bounds.width - 20, height: 70)
  }
}
