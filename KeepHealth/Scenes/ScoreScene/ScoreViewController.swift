//
//  ScoreViewController.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/7/25.
//

import UIKit

import RxSwift
import RxFlow
import RxRelay
import DGCharts
import SnapKit
import Then

/// 점수 VC
class ScoreViewController: UIViewController {
  var dietVM: DietViewModel? = nil
  
  let disposeBag = DisposeBag()
  
  /// 차트
  private var myPieChart = PieChartView(frame: .zero)
  
  /// 점수라벨
  private lazy var scoreLabel = UILabel().then {
    $0.numberOfLines = 2
    $0.textAlignment = .center
    $0.textColor = .black
    $0.font = .boldSystemFont(ofSize: 24)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "점수"
    self.view.backgroundColor = KHColorList.backgroundGray.color
    
    setupLayout()
    setupBinding()
    
  } // viewDidLoad
  
  
  /// layout 설정
  private func setupLayout() {
    // 차트
    view.addSubview(myPieChart)
    myPieChart.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.size.equalTo(300)
    }
    
    // 점수
    view.addSubview(scoreLabel)
    scoreLabel.snp.makeConstraints {
      $0.centerX.equalTo(myPieChart.snp.centerX)
      $0.centerY.equalTo(myPieChart.snp.centerY).offset(-20)
    }
  }
  
  
  /// 바인딩 설정
  func setupBinding(){
    // 파이차트 바인딩
    dietVM?.chartCount
      .asDriver()
      .drive(onNext: { [weak self] chartCount in
        self?.updatePieChart(with: chartCount)
      })
      .disposed(by: disposeBag)
    
    // 식단 점수 바인딩
    dietVM?.chartRate
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] rate in
        guard let _rate = rate else { return }
        self?.dietVM?.updateDietScore(_rate)
      })
      .disposed(by: disposeBag)
    
    // 식단 점수 UI
    dietVM?.totalDietScore
      .asDriver(onErrorJustReturn: 0)
      .drive(onNext: { [weak self] score in
        guard let _score = score else { return }
        self?.scoreLabel.text = "식단 점수\n\(_score)"
      })
      .disposed(by: disposeBag)
  }
  
  
  /// 차트 업데이트
  /// - Parameter chartCount: 차트 데이터  갯수
  private func updatePieChart(with chartCount: [Double]) {
    guard let dietVM = dietVM else { return }
    
    let pieChartDataEntries = zip(dietVM.chartLabel, chartCount).map { label, count in
      PieChartDataEntry(value: count, label: label)
    }
    
    let pieChartDataSet = PieChartDataSet(entries: pieChartDataEntries, label: "")
    pieChartDataSet.colors = [KHColorList.mainGreen.color,
                              KHColorList.mainGray.color,
                              KHColorList.mainRed.color]
    pieChartDataSet.valueTextColor = .black
    pieChartDataSet.valueFormatter = self
    
    let pieChartData = PieChartData(dataSet: pieChartDataSet)
    myPieChart.data = pieChartData
    
    // 차트 갱신해주기
    myPieChart.notifyDataSetChanged()
    
    // 차트 밑에 평가항목 나타내기
    myPieChart.legend.enabled = true
    myPieChart.legend.orientation = .horizontal
    myPieChart.legend.verticalAlignment = .bottom
    myPieChart.legend.horizontalAlignment = .center
    myPieChart.legend.form = .circle
    myPieChart.legend.textColor = .black
    myPieChart.legend.font = .systemFont(ofSize: 14)
  }
}

// MARK: - extension

extension ScoreViewController: ValueFormatter {
  
  /// 차트에 들어갈 값 Int 로 변환
  /// - Parameters:
  ///   - value: 차트에 들어갈 값
  ///   - entry: ChartDataEntry
  ///   - dataSetIndex: dataSetIndex
  ///   - viewPortHandler: viewPortHandler
  /// - Returns: Int
  func stringForValue(_ value: Double,
                      entry: DGCharts.ChartDataEntry,
                      dataSetIndex: Int,
                      viewPortHandler: DGCharts.ViewPortHandler?) -> String {
    return "\(Int(value))"
  }
}
