//
//  SupabaseManager.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/15/25.
//

import Foundation

import Supabase


/// Supabase CRUD 작업
class SupabaseManager {
  static let shared = SupabaseManager()
  
  
  /// supabase에 접근할 데이터
  var dietEntity: DietEntityToServer? = nil
  
  /// 서버랑 접근하는 유형
  var contactType: ContactToServerCaes? = nil
  
  
  /// Supabase에서 모든 데이터 가져오기
  func fetchFromSupabase() async throws {
    let diets: [DietEntityToServer] = try await supabase
      .from("diets")
      .select()
      .execute()
      .value
    
  }
  
  /// Supabase에 데이터  추가
  func createDataFromSupabase() async throws {
    guard let _dietEntity = dietEntity else { return }
    
    try await supabase
      .from("diets")
      .insert(_dietEntity)
      .execute()
  }
  
  /// Supabase에서 데이터 편집
  func editDataFromSupabase() async throws {
    guard let _dietEntity = dietEntity else { return }

    try await supabase
      .from("diets")
      .update(_dietEntity)
      .eq("dietID", value: _dietEntity.dietID)
      .execute()
  }
  
  /// Supabase에서 데이터 삭제
  func deleteDataFromSupabase() async throws {
    guard let _dietEntity = dietEntity?.dietID else { return }
    try await supabase
      .from("diets")
      .delete()
      .eq("dietID", value: _dietEntity)
      .execute()
  }
  
  
  /// supabase 함수 리턴해주기
  /// - Returns: CRUD 함수
  func selectSupabaseAction()-> () async throws -> (){
    switch contactType {
    case .create:
      return createDataFromSupabase
    case .edit:
      return editDataFromSupabase
    case .delete:
      return deleteDataFromSupabase
    case .none:
      return fetchFromSupabase
    }
  }
}
