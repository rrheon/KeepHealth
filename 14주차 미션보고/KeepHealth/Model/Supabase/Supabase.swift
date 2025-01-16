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
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjdHl6cnRlYWVubHVkaXRwb3B1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5MjA3ODYsImV4cCI6MjA1MjQ5Njc4Nn0.AbdwFtHaY2A5f-ajpdFbr1CwbqAqjDtGBuupo94tw3Y"
)
