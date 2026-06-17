import Foundation

struct BodyMetricPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
    let isToday: Bool
}

struct BodyEntry: Codable, Identifiable {
    var id: String { dateString }
    let dateString: String
    var weightKg: Double?
    var waistCm: Double?
}

struct NutritionDayLog: Codable, Identifiable, Equatable {
    var id: String { dateString }
    let dateString: String
    var completedMealIDs: Set<String>
}

struct TrainingCalendarEntry: Codable, Identifiable, Equatable {
    var id: String { dateString }
    let dateString: String
    var cycleID: Int
    var trainingDay: String
}

struct ExerciseSetLog: Codable, Identifiable, Equatable {
    let id: String
    var targetReps: String
    var weightText: String
    var repsText: String
    var isDone: Bool
}

struct ExerciseLog: Codable, Identifiable, Equatable {
    var id: String { logKey }
    let logKey: String
    var setLogs: [ExerciseSetLog]
    var note: String
    var isDone: Bool

    init(logKey: String, setLogs: [ExerciseSetLog], note: String, isDone: Bool) {
        self.logKey = logKey
        self.setLogs = setLogs
        self.note = note
        self.isDone = isDone
    }

    private enum CodingKeys: String, CodingKey {
        case logKey
        case setLogs
        case weightText
        case repsText
        case note
        case isDone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        logKey = try container.decode(String.self, forKey: .logKey)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        isDone = try container.decodeIfPresent(Bool.self, forKey: .isDone) ?? false

        if let decodedSetLogs = try container.decodeIfPresent([ExerciseSetLog].self, forKey: .setLogs) {
            setLogs = decodedSetLogs
        } else {
            let legacyWeight = try container.decodeIfPresent(String.self, forKey: .weightText) ?? ""
            let legacyReps = try container.decodeIfPresent(String.self, forKey: .repsText) ?? ""
            setLogs = legacyWeight.isEmpty && legacyReps.isEmpty ? [] : [
                ExerciseSetLog(id: "set-1", targetReps: "", weightText: legacyWeight, repsText: legacyReps, isDone: isDone)
            ]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(logKey, forKey: .logKey)
        try container.encode(setLogs, forKey: .setLogs)
        try container.encode(note, forKey: .note)
        try container.encode(isDone, forKey: .isDone)
    }
}

struct TodayPlan: Codable, Equatable {
    var cycleID: Int
    var trainingDay: String
    var phaseID: String
    var recipeVariantID: String
    var calorieAdjustmentID: String

    init(
        cycleID: Int,
        trainingDay: String,
        phaseID: String = "buffer-3-8",
        recipeVariantID: String = "chicken",
        calorieAdjustmentID: String = "base"
    ) {
        self.cycleID = cycleID
        self.trainingDay = trainingDay
        self.phaseID = phaseID
        self.recipeVariantID = recipeVariantID
        self.calorieAdjustmentID = calorieAdjustmentID
    }

    private enum CodingKeys: String, CodingKey {
        case cycleID
        case trainingDay
        case phaseID
        case recipeVariantID
        case calorieAdjustmentID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cycleID = try container.decode(Int.self, forKey: .cycleID)
        trainingDay = try container.decode(String.self, forKey: .trainingDay)
        phaseID = try container.decodeIfPresent(String.self, forKey: .phaseID) ?? "buffer-3-8"
        recipeVariantID = try container.decodeIfPresent(String.self, forKey: .recipeVariantID) ?? "chicken"
        calorieAdjustmentID = try container.decodeIfPresent(String.self, forKey: .calorieAdjustmentID) ?? "base"
    }
}

@MainActor
final class AthleteDataStore: ObservableObject {
    @Published private(set) var bodyEntries: [BodyEntry] = []
    @Published private(set) var nutritionLogs: [NutritionDayLog] = []
    @Published private(set) var trainingCalendarEntries: [TrainingCalendarEntry] = []
    @Published private(set) var exerciseLogs: [ExerciseLog] = []
    @Published private(set) var todayPlan = TodayPlan(cycleID: 1, trainingDay: "背")

    private let defaults: UserDefaults
    private let bodyEntriesKey = "ironprotocol.bodyEntries"
    private let nutritionLogsKey = "ironprotocol.nutritionLogs"
    private let trainingCalendarKey = "ironprotocol.trainingCalendarEntries"
    private let exerciseLogsKey = "ironprotocol.exerciseLogs"
    private let todayPlanKey = "ironprotocol.todayPlan"
    private let calendar = Calendar.current

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var todayEntry: BodyEntry? {
        entry(for: Date())
    }

    var latestWeight: Double? {
        bodyEntries
            .sorted { $0.dateString > $1.dateString }
            .compactMap(\.weightKg)
            .first
    }

    var latestWaist: Double? {
        bodyEntries
            .sorted { $0.dateString > $1.dateString }
            .compactMap(\.waistCm)
            .first
    }

    var sevenDayAverageWeight: Double? {
        averageWeight(days: 7)
    }

    var twoWeekWeightDelta: Double? {
        let recent = averageWeight(days: 7, endingAt: Date())
        guard let previousEnd = calendar.date(byAdding: .day, value: -7, to: Date()) else { return nil }
        let previous = averageWeight(days: 7, endingAt: previousEnd)
        guard let recent, let previous else { return nil }
        return recent - previous
    }

    var monthlyGainRate: Double? {
        let weighted = bodyEntries
            .compactMap { entry -> (Date, Double)? in
                guard let date = Self.dateFormatter.date(from: entry.dateString),
                      let weight = entry.weightKg else { return nil }
                return (date, weight)
            }
            .sorted { $0.0 < $1.0 }
        guard let first = weighted.first, let last = weighted.last, first.0 != last.0 else { return nil }
        let days = max(calendar.dateComponents([.day], from: first.0, to: last.0).day ?? 1, 1)
        return (last.1 - first.1) / Double(days) * 30
    }

    var chartPoints: [BodyMetricPoint] {
        let recent = bodyEntries
            .compactMap { entry -> (Date, BodyEntry)? in
                guard let date = Self.dateFormatter.date(from: entry.dateString),
                      entry.weightKg != nil else { return nil }
                return (date, entry)
            }
            .sorted { $0.0 < $1.0 }
            .suffix(7)

        return recent.map { date, entry in
            BodyMetricPoint(
                day: String(calendar.component(.day, from: date)),
                value: entry.weightKg ?? 0,
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    var trendStatusText: String {
        guard let delta = twoWeekWeightDelta else { return "待记录" }
        if delta < 0.2 {
            return "偏低"
        }
        if delta > 0.6 {
            return "偏高"
        }
        return "正常"
    }

    var coachInsightText: String {
        guard let delta = twoWeekWeightDelta else {
            return "先连续记录体重至少 14 天，再输出食谱调整建议。"
        }
        if delta < 0.2 {
            return "两周均重增长偏低。若训练表现也没有上涨，建议确认启用当前阶段 +100 kcal 版本。"
        }
        if delta > 0.6 {
            return "体重增长偏快。若腰围也明显上涨，建议优先减少休息日碳水。"
        }
        return "体重趋势在目标区间，保持当前模板，不自动调整计划。"
    }

    var todayMealCount: Int {
        todayPlan.trainingDay == "休息" ? 3 : 4
    }

    var todayNutritionCompletionText: String {
        let completed = completedMealCount()
        return "\(min(completed, todayMealCount)) / \(todayMealCount) 餐次"
    }

    var todayNutritionCompletionRate: Double {
        Double(min(completedMealCount(), todayMealCount)) / Double(todayMealCount)
    }

    func nutritionCompletionText(for mealIDs: [String], on date: Date = Date()) -> String {
        let completed = completedMealCount(for: mealIDs, on: date)
        return "\(completed) / \(mealIDs.count) 餐次"
    }

    func nutritionCompletionRate(for mealIDs: [String], on date: Date = Date()) -> Double {
        guard !mealIDs.isEmpty else { return 0 }
        return Double(completedMealCount(for: mealIDs, on: date)) / Double(mealIDs.count)
    }

    var todayPhaseText: String {
        switch todayPlan.phaseID {
        case "post-cut-1-2":
            return "减脂后1-2周"
        case "stable-9-plus":
            return "9周后稳定增肌"
        default:
            return "3-8周缓冲"
        }
    }

    var todayDietTypeText: String {
        switch todayPlan.trainingDay {
        case "肩", "胸":
            return "肩胸中碳"
        case "背", "腿":
            return "背腿高碳"
        default:
            return "休息中低碳"
        }
    }

    var todayRecipeVariantText: String {
        switch todayPlan.recipeVariantID {
        case "beef":
            return "带牛肉"
        case "beef-ball":
            return todayPlan.phaseID == "stable-9-plus" ? "牛肉丸版" : "带牛肉"
        default:
            return "纯鸡胸"
        }
    }

    var todayCalorieAdjustmentText: String {
        todayPlan.calorieAdjustmentID == "plus-100" ? "+100 kcal" : "标准"
    }

    var todayCaloriesText: String {
        let suffix = todayPlan.calorieAdjustmentID == "plus-100" ? " +100" : ""
        switch todayPlan.phaseID {
        case "post-cut-1-2":
            return todayPlan.trainingDay == "休息" ? "无练后餐" : "过渡模板"
        case "stable-9-plus":
            switch todayPlan.trainingDay {
            case "肩", "胸":
                return "2700\(suffix) kcal"
            case "背", "腿":
                return "2950\(suffix) kcal"
            default:
                return "2400\(suffix) kcal"
            }
        default:
            switch todayPlan.trainingDay {
            case "肩", "胸":
                return "2500\(suffix) kcal"
            case "背", "腿":
                return "2750\(suffix) kcal"
            default:
                return "2250\(suffix) kcal"
            }
        }
    }

    var todayMacroTargets: (protein: String, carbs: String, fat: String) {
        let carbBoost = todayPlan.calorieAdjustmentID == "plus-100" ? 25 : 0
        switch todayPlan.phaseID {
        case "post-cut-1-2":
            return todayPlan.trainingDay == "休息" ? ("P 175", "C \(190 + carbBoost)", "F 60") : ("P 175", "C \(240 + carbBoost)", "F 55")
        case "stable-9-plus":
            switch todayPlan.trainingDay {
            case "肩", "胸":
                return ("P 185", "C \(335 + carbBoost)", "F 55")
            case "背", "腿":
                return ("P 190", "C \(370 + carbBoost)", "F 55")
            default:
                return ("P 185", "C \(245 + carbBoost)", "F 65")
            }
        default:
            switch todayPlan.trainingDay {
            case "肩", "胸":
                return ("P 180", "C \(300 + carbBoost)", "F 55")
            case "背", "腿":
                return ("P 185", "C \(335 + carbBoost)", "F 55")
            default:
                return ("P 180", "C \(220 + carbBoost)", "F 65")
            }
        }
    }

    func saveToday(weightText: String, waistText: String) {
        let weight = Double(weightText.trimmingCharacters(in: .whitespacesAndNewlines))
        let waist = Double(waistText.trimmingCharacters(in: .whitespacesAndNewlines))
        upsert(date: Date(), weightKg: weight, waistCm: waist)
    }

    func setTodayPlan(
        cycleID: Int? = nil,
        trainingDay: String? = nil,
        phaseID: String? = nil,
        recipeVariantID: String? = nil,
        calorieAdjustmentID: String? = nil
    ) {
        todayPlan = TodayPlan(
            cycleID: cycleID ?? todayPlan.cycleID,
            trainingDay: trainingDay ?? todayPlan.trainingDay,
            phaseID: phaseID ?? todayPlan.phaseID,
            recipeVariantID: recipeVariantID ?? todayPlan.recipeVariantID,
            calorieAdjustmentID: calorieAdjustmentID ?? todayPlan.calorieAdjustmentID
        )
        persistTodayPlan()
        if cycleID != nil || trainingDay != nil {
            saveTrainingCalendarEntry(date: Date(), cycleID: todayPlan.cycleID, trainingDay: todayPlan.trainingDay)
        }
    }

    func trainingCalendarEntry(on date: Date) -> TrainingCalendarEntry? {
        let key = Self.dateFormatter.string(from: date)
        return trainingCalendarEntries.first { $0.dateString == key }
    }

    func saveTrainingCalendarEntry(date: Date, cycleID: Int, trainingDay: String) {
        let key = Self.dateFormatter.string(from: date)
        if let index = trainingCalendarEntries.firstIndex(where: { $0.dateString == key }) {
            trainingCalendarEntries[index].cycleID = cycleID
            trainingCalendarEntries[index].trainingDay = trainingDay
        } else {
            trainingCalendarEntries.append(TrainingCalendarEntry(dateString: key, cycleID: cycleID, trainingDay: trainingDay))
        }
        trainingCalendarEntries.sort { $0.dateString < $1.dateString }
        persistTrainingCalendar()
    }

    func isMealCompleted(_ mealID: String, on date: Date = Date()) -> Bool {
        let key = Self.dateFormatter.string(from: date)
        return nutritionLogs.first { $0.dateString == key }?.completedMealIDs.contains(mealID) ?? false
    }

    func toggleMeal(_ mealID: String, on date: Date = Date()) {
        let key = Self.dateFormatter.string(from: date)
        if let index = nutritionLogs.firstIndex(where: { $0.dateString == key }) {
            if nutritionLogs[index].completedMealIDs.contains(mealID) {
                nutritionLogs[index].completedMealIDs.remove(mealID)
            } else {
                nutritionLogs[index].completedMealIDs.insert(mealID)
            }
        } else {
            nutritionLogs.append(NutritionDayLog(dateString: key, completedMealIDs: [mealID]))
        }
        nutritionLogs.sort { $0.dateString < $1.dateString }
        persistNutrition()
    }

    func exerciseLog(cycleID: Int, day: String, exerciseID: String) -> ExerciseLog {
        let key = exerciseLogKey(cycleID: cycleID, day: day, exerciseID: exerciseID)
        return exerciseLogs.first { $0.logKey == key } ?? ExerciseLog(
            logKey: key,
            setLogs: [],
            note: "",
            isDone: false
        )
    }

    func saveExerciseLog(
        cycleID: Int,
        day: String,
        exerciseID: String,
        setLogs: [ExerciseSetLog],
        note: String,
        isDone: Bool
    ) {
        let key = exerciseLogKey(cycleID: cycleID, day: day, exerciseID: exerciseID)
        let log = ExerciseLog(
            logKey: key,
            setLogs: setLogs,
            note: note,
            isDone: isDone
        )
        if let index = exerciseLogs.firstIndex(where: { $0.logKey == key }) {
            exerciseLogs[index] = log
        } else {
            exerciseLogs.append(log)
        }
        persistExerciseLogs()
    }

    func completedExerciseCount(cycleID: Int, day: String, exerciseIDs: [String]) -> Int {
        exerciseIDs.filter { exerciseLog(cycleID: cycleID, day: day, exerciseID: $0).isDone }.count
    }

    func latestTrainingSummary(cycleID: Int, day: String, exerciseIDs: [String]) -> String {
        let completed = completedExerciseCount(cycleID: cycleID, day: day, exerciseIDs: exerciseIDs)
        guard completed > 0 else { return "今天还未开始记录" }
        return "已完成 \(completed)/\(exerciseIDs.count) 个动作"
    }

    func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1fkg", value)
    }

    func formattedWaist(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1fcm", value)
    }

    func formattedDelta(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%+.1fkg", value)
    }

    func formattedGainRate(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1fkg / 月", value)
    }

    private func entry(for date: Date) -> BodyEntry? {
        let key = Self.dateFormatter.string(from: date)
        return bodyEntries.first { $0.dateString == key }
    }

    private func completedMealCount(on date: Date = Date()) -> Int {
        let key = Self.dateFormatter.string(from: date)
        return nutritionLogs.first { $0.dateString == key }?.completedMealIDs.count ?? 0
    }

    private func completedMealCount(for mealIDs: [String], on date: Date = Date()) -> Int {
        let key = Self.dateFormatter.string(from: date)
        let completedIDs = nutritionLogs.first { $0.dateString == key }?.completedMealIDs ?? []
        return mealIDs.filter { completedIDs.contains($0) }.count
    }

    private func exerciseLogKey(cycleID: Int, day: String, exerciseID: String, date: Date = Date()) -> String {
        "\(Self.dateFormatter.string(from: date))|cycle-\(cycleID)|\(day)|\(exerciseID)"
    }

    private func upsert(date: Date, weightKg: Double?, waistCm: Double?) {
        let key = Self.dateFormatter.string(from: date)
        if let index = bodyEntries.firstIndex(where: { $0.dateString == key }) {
            bodyEntries[index].weightKg = weightKg
            bodyEntries[index].waistCm = waistCm
        } else {
            bodyEntries.append(BodyEntry(dateString: key, weightKg: weightKg, waistCm: waistCm))
        }
        bodyEntries.sort { $0.dateString < $1.dateString }
        persist()
    }

    private func averageWeight(days: Int, endingAt endDate: Date = Date()) -> Double? {
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: endDate)) else {
            return nil
        }
        let end = calendar.startOfDay(for: endDate)
        let values = bodyEntries.compactMap { entry -> Double? in
            guard let date = Self.dateFormatter.date(from: entry.dateString),
                  date >= startDate,
                  date <= end else { return nil }
            return entry.weightKg
        }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private func load() {
        if let data = defaults.data(forKey: bodyEntriesKey),
           let decoded = try? JSONDecoder().decode([BodyEntry].self, from: data) {
            bodyEntries = decoded.sorted { $0.dateString < $1.dateString }
        } else {
            bodyEntries = []
        }

        if let data = defaults.data(forKey: nutritionLogsKey),
           let decoded = try? JSONDecoder().decode([NutritionDayLog].self, from: data) {
            nutritionLogs = decoded.sorted { $0.dateString < $1.dateString }
        } else {
            nutritionLogs = []
        }

        if let data = defaults.data(forKey: trainingCalendarKey),
           let decoded = try? JSONDecoder().decode([TrainingCalendarEntry].self, from: data) {
            trainingCalendarEntries = decoded.sorted { $0.dateString < $1.dateString }
        } else {
            trainingCalendarEntries = []
        }

        if let data = defaults.data(forKey: exerciseLogsKey),
           let decoded = try? JSONDecoder().decode([ExerciseLog].self, from: data) {
            exerciseLogs = decoded
        } else {
            exerciseLogs = []
        }

        if let data = defaults.data(forKey: todayPlanKey),
           let decoded = try? JSONDecoder().decode(TodayPlan.self, from: data) {
            todayPlan = decoded
        } else {
            todayPlan = TodayPlan(cycleID: 1, trainingDay: "背")
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(bodyEntries) else { return }
        defaults.set(data, forKey: bodyEntriesKey)
    }

    private func persistNutrition() {
        guard let data = try? JSONEncoder().encode(nutritionLogs) else { return }
        defaults.set(data, forKey: nutritionLogsKey)
    }

    private func persistTrainingCalendar() {
        guard let data = try? JSONEncoder().encode(trainingCalendarEntries) else { return }
        defaults.set(data, forKey: trainingCalendarKey)
    }

    private func persistExerciseLogs() {
        guard let data = try? JSONEncoder().encode(exerciseLogs) else { return }
        defaults.set(data, forKey: exerciseLogsKey)
    }

    private func persistTodayPlan() {
        guard let data = try? JSONEncoder().encode(todayPlan) else { return }
        defaults.set(data, forKey: todayPlanKey)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
