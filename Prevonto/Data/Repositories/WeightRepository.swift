//
//  WeightRepository.swift
//  Prevonto
//
//  Created by Yehjune Heo on 9/26/25.
//


import Foundation

protocol WeightRepository {
    func fetchEntries() -> [WeightEntry]
    func addEntry(weight: Double)
}
