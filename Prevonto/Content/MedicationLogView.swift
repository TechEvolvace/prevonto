// Medication Log page allows user to track their medication intake by day or week
import SwiftUI

// Properties of Medication Log data
struct MedicationEntry {
    let id: UUID
    let metricId: Int? // nil means "not taken" (no API record)
    let medicationName: String
    let instructions: String
    let scheduledTime: Date
    var status: MedicationStatus?
}

enum MedicationStatus {
    case taken
    case skipped
}

struct MedicationLogView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Default view mode selected is Daily View
    @State private var selectedMode: MedicationViewMode = .daily
    // Specify what date the user selected
    @State private var selectedDate: Date = Date()
    // Week mode start and end date pickers
    @State private var showingStartDatePicker: Bool = false
    @State private var showingEndDatePicker: Bool = false
    @State private var weekStartDate: Date = Date()
    @State private var weekEndDate: Date = Date()
    
    // Medication entries from API
    @State private var medicationEntries: [MedicationEntry] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let metricsService = MetricsService.shared
    private let onboardingService = OnboardingService.shared
    
    // Filtered entries for the selected day
    private var dayEntries: [MedicationEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return medicationEntries
            .filter { entry in
                entry.scheduledTime >= startOfDay && entry.scheduledTime < endOfDay
            }
            .sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    // Entries grouped by day for the selected weeks
    private var weekEntriesByDay: [(date: Date, entries: [MedicationEntry])] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: weekEndDate)!)
        
        var result: [(date: Date, entries: [MedicationEntry])] = []
        var currentDate = startOfWeek
        
        while currentDate < endOfWeek {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayEntries = medicationEntries
                .filter { entry in
                    entry.scheduledTime >= dayStart && entry.scheduledTime < dayEnd
                }
                .sorted { $0.scheduledTime < $1.scheduledTime }
            
            result.append((date: currentDate, entries: dayEntries))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    // Calculate weekly completion percentage
    private var weeklyCompletionPercentage: Int {
        let weekEntries = weekEntriesByDay.flatMap { $0.entries }
        guard !weekEntries.isEmpty else { return 0 }
        
        let takenCount = weekEntries.filter { $0.status == .taken }.count
        return Int((Double(takenCount) / Double(weekEntries.count)) * 100)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Header Section
                    headerSection
                    
                    // View Mode Toggle Buttons
                    viewModeToggle
                    
                    // Calendar Navigation
                    calendarSection
                    
                    // Content based on selected mode
                    if selectedMode == .daily {
                        dailyViewContent
                    } else {
                        weeklyViewContent
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color.white)
        }
        .onAppear {
            updateWeekDates()
            loadMedicationData()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - API Integration
    private func loadMedicationData() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                // Get medications from onboarding
                let onboarding = try await onboardingService.getOnboarding()
                let onboardingMedications = onboarding.medications ?? []
                
                // Fetch medication logs from API
                let calendar = Calendar.current
                let endDate = calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
                let startDate = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                
                let response = try await metricsService.listMetrics(
                    metricType: .medication,
                    startDate: startDate,
                    endDate: endDate,
                    pageSize: 100
                )
                
                // Map taken logs from API by (name + scheduled slot components).
                // We treat existence of a metric record as "taken".
                func slotKey(name: String, scheduledTime: Date) -> String {
                    let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTime)
                    let y = comps.year ?? 0
                    let m = comps.month ?? 0
                    let d = comps.day ?? 0
                    let h = comps.hour ?? 0
                    let min = comps.minute ?? 0
                    return "\(name.lowercased())|\(y)-\(m)-\(d)|\(h):\(min)"
                }
                
                var takenByKey: [String: Int] = [:] // key -> metricId
                for metric in response.metrics {
                    guard let med = metric.extractMedication() else { continue }
                    takenByKey[slotKey(name: med.name, scheduledTime: metric.measuredAt)] = metric.id
                }
                
                // Build scheduled slots locally (9AM + 3PM each day) for onboarding medications,
                // then overlay taken status based on the API records.
                let scheduledHours = [9, 15]
                var entries: [MedicationEntry] = []
                
                guard !onboardingMedications.isEmpty else {
                    await MainActor.run {
                        medicationEntries = []
                        isLoading = false
                    }
                    return
                }
                
                var day = calendar.startOfDay(for: startDate)
                let endDay = calendar.startOfDay(for: endDate)
                
                while day <= endDay {
                    for hour in scheduledHours {
                        guard let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }
                        for med in onboardingMedications {
                            let metricId = takenByKey[slotKey(name: med.name, scheduledTime: scheduledTime)]
                            
                            let status: MedicationStatus?
                            if metricId != nil {
                                status = .taken
                            } else {
                                // If there's no API record for this scheduled slot, treat it as skipped.
                                // This makes "Skipped" selectable even for future slots.
                                status = .skipped
                            }
                            
                            entries.append(MedicationEntry(
                                id: UUID(),
                                metricId: metricId,
                                medicationName: med.name,
                                instructions: "Instructions for intake",
                                scheduledTime: scheduledTime,
                                status: status
                            ))
                        }
                    }
                    day = calendar.date(byAdding: .day, value: 1, to: day) ?? day
                }
                
                await MainActor.run {
                    medicationEntries = entries.sorted { $0.scheduledTime < $1.scheduledTime }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func markMedicationAsTaken(_ entry: MedicationEntry) {
        guard !isSaving else { return }
        isSaving = true
        
        Task {
            do {
                // POST a medication metric to indicate "taken" for this scheduled slot.
                // If it already exists, do nothing.
                if entry.metricId != nil {
                    await MainActor.run { isSaving = false }
                    return
                }
                
                let request = MetricCreateRequest.medication(
                    name: entry.medicationName,
                    dosage: "1 tablet", // Default dosage
                    timeTaken: Date(),
                    measuredAt: entry.scheduledTime
                )
                
                _ = try await metricsService.createMetric(request)
                
                // Reload data
                loadMedicationData()
                
                await MainActor.run {
                    isSaving = false
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func markMedicationAsSkipped(_ entry: MedicationEntry) {
        // DELETE the medication metric (if it exists) to indicate "not taken" for this scheduled slot.
        guard !isSaving else { return }
        isSaving = true
        
        Task {
            do {
                if let metricId = entry.metricId {
                    try await metricsService.deleteMetric(metricType: .medication, metricId: metricId)
                }
                loadMedicationData()
                await MainActor.run { isSaving = false }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Medication Log")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.primaryGreen)
            
            Text("Track your medicine")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
    }
    
    // MARK: - View Mode Toggle
    private var viewModeToggle: some View {
        HStack(spacing: 8) {
            toggleButton(title: "Daily View", mode: .daily)
            toggleButton(title: "Weekly View", mode: .weekly)
        }
        .padding(.bottom, 10)
    }
    
    private func toggleButton(title: String, mode: MedicationViewMode) -> some View {
        Button(action: {
            selectedMode = mode
            if mode == .weekly {
                updateWeekDates()
            }
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(selectedMode == mode ? .white : .gray)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(selectedMode == mode ? Color.secondaryGreen : .white)
                .cornerRadius(8)
                .shadow(color: selectedMode == mode ? .clear : Color.neutralShadow, radius: 4, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(spacing: 12) {
            // Month navigation buttons
            monthNavigationButtons
            
            // Mode-specific date selectors
            if selectedMode == .daily {
                daySelector
                    .padding(.bottom, 16)
            } else {
                weekSelector
                    .padding(.bottom, 16)
            }
        }
    }
    
    private var monthNavigationButtons: some View {
        HStack {
            Button(action: {
                navigateMonth(forward: false)
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
            
            Spacer()
            
            Text(monthYearText)
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.darkGrayText)
            
            Spacer()
            
            Button(action: {
                navigateMonth(forward: true)
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
    }
    
    // MARK: - Day Selector
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(daysInCurrentMonth, id: \.self) { date in
                    dayButton(for: date)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func dayButton(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
        
        // Check medications for this day and their status
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        let dayMedications = medicationEntries.filter { entry in
            entry.scheduledTime >= dayStart && entry.scheduledTime < dayEnd
        }
        let hasMedications = !dayMedications.isEmpty
        
        // Check if all medications for this day are taken
        let allTaken = hasMedications && dayMedications.allSatisfy { $0.status == .taken }
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text(weekdaySymbol)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .darkGrayText)
                
                Text("\(day)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primaryGreen)
            }
            .frame(width: 50, height: 60)
            .background(isSelected ? Color.secondaryGreen : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.tintedShadow, radius: 2, x: 0, y: 1)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.15)
            }
            .overlay(alignment: .topTrailing) {
                if hasMedications && !isSelected {
                    Circle()
                        .fill(allTaken ? Color.secondaryGreen : Color.missingColor)
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: 4)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var daysInCurrentMonth: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let dayRange = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return []
        }
        
        return dayRange.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: monthInterval.start)
        }
    }
    
    // MARK: - Week Selector
    private var weekSelector: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                weekDateButton(
                    title: "start date",
                    date: weekStartDate,
                    isShowing: showingStartDatePicker,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showingStartDatePicker.toggle()
                            if showingStartDatePicker {
                                showingEndDatePicker = false
                            }
                        }
                    }
                )
                
                Text("to")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(.darkGrayText)
                
                weekDateButton(
                    title: "end date",
                    date: weekEndDate,
                    isShowing: showingEndDatePicker,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showingEndDatePicker.toggle()
                            if showingEndDatePicker {
                                showingStartDatePicker = false
                            }
                        }
                    }
                )
            }
            .padding(.horizontal, 16)
            
            if showingStartDatePicker {
                weekDatePickerView(for: $weekStartDate, isStartDate: true)
                    .background(
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                dismissStartDatePicker()
                            }
                    )
            }
            
            if showingEndDatePicker {
                weekDatePickerView(for: $weekEndDate, isStartDate: false)
                    .background(
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                dismissEndDatePicker()
                            }
                    )
            }
        }
    }
    
    private func dismissStartDatePicker() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            let calendar = Calendar.current
            if let newEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) {
                weekEndDate = newEndDate
            }
            showingStartDatePicker = false
            updateSelectedDateFromWeek()
        }
    }
    
    private func dismissEndDatePicker() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            let calendar = Calendar.current
            if let newStartDate = calendar.date(byAdding: .day, value: -6, to: weekEndDate) {
                weekStartDate = newStartDate
            }
            showingEndDatePicker = false
            updateSelectedDateFromWeek()
        }
    }
    
    private func weekDateButton(title: String, date: Date, isShowing: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(.darkGrayText)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11))
                        .foregroundColor(.darkGrayText)
                    Text(weekDateFormatter.string(from: date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func weekDatePickerView(for binding: Binding<Date>, isStartDate: Bool) -> some View {
        DatePicker(
            "",
            selection: binding,
            displayedComponents: .date
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .onChange(of: binding.wrappedValue) { _, newDate in
            let calendar = Calendar.current
            if isStartDate {
                if let newEndDate = calendar.date(byAdding: .day, value: 6, to: newDate) {
                    weekEndDate = newEndDate
                }
            } else {
                if let newStartDate = calendar.date(byAdding: .day, value: -6, to: newDate) {
                    weekStartDate = newStartDate
                }
            }
            updateSelectedDateFromWeek()
        }
    }
    
    // MARK: - Daily View Content
    private var dailyViewContent: some View {
        VStack(spacing: 16) {
            if dayEntries.isEmpty {
                emptyStateMessage(
                    title: "No medications scheduled",
                    message: "You don't have any medications scheduled for this day."
                )
            } else {
                ForEach(dayEntries) { entry in
                    medicationCard(for: entry)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Weekly View Content
    private var weeklyViewContent: some View {
        VStack(spacing: 20) {
            // Weekly Completion Summary
            if !weekEntriesByDay.isEmpty && weekEntriesByDay.flatMap({ $0.entries }).isEmpty == false {
                weeklyCompletionSummary
            }
            
            // Daily Sections
            if weekEntriesByDay.isEmpty || weekEntriesByDay.allSatisfy({ $0.entries.isEmpty }) {
                emptyStateMessage(
                    title: "No medications scheduled",
                    message: "You don't have any medications scheduled for this week."
                )
            } else {
                ForEach(weekEntriesByDay, id: \.date) { dayData in
                    dailySection(for: dayData.date, entries: dayData.entries)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private var weeklyCompletionSummary: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 65, height: 65)
                    
                    Circle()
                        .trim(from: 0, to: Double(weeklyCompletionPercentage) / 100.0)
                        .stroke(Color.secondaryGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 65, height: 65)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(weeklyCompletionPercentage)%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                }
                .padding(.trailing, 15)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Completion")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.darkGrayText)
                    
                    Text("\(weekDateFormatter.string(from: weekStartDate)) - \(weekDateFormatter.string(from: weekEndDate))")
                        .font(.system(size: 16))
                        .foregroundColor(.darkGrayText)
                }
                
                Spacer()
            }
            .padding()
            
            Divider()
                .background(Color.gray)
        }
    }
    
    // MARK: - Medication Card (Daily View)
    private func medicationCard(for entry: MedicationEntry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Time section with gray background
            Text(timeFormatter.string(from: entry.scheduledTime))
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.darkGrayText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 0) {
                // Medicine Name
                Text(entry.medicationName)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.primaryGreen)
                    .padding(.bottom, 0)
                
                // Instructions
                Text(entry.instructions)
                    .font(.system(size: 16))
                    .foregroundColor(.darkGrayText)
                    .padding(.bottom, 12)
                
                // Status Buttons
                HStack(spacing: 12) {
                    statusButton(title: "Skipped", status: .skipped, isSelected: entry.status == .skipped, entryId: entry.id)
                    statusButton(title: "Taken", status: .taken, isSelected: entry.status == .taken, entryId: entry.id)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 0.15)
        }
    }
    
    private func statusButton(title: String, status: MedicationStatus, isSelected: Bool, entryId: UUID) -> some View {
        Button(action: {
            if let entry = medicationEntries.first(where: { $0.id == entryId }) {
                if status == .taken {
                    markMedicationAsTaken(entry)
                } else if status == .skipped {
                    markMedicationAsSkipped(entry)
                }
            }
        }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .darkGrayText)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? (status == .taken ? Color.secondaryGreen : Color.missingColor) : Color.white)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.8), lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Daily Section (Weekly View)
    private func dailySection(for date: Date, entries: [MedicationEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Day Header
            Text(dayHeaderFormatter.string(from: date))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primaryGreen)
            
            if entries.isEmpty {
                Text("No medications scheduled for this day")
                    .font(.system(size: 16))
                    .foregroundColor(.darkGrayText)
                    .padding(.top, 0)
            } else {
                // Missed medications are medications that were not taken
                let missedEntries = entries.filter { $0.status == .skipped || $0.status == nil}
                
                // Taken medications are medications that were taken
                let takenEntries = entries.filter { $0.status == .taken }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Missed medications for the day section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.missingColor)
                                .frame(width: 8, height: 8)
                            
                            Text("Missed (\(missedEntries.count))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.darkGrayText)
                        }
                        
                        if !missedEntries.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                // Vertical line stretches as long as the list
                                Rectangle()
                                    .fill(Color.missingColor)
                                    .frame(width: 2)
                                    .frame(height: CGFloat(missedEntries.count) * 24.0)
                                    .padding(.leading, 2)
                                
                                // List of missed medication times
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(missedEntries) { entry in
                                        HStack(spacing: 8) {
                                            Image(systemName: "pills")
                                                .font(.system(size: 14))
                                                .foregroundColor(.darkGrayText)
                                            
                                            Text("\(entry.medicationName), \(timeFormatter.string(from: entry.scheduledTime))")
                                                .font(.system(size: 14))
                                                .foregroundColor(.darkGrayText)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Taken medications for the day section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.secondaryGreen)
                                .frame(width: 8, height: 8)
                            
                            Text("Taken (\(takenEntries.count))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.darkGrayText)
                        }
                        
                        if !takenEntries.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                // Vertical line stretches as long as the list
                                Rectangle()
                                    .fill(Color.secondaryGreen)
                                    .frame(width: 2)
                                    .frame(height: CGFloat(takenEntries.count) * 24.0)
                                    .padding(.leading, 2)
                                
                                // List of taken medication times
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(takenEntries) { entry in
                                        HStack(spacing: 8) {
                                            Image(systemName: "pills")
                                                .font(.system(size: 14))
                                                .foregroundColor(.darkGrayText)
                                            
                                            Text("\(entry.medicationName), \(timeFormatter.string(from: entry.scheduledTime))")
                                                .font(.system(size: 14))
                                                .foregroundColor(.darkGrayText)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Empty State
    private func emptyStateMessage(title: String, message: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.darkGrayText)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.darkGrayText)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Functions
    enum MedicationViewMode {
        case daily, weekly
    }
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    private var dayHeaderFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    private func navigateMonth(forward: Bool) {
        let calendar = Calendar.current
        let value = forward ? 1 : -1
        
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
            
            if selectedMode == .weekly {
                updateWeekDates()
            }
        }
    }
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) {
            weekStartDate = weekInterval.start
            weekEndDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
        }
    }
    
    private func updateSelectedDateFromWeek() {
        selectedDate = weekStartDate
    }
}

// Make MedicationEntry Identifiable
extension MedicationEntry: Identifiable {}

// More colors to use for this page
private extension Color {
    static let missingColor = Color(red: 181/255, green: 55/255, blue: 55/255)
}

// To preview this page for only developer use
#Preview {
    MedicationLogView()
}
