// Metric Models for API
import Foundation

// MARK: - Metric Type Enum
enum MetricType: String, Codable {
    case bloodPressure = "blood_pressure"
    case heartRate = "heart_rate"
    case bloodGlucose = "blood_glucose"
    case spo2 = "spo2"
    case medication = "medication"
    case energyMood = "energy_mood"
    case stepsActivity = "steps_activity"
    case daysTracked = "days_tracked"
    case weight = "weight"
}

// MARK: - Data Source Enum
enum DataSource: String, Codable {
    case manual = "manual"
    case healthkit = "healthkit"
    case `import` = "import"
}

// MARK: - Metric Value Types
struct BloodPressureValue: Codable {
    let systolic: Int
    let diastolic: Int
    let pulse: Int?
}

struct HeartRateValue: Codable {
    let bpm: Int
}

struct BloodGlucoseValue: Codable {
    let value: Double
}

struct SpO2Value: Codable {
    let value: Double
}

struct MedicationValue: Codable {
    let name: String
    let dosage: String
    let timeTaken: Date?
    
    enum CodingKeys: String, CodingKey {
        case name
        case dosage
        case timeTaken = "time_taken"
    }
}

struct EnergyMoodValue: Codable {
    let energy: Int
    let mood: Int
}

struct StepsActivityValue: Codable {
    let steps: Int
    let distance: Double?
    let activeMinutes: Int?
    
    enum CodingKeys: String, CodingKey {
        case steps
        case distance
        case activeMinutes = "active_minutes"
    }
}

struct WeightValue: Codable {
    let weight: Double
}

// MARK: - Metric Response
struct MetricResponse: Codable, Identifiable {
    let id: Int
    let userId: Int
    let metricType: MetricType
    let source: DataSource
    let measuredAt: Date
    let value: [String: AnyCodable]
    let unit: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case metricType = "metric_type"
        case source
        case measuredAt = "measured_at"
        case value
        case unit
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Metric List Response
struct MetricListResponse: Codable {
    let metrics: [MetricResponse]
    let total: Int
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case metrics
        case total
        case page
        case pageSize = "page_size"
    }
}

// MARK: - Metric Create Request
struct MetricCreateRequest: Encodable {
    let metricType: MetricType
    let measuredAt: Date
    let value: [String: AnyCodable]
    let unit: String?
    let notes: String?
    let source: DataSource
    let healthkitUuid: String?
    
    enum CodingKeys: String, CodingKey {
        case metricType = "metric_type"
        case measuredAt = "measured_at"
        case value
        case unit
        case notes
        case source
        case healthkitUuid = "healthkit_uuid"
    }
}

// MARK: - Metric Update Request
struct MetricUpdateRequest: Encodable {
    let measuredAt: Date?
    let value: [String: AnyCodable]?
    let unit: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case measuredAt = "measured_at"
        case value
        case unit
        case notes
    }
}

// MARK: - AnyCodable Helper (for dynamic JSON values)
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let date as Date:
            // Encode dates as ISO8601 strings
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date))
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded: \(type(of: value))"
                )
            )
        }
    }
}

// MARK: - Helper Extensions for Converting Values
extension MetricResponse {
    // Extract typed values from AnyCodable dictionary
    func extractBloodPressure() -> BloodPressureValue? {
        guard metricType == .bloodPressure,
              let systolic = value["systolic"]?.value as? Int,
              let diastolic = value["diastolic"]?.value as? Int else {
            return nil
        }
        let pulse = value["pulse"]?.value as? Int
        return BloodPressureValue(systolic: systolic, diastolic: diastolic, pulse: pulse)
    }
    
    func extractHeartRate() -> HeartRateValue? {
        guard metricType == .heartRate,
              let bpm = value["bpm"]?.value as? Int else {
            return nil
        }
        return HeartRateValue(bpm: bpm)
    }
    
    func extractBloodGlucose() -> BloodGlucoseValue? {
        guard metricType == .bloodGlucose,
              let val = value["value"]?.value as? Double else {
            return nil
        }
        return BloodGlucoseValue(value: val)
    }
    
    func extractSpO2() -> SpO2Value? {
        guard metricType == .spo2,
              let val = value["value"]?.value as? Double else {
            return nil
        }
        return SpO2Value(value: val)
    }
    
    func extractMedication() -> MedicationValue? {
        guard metricType == .medication,
              let name = value["name"]?.value as? String,
              let dosage = value["dosage"]?.value as? String else {
            return nil
        }
        var timeTaken: Date? = nil
        if let timeStr = value["time_taken"]?.value as? String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            timeTaken = formatter.date(from: timeStr)
        }
        return MedicationValue(name: name, dosage: dosage, timeTaken: timeTaken)
    }
    
    func extractEnergyMood() -> EnergyMoodValue? {
        guard metricType == .energyMood,
              let energy = value["energy"]?.value as? Int,
              let mood = value["mood"]?.value as? Int else {
            return nil
        }
        return EnergyMoodValue(energy: energy, mood: mood)
    }
    
    func extractStepsActivity() -> StepsActivityValue? {
        guard metricType == .stepsActivity,
              let steps = value["steps"]?.value as? Int else {
            return nil
        }
        let distance = value["distance"]?.value as? Double
        let activeMinutes = value["active_minutes"]?.value as? Int
        return StepsActivityValue(steps: steps, distance: distance, activeMinutes: activeMinutes)
    }
    
    func extractWeight() -> WeightValue? {
        guard metricType == .weight,
              let weight = value["weight"]?.value as? Double else {
            return nil
        }
        return WeightValue(weight: weight)
    }
}

// MARK: - Helper Functions for Creating Metric Requests
extension MetricCreateRequest {
    // Creating Blood Pressure requests
    static func bloodPressure(systolic: Int, diastolic: Int, pulse: Int?, measuredAt: Date, unit: String? = "mmHg", notes: String? = nil) -> MetricCreateRequest {
        var value: [String: AnyCodable] = [
            "systolic": AnyCodable(systolic),
            "diastolic": AnyCodable(diastolic)
        ]
        if let pulse = pulse {
            value["pulse"] = AnyCodable(pulse)
        }
        return MetricCreateRequest(
            metricType: .bloodPressure,
            measuredAt: measuredAt,
            value: value,
            unit: unit,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating Heart Rate requests
    static func heartRate(bpm: Int, measuredAt: Date, unit: String? = "bpm", notes: String? = nil) -> MetricCreateRequest {
        return MetricCreateRequest(
            metricType: .heartRate,
            measuredAt: measuredAt,
            value: ["bpm": AnyCodable(bpm)],
            unit: unit,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating Blood Glucose requests
    static func bloodGlucose(value: Double, measuredAt: Date, unit: String? = "mg/dL", notes: String? = nil) -> MetricCreateRequest {
        return MetricCreateRequest(
            metricType: .bloodGlucose,
            measuredAt: measuredAt,
            value: ["value": AnyCodable(value)],
            unit: unit,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating SpO2 requests
    static func spo2(value: Double, measuredAt: Date, unit: String? = "%", notes: String? = nil) -> MetricCreateRequest {
        return MetricCreateRequest(
            metricType: .spo2,
            measuredAt: measuredAt,
            value: ["value": AnyCodable(value)],
            unit: unit,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating Medication Requests
    static func medication(name: String, dosage: String, timeTaken: Date?, measuredAt: Date, notes: String? = nil) -> MetricCreateRequest {
        var value: [String: AnyCodable] = [
            "name": AnyCodable(name),
            "dosage": AnyCodable(dosage)
        ]
        if let timeTaken = timeTaken {
            value["time_taken"] = AnyCodable(timeTaken)
        }
        return MetricCreateRequest(
            metricType: .medication,
            measuredAt: measuredAt,
            value: value,
            unit: nil,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating mood and energy requests
    static func energyMood(energy: Int, mood: Int, measuredAt: Date, notes: String? = nil) -> MetricCreateRequest {
        return MetricCreateRequest(
            metricType: .energyMood,
            measuredAt: measuredAt,
            value: [
                "energy": AnyCodable(energy),
                "mood": AnyCodable(mood)
            ],
            unit: nil,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating steps activity request
    static func stepsActivity(steps: Int, distance: Double? = nil, activeMinutes: Int? = nil, measuredAt: Date, notes: String? = nil) -> MetricCreateRequest {
        var value: [String: AnyCodable] = ["steps": AnyCodable(steps)]
        if let distance = distance {
            value["distance"] = AnyCodable(distance)
        }
        if let activeMinutes = activeMinutes {
            value["active_minutes"] = AnyCodable(activeMinutes)
        }
        return MetricCreateRequest(
            metricType: .stepsActivity,
            measuredAt: measuredAt,
            value: value,
            unit: nil,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
    
    // Creating weights request
    static func weight(weight: Double, measuredAt: Date, unit: String? = "kg", notes: String? = nil) -> MetricCreateRequest {
        return MetricCreateRequest(
            metricType: .weight,
            measuredAt: measuredAt,
            value: ["weight": AnyCodable(weight)],
            unit: unit,
            notes: notes,
            source: .manual,
            healthkitUuid: nil
        )
    }
}

