//
//  AddDietScene.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxRelay
import Then


/// 식단 페이지 종류
enum ManageDietVCType {
  case add
  case edit
  
  var vcTitle: String {
    switch self {
    case .add:  return "식단 추가"
    case .edit: return "식단 수정"
    }
  }
}

/// 식단 관리 VC
class MangementDietViewController: UIViewController {
  var dietVM: DietViewModel? = nil
  
  private lazy var selectDietTypeSegment: UISegmentedControl = {
    let control = UISegmentedControl(items: [DietType.morning.rawValue,
                                             DietType.lunch.rawValue,
                                             DietType.dinner.rawValue])
    control.layer.cornerRadius = 30
    control.selectedSegmentIndex = 0
    control.addTarget(self, action: #selector(selectSegment(sender: )), for: .valueChanged)
    return control
  }()
  
  private lazy var dietImageTitleLabel = UILabel().then {
    $0.text = "식단사진 추가하기"
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  /// 식단 추가 버튼
  private lazy var addDietImageButton = UIButton().then {
    $0.setTitle("+", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 10
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
  }
  
  private lazy var dietContentTitleLabel = UILabel().then {
    $0.text = "식단내용"
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  private lazy var dietContentTextView = UITextView().then {
    $0.text = "식단을 입력해주세요."
    $0.textColor = .lightGray
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1.0
    $0.layer.cornerRadius = 10
  }
  
  private lazy var dietRatingTitleLabel = UILabel().then {
    $0.text = "식단 평가하기"
    $0.font = .boldSystemFont(ofSize: 18)
    $0.textColor = .black
  }
  
  private lazy var selectDietRateSegment: UISegmentedControl = {
    let control = UISegmentedControl(items: ["Good", "Normal", "Bad"])
    control.layer.cornerRadius = 30
    control.selectedSegmentIndex = 0
    return control
  }()
  
  private lazy var addDietButton = UIButton.makeKFMainButton(buttonTitle: "식단 추가하기",
                                                             backgroundColor: KHColorList.mainGray.color)

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.isHidden = false
    self.title = ManageDietVCType.add.vcTitle
    self.view.backgroundColor = KHColorList.backgroundGray.color
    
    setupLayout()

    registerNotifications()
    
    dietContentTextView.delegate = self
    dietContentTextView.isScrollEnabled = false
    
    addDietButton.addTarget(self, action: #selector(managementDietAction), for: .touchUpInside)
    addDietButton.isEnabled = false
    
    addDietImageButton.addTarget(self, action: #selector(presentBottomSheet), for: .touchUpInside)
    
    setupNavigationItem()
    
    // 개별 데이터가 있으면 편집
    if let data: DietEntity = dietVM?.dietData {
      updateEditDietScreen(data: data)
    }
  }// viewDidLoad
  
  // 노티피케이션 해제
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  
  /// layout 설정
  func setupLayout(){
    [
      selectDietTypeSegment,
      dietImageTitleLabel,
      addDietImageButton,
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
      selectDietTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      selectDietTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      selectDietTypeSegment.heightAnchor.constraint(equalToConstant: 50),
      
      // 식단이미지 제목 라벨
      dietImageTitleLabel.topAnchor.constraint(equalTo: selectDietTypeSegment.bottomAnchor, constant: 20),
      dietImageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietImageTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단이미지 추가 버튼
      addDietImageButton.topAnchor.constraint(equalTo: dietImageTitleLabel.bottomAnchor, constant: 20),
      addDietImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      addDietImageButton.heightAnchor.constraint(equalToConstant: 42),
      addDietImageButton.widthAnchor.constraint(equalToConstant: 42),
      
      // 식단내용 제목 라벨
      dietContentTitleLabel.topAnchor.constraint(equalTo: addDietImageButton.bottomAnchor, constant: 40),
      dietContentTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietContentTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단내용 텍스트뷰
      dietContentTextView.topAnchor.constraint(equalTo: dietContentTitleLabel.bottomAnchor, constant: 10),
      dietContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      dietContentTextView.heightAnchor.constraint(equalToConstant: 50),
      
      // 식단평가 제목라벨
      dietRatingTitleLabel.topAnchor.constraint(equalTo: dietContentTextView.bottomAnchor, constant: 20),
      dietRatingTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      dietRatingTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
      
      // 식단평가 세그먼트
      selectDietRateSegment.topAnchor.constraint(equalTo: dietRatingTitleLabel.bottomAnchor, constant: 10),
      selectDietRateSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      selectDietRateSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      selectDietRateSegment.heightAnchor.constraint(equalToConstant: 50),
      
      addDietButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
      addDietButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      addDietButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      addDietButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  
  // MARK: - functions
  
  /// 노티피케이션 및 탭 재스쳐 등록
  fileprivate func registerNotifications() {
    // 키보드 보이기 전
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    
    // 키보드 들어가기 전
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
    
    // 탭 제스쳐
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  /// 키보드 올라갈 때 높이 조절
  /// - Parameter notification:notification
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= keyboardSize.height - 40
      }
    }
  }
  
  /// 키보드 내려갈 때 높이 조절
  /// - Parameter notification: notification
  @objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y = 0
    }
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
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
    guard let popupType: PopupCase = dietVM?.getPopupCase(self.title ?? "") else { return }
    dietVM?.steps.accept(AppStep.popupIsRequired(popupType: popupType))
    
    let dietTpye: String = DietType.fromIndex(selectDietTypeSegment.selectedSegmentIndex)
    let dietRate: String = RateTitle.fromIndex(selectDietRateSegment.selectedSegmentIndex)
    let dietContent: String = dietContentTextView.text
    let dietDate: String? = dietVM?.getConvertedDate()
    
    dietVM?.managementDietData = DietManagementModel(dietTpye, dietRate, dietContent, dietDate, nil)
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
    
    self.title = ManageDietVCType.edit.vcTitle
    addDietButton.setTitle("식단 수정하기", for: .normal)
    
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

extension MangementDietViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let size = CGSize(width: view.frame.width, height: .infinity)
    let estimatedSize = textView.sizeThatFits(size)
    
    textView.constraints.forEach { (constraint) in
      // 최소 높이 50, 최대 높이 100으로 제한
      if estimatedSize.height <= 50 {
        constraint.constant = 50
      } else if estimatedSize.height > 100 {
        constraint.constant = 100
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
    if textView.text != "식단을 입력해주세요." && textView.text != "" {
      addDietButton.isEnabled = true
      addDietButton.backgroundColor = KHColorList.mainGreen.color
    } else {
      addDietButton.isEnabled = false
      addDietButton.backgroundColor = KHColorList.mainGray.color
    }
  }
}

extension MangementDietViewController: UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate{
  
}
