//
//  CalendarViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/11/25.
//

import UIKit

import FSCalendar
import SnapKit
import FloatingPanel
import Then

/// 캘린더 레이아웃
class CalendarPanelLayout: FloatingPanelLayout {
  
  /// 패널 위치
  var position: FloatingPanelPosition {
    return .bottom
  }
  
  
  /// 패널 표시방법
  var initialState: FloatingPanelState {
    return .half
  }
  
  
  /// 패널 크기설정
  var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
    return [
      .half: FloatingPanelLayoutAnchor(absoluteInset: 300, edge: .bottom,
                                       referenceGuide: .safeArea)
    ]
  }
}

/// Calendar
class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
  
  /// 달력
  private var calendar: FSCalendar?
  
  /// 달력에서 선택한 날짜
  private var selectDate: String?
  
  /// 이전 버튼
  private lazy var previousMonthButton = UIButton().then {
    $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    $0.tintColor = .black
  }
  
  
  /// 오른쪽 버튼
  private lazy var nextMonthButton = UIButton().then {
    $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    $0.tintColor = .black
  }
  
  
  /// 선택완료 버튼
  private lazy var selectionCompleteButton = UIButton().then {
    $0.setTitle("완료", for: .normal)
    $0.setTitleColor(KHColorList.mainGreen.color, for: .normal)
    $0.addTarget(self, action: #selector(onCompleteBtnTapped), for: .touchUpInside)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    
    // FSCalendar 초기화 및 설정
    self.calendar = FSCalendar(frame: .zero)
    
    setupCalendar()
    setupLayout()
  }
  
  /// UI 설정
  func setupLayout() {
    guard let calendar = calendar else { return }
    
    // 캘린더
    view.addSubview(calendar)
    calendar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(250)
    }
    
    // 이전 달 이동 버튼
    view.addSubview(previousMonthButton)
    previousMonthButton.snp.makeConstraints {
      $0.top.equalTo(calendar.snp.top).offset(10)
      $0.leading.equalTo(calendar.calendarHeaderView.snp.leading).offset(80)
    }
    
    // 다음 달 이동 버튼
    view.addSubview(nextMonthButton)
    nextMonthButton.snp.makeConstraints {
      $0.top.equalTo(previousMonthButton.snp.top)
      $0.trailing.equalTo(calendar.calendarHeaderView.snp.trailing).offset(-80)
    }
    
    // 선택완료버튼
    view.addSubview(selectionCompleteButton)
    selectionCompleteButton.snp.makeConstraints {
      $0.centerY.equalTo(nextMonthButton.snp.centerY)
      $0.trailing.equalTo(calendar.calendarHeaderView.snp.trailing).offset(-10)
    }
  }
  
  /// 캘린더 설정
  func setupCalendar(){
    guard let calendar = calendar else { return }
    
    // 델리게이트와 데이터소스 설정
    calendar.delegate = self
    calendar.dataSource = self
    
    // 달력 외형 커스터마이징 (옵션)
    
    // 상단 날짜 형식
    calendar.appearance.headerDateFormat = "MMMM yyyy"
    // 상단 제목 색상
    calendar.appearance.headerTitleColor = .black
    // 주간타이틀 색상
    calendar.appearance.weekdayTextColor = .lightGray
    // 선택된날짜 색상
    calendar.appearance.selectionColor = KHColorList.mainGreen.color
    // 오늘 날짜 배경색
    calendar.appearance.todayColor = KHColorList.mainGreen.color
    // 오늘 날짜 타이틀 색상
    calendar.appearance.titleTodayColor = .white
    calendar.appearance.borderRadius = 10
    
    // 이전 달, 다음 달 표시 x
    calendar.appearance.headerMinimumDissolvedAlpha = 0
  }
  
  
  /// 날짜 선택 시 액션
  /// - Parameters:
  ///   - calendar: 캘린더
  ///   - date: 선택된 날짜
  ///   - monthPosition: 월
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    let selectedDate: String = DietViewModel.shared.getConvertedDate(date: date)
    print("선택한 날짜: \(selectedDate)")
    
    selectDate = selectedDate
    
    calendar.appearance.todayColor = .clear
    calendar.appearance.titleTodayColor = .black
  }
  
  
  /// 완료버튼 액션 / 캘린더 닫고 선택한 날짜로 식단 목록 변경
  @objc func onCompleteBtnTapped(){
    guard let selectedDate = selectDate else { return }
    
    DietViewModel.shared.selectedDate.accept(selectedDate)
    DietViewModel.shared.steps.accept(DietStep.dismissIsRequired)
  }
}

