//
//  ScoreViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxFlow
import RxRelay

/// 점수 VC
class ScoreViewController: UIViewController, Stepper {
  var steps: PublishRelay<Step> = PublishRelay()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "점수"
    self.view.backgroundColor = .yellow
  

  }// viewDidLoad

  
  
}
