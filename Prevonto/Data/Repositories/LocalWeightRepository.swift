//
//  LocalWeightRepository.swift
//  Prevonto
//
//  Created by Yehjune Heo on 9/26/25.
//


import Foundation

class LocalWeightRepository: WeightRepository {
    private let key = "weight_entries"
    private var entries: [WeightEntry] = []

    init() {
        load()
    }

    func fetchEntries() -> [WeightEntry] {
        entries
    }

    func addEntry(weight: Double) {
        let newEntry = WeightEntry(date: Date(), weightLb: weight)
        entries.insert(newEntry, at: 0)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            entries = saved
        }
    }
}
