//
//  Supabase.swift
//  KeepHealth
//
//  Created by 최용헌 on 1/15/25.
//

import Foundation

import Supabase


/// supabase 서버에 접근하는 경우
enum ContactToServerCaes {
  case create
  case edit
  case delete
}

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://tctyzrteaenluditpopu.supabase.co")!,
  supabaseKey: Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? ""
)
