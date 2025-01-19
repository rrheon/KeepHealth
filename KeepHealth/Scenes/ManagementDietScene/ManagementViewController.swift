//
//  AddDietScene.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxFlow
import RxRelay
import Then
import PhotosUI


/// 식단 관리 VC
class ManagementViewController: UIViewController {
  var dietVM: DietViewModel? = nil
  
  let disposeBag: DisposeBag = DisposeBag()
  
  
  /// 식단 종류 segment
  private lazy var selectDietTypeSegment: UISegmentedControl = {
    let control = UISegmentedControl(items: [DietType.morning.rawValue,
                                             DietType.lunch.rawValue,
                                             DietType.dinner.rawValue])

    control.setLayout(backgorundColor: KHColorList.mainGreen.color)
    control.addTarget(self, action: #selector(selectSegment(sender: )), for: .valueChanged)
    return control
  }()
  
  
  /// 식단사진추가 제목 라벨
  private lazy var dietImageTitleLabel = UILabel().then {
    $0.text = NSLocalizedString("ManagementDiet_AddDietTitle", comment: "")
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  /// 식단사진 추가 버튼
  private lazy var addDietImageButton = UIButton().then {
    $0.setTitle("+", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 10
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
  }
  
  
  /// 식단사진 collectionview
  private lazy var dietImageCollectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = 10
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = .clear
    view.clipsToBounds = false
    return view
  }()

  
  /// 식단내용 제목 라벨
  private lazy var dietContentTitleLabel = UILabel().then {
    $0.text = NSLocalizedString("ManagementDiet_DietContent", comment: "")
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  
  /// 식단내용 TextView
  private lazy var dietContentTextView = UITextView().then {
    $0.text = NSLocalizedString("ManagementDiet_DietContent_TextView", comment: "")
    $0.textColor = .lightGray
    $0.backgroundColor = .white
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1.0
    $0.layer.cornerRadius = 10
    $0.tintColor = .black
    $0.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
  }
  
  
  /// 식단평가 제목 타이틀
  private lazy var dietRatingTitleLabel = UILabel().then {
    $0.text = NSLocalizedString("ManagementDiet_DietRateTile", comment: "")
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  
  /// 식단평가 segmentcontrol
  private lazy var selectDietRateSegment: UISegmentedControl = {
    let control = UISegmentedControl(items: ["Good", "Normal", "Bad"])
    control.setLayout(backgorundColor: KHColorList.mainGreen.color)
    return control
  }()
  
  
  /// 식단추가버튼
  private lazy var addDietButton = UIButton.makeKFMainButton(
    buttonTitle: NSLocalizedString("ManagementDiet_ButtonTitle", comment: ""),
    backgroundColor: KHColorList.mainGray.color
  )
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.isHidden = false
    settingNavigationTitle(title: ManageDietVCType.addDiet.vcTitle)
    self.view.backgroundColor = KHColorList.backgroundGray.color
    
    setupLayout()
    
    // 노티피케이션 등록
    registerNotifications()
    
    // delegate 및 collectionView 셀 등록
    addDelegateAndRegisterCell()
    
    // 버튼액션 추가
    addButtonActions()
    
    // 네비게이션바 아이템 설정
    setupNavigationItem()
    
    // 바인딩 설정
    setupBindings()
  
    // 개별 데이터가 있으면 편집
    if let data: DietEntity = dietVM?.dietData {
      updateEditDietScreen(data: data)
    }
  }// viewDidLoad
  
#warning("supabase test용")
//  override func viewDidDisappear(_ animated: Bool) {
//    Task {
//      do {
//        let action = SupabaseManager.shared.selectSupabaseAction()
//        try await action()
//      }catch {
//        dump(error)
//      }
//    }
//  }
  
  /// layout 설정
  func setupLayout(){
    [
      selectDietTypeSegment,
      dietImageTitleLabel,
      addDietImageButton,
      dietImageCollectionView,
      dietContentTitleLabel,
      dietContentTextView,
      dietRatingTitleLabel,
      selectDietRateSegment,
      addDietButton
    ].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      // 식단 타입 세그먼트
      selectDietTypeSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
      selectDietTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      selectDietTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      selectDietTypeSegment.heightAnchor.constraint(equalToConstant: 50),
      
      // 식단이미지 제목 라벨
      dietImageTitleLabel.topAnchor.constraint(equalTo: selectDietTypeSegment.bottomAnchor, constant: 20),
      dietImageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietImageTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단이미지 추가 버튼
      addDietImageButton.topAnchor.constraint(equalTo: dietImageTitleLabel.bottomAnchor, constant: 20),
      addDietImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      addDietImageButton.heightAnchor.constraint(equalToConstant: 70),
      addDietImageButton.widthAnchor.constraint(equalToConstant: 70),
      
      // 식단이미지 collectionview
      dietImageCollectionView.topAnchor.constraint(equalTo: addDietImageButton.topAnchor),
      dietImageCollectionView.leadingAnchor.constraint(equalTo: addDietImageButton.trailingAnchor, constant: 10),
      dietImageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dietImageCollectionView.heightAnchor.constraint(equalToConstant: 70),
      
      // 식단내용 제목 라벨
      dietContentTitleLabel.topAnchor.constraint(equalTo: addDietImageButton.bottomAnchor, constant: 40),
      dietContentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietContentTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단내용 텍스트뷰
      dietContentTextView.topAnchor.constraint(equalTo: dietContentTitleLabel.bottomAnchor, constant: 10),
      dietContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      dietContentTextView.heightAnchor.constraint(equalToConstant: 100),
      
      // 식단평가 제목라벨
      dietRatingTitleLabel.topAnchor.constraint(equalTo: dietContentTextView.bottomAnchor, constant: 20),
      dietRatingTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietRatingTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단평가 세그먼트
      selectDietRateSegment.topAnchor.constraint(equalTo: dietRatingTitleLabel.bottomAnchor, constant: 10),
      selectDietRateSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      selectDietRateSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      selectDietRateSegment.heightAnchor.constraint(equalToConstant: 50),
      
      // 식단 등록 버튼
      addDietButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
      addDietButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      addDietButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      addDietButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
    // textView 스크롤 비활성화
    dietContentTextView.isScrollEnabled = false

    // 식단추가버튼 처음에 비활성화
    addDietButton.isEnabled = false
  }
  
  
  // MARK: - functions
  
  
  /// delegate 및 collectionView 셀 등록
  func addDelegateAndRegisterCell(){
    dietContentTextView.delegate = self
    
    dietImageCollectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    dietImageCollectionView.register(
      DietImageCollectionViewCell.self,
      forCellWithReuseIdentifier: DietImageCollectionViewCell.cellID
    )
  }
  
  
  /// 바인딩 설정
  func setupBindings() {
    dietVM?.dietImages
      .asDriver()
      .drive(dietImageCollectionView.rx.items(
        cellIdentifier: DietImageCollectionViewCell.cellID,
        cellType: DietImageCollectionViewCell.self)) { index, content, cell in
          cell.bindImage(with: content, index: index)
          print(#fileID, #function, #line," - \(index)}")
        }
        .disposed(by: disposeBag)
  }
  
  /// 버튼 actions 등록
  func addButtonActions(){
    // 식단추가버튼 액션등록
    addDietButton.addTarget(self, action: #selector(managementDietAction), for: .touchUpInside)
    
    // 식단이미지추가버튼 액션등록
    addDietImageButton.addTarget(self, action: #selector(presentBottomSheet), for: .touchUpInside)
  }
  
  /// 노티피케이션 및 탭 재스쳐 등록
  fileprivate func registerNotifications() {

    // 키보드 보이기 전
    NotificationCenter.default.rx
      .notification(UIResponder.keyboardWillShowNotification)
      .subscribe(onNext: { notification in
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
          if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height - 40
          }
        }
      })
      .disposed(by: disposeBag)

    // 키보드 들어가기 전
    NotificationCenter.default.rx
      .notification(UIResponder.keyboardWillHideNotification)
      .subscribe(onNext: { _ in
        if self.view.frame.origin.y != 0 {
          self.view.frame.origin.y = 0
        }
      })
      .disposed(by: disposeBag)
       
    // 탭 제스쳐
    let tapBackground = UITapGestureRecognizer()
    tapBackground.rx.event
        .subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        })
        .disposed(by: disposeBag)
   
    view.addGestureRecognizer(tapBackground)
  }
  
  
  /// 화면이 사라질 때 네비게이션 바 숨기기
  /// - Parameter animated: 애니메이션 여부
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  /// 식단 종류 및 평가 선택 시
  /// - Parameter sender: UISegmentedControl
  @objc func selectSegment(sender: UISegmentedControl) {
    print(#fileID, #function, #line, " - \(sender.selectedSegmentIndex)")
    
    switch sender {
    case selectDietTypeSegment:
      selectDietTypeSegment.selectedSegmentIndex = sender.selectedSegmentIndex
    case selectDietRateSegment:
      selectDietRateSegment.selectedSegmentIndex = sender.selectedSegmentIndex
    default:
      print("알 수 없는 SegmentControl")
    }
  }
  
  /// 식단 추가 수정 action
  @objc func managementDietAction(){
    guard let navTitle: String = self.navigationItem.title,
          let popupType: PopupCase = dietVM?.getPopupCase(navTitle) else { return }
    dietVM?.steps.accept(AppStep.popupIsRequired(popupType: popupType))
    
    let dietTpye: String = DietType.fromIndex(selectDietTypeSegment.selectedSegmentIndex)
    let dietRate: String = RateTitle.fromIndex(selectDietRateSegment.selectedSegmentIndex)
    let dietContent: String = dietContentTextView.text
    let dietDate: String? = dietVM?.getConvertedDate()
    let dietImages: [UIImage] = dietVM?.dietImages.value ?? [UIImage]()
    
    
    dietVM?.managementDietData = DietManagementModel(dietTpye, dietRate, dietContent, dietDate, dietImages)
  }
  
  /// 식단 삭제
  @objc func deleteDietAction(){
    dietVM?.steps.accept(AppStep.popupIsRequired(popupType: .delete))
  }
  
  /// 편집 시 데이터 추가, 네비게이션 오른쪽 버튼 추가
  func updateEditDietScreen(data: DietEntity){
    dietContentTextView.text = data.dietContent
    dietContentTextView.textColor = .black
    
    selectDietTypeSegment.selectedSegmentIndex = DietType.fromString(data.dietType ?? "") ?? 0
    selectDietRateSegment.selectedSegmentIndex = RateTitle.fromString(data.dietRate ?? "") ?? 0
    
    let convertedImageArray: [String] = Utils.convertListToArray(wtih: data.imagesPathArray)
    print(#fileID, #function, #line," - \(convertedImageArray)")

    // 이미지 가져오기
    var imagesArray: [UIImage] = []
    convertedImageArray.forEach {
      print($0)
      imagesArray.append(DietImagesManager.loadImageFromDocumentDirectory(imageName: $0) ?? UIImage())
    }
    
    dietVM?.dietImages.accept(imagesArray)

    self.title = ManageDietVCType.editDiet.vcTitle
    addDietButton.setTitle(NSLocalizedString("PopupTitle_Edit", comment: ""), for: .normal)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(deleteDietAction))
    navigationItem.rightBarButtonItem?.tintColor = .black
  }
  
  
  /// 네비게이션 아이템 설정
  func setupNavigationItem(){
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "chevron.left"),
      style: .plain,
      target: self,
      action: #selector(backButtonTapped)
    )
    
    navigationItem.leftBarButtonItem?.tintColor = .black
  }
  
  
  /// 뒤로가기 버튼 탭
  @objc private func backButtonTapped() {
    dietVM?.steps.accept(AppStep.popIsRequired)
  }
  
  /// bottomSheet 띄우기
  @objc func presentBottomSheet(){
    dietVM?.steps.accept(AppStep.bottomSheetIsRequired)
  }
}

// MARK: - Extension

// textview 높이 동적조절

extension ManagementViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let size = CGSize(width: view.frame.width, height: .infinity)
    let estimatedSize = textView.sizeThatFits(size)
    
    textView.constraints.forEach { (constraint) in
      // 최소 높이 100, 최대 높이 150으로 제한
      if estimatedSize.height <= 100 {
        constraint.constant = 100
      } else if estimatedSize.height > 150 {
        constraint.constant = 150
        textView.isScrollEnabled = true
      } else {
        constraint.constant = estimatedSize.height
      }
    }
  }
  
  
  /// 처음 textView 입력 시작 시 placeHolder지우고 text 색상 , 테두리 색상 변경
  /// - Parameter textView: textView
  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.layer.borderColor = UIColor.black.cgColor
    
    if textView.textColor == .lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidChangeSelection(_ textView: UITextView) {
    // 텍스트가 비어있지 않은 경우 버튼 활성화
    if textView.text != NSLocalizedString("ManagementDiet_DietContent_TextView", comment: "") && textView.text != "" {
      addDietButton.isEnabled = true
      addDietButton.backgroundColor = KHColorList.mainGreen.color
    } else {
      addDietButton.isEnabled = false
      addDietButton.backgroundColor = KHColorList.mainGray.color
    }
  }
}

// 사진 촬영 후 이미지 처리
extension ManagementViewController: UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate{
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    dietVM?.steps.accept(AppStep.dismissIsRequired)

    // 임시 배열 생성
    var selectedImages: [UIImage] = []
    
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
      
      selectedImages.append(image)
      
      self.dietVM?.managementImages(with: selectedImages)
    }
  }
}

// 사진 선택 후 이미지 처리
extension ManagementViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    dietVM?.steps.accept(AppStep.dismissIsRequired)
    
    // 임시 배열 생성
    var selectedImages: [UIImage] = []
    
    // DispatchGroup 사용
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for result in results {
      // 시작
      dispatchGroup.enter()
      
      result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
        if let image = image as? UIImage {
          selectedImages.append(image)
        }
        // 종료
        dispatchGroup.leave()
      }
    }
    
    // 모든 이미지 로딩 완료 후 호출
    dispatchGroup.notify(queue: .main) {
      self.dietVM?.managementImages(with: selectedImages)
      print("저장된 이미지 개수: \(selectedImages.count)")
    
    }
  }
}


// collectionView cell의 크기
extension ManagementViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 70, height: 70)
  }
}
