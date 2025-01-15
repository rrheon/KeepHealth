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
  
  
  /// Supabase에서 모든 데이터 가져오기
  func fetchFromSupabase() async throws {
    let countries: [Country] = try await supabase
      .from("countries")
      .select()
      .execute()
      .value
    print("Countries: \(countries)")
    
  }
  
  /// Supabase에서 데이터 삽입
  func insertDataFromSupabase() async throws {
    try await supabase
      .from("countries")
      .insert(["name": "Canada"])
      .execute()
  }
  
  /// Supabase에서 데이터 편집
  func editDataFromSupabase() async throws {
    try await supabase
      .from("countries")
      .update(["name": "Canad"]) // 이걸로 변환
      .eq("id", value: 5) // id가 5랑 같으면
      .execute()
  }
  
  /// Supabase에서 데이터 삭제
  func deleteDataFromSupabase() async throws {
    try await supabase
      .from("countries")
      .delete()
      .eq("id", value: 1)
      .execute()
  }
}
