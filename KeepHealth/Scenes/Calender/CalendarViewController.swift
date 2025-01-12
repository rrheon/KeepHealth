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

/// Calendar
class CalendarViewController: UIViewController {
  
  /// 달력
  private var calendar: FSCalendar? = nil
  
  /// floating panel
  private var fpc: FloatingPanelController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.calendar = FSCalendar(frame: .zero)
//    
//    self.fpc = FloatingPanelController()
//    
//    // 보여줄 vc 셋팅
//    self.fpc?.set(contentViewController: self)
//    self.fpc?.addPanel(toParent: self)
//    
    setupLayout()
    
  } // viewDidLoad
  
  
  /// UI 설정
  func setupLayout(){
    guard let _calendar = calendar else { return }
    view.addSubview(_calendar)
    _calendar.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
