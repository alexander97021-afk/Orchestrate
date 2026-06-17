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

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case protein
    case carb
    case fat
    case dairy
    case vegetable
    case fruit
    case mixed
    case supplement

    var id: String { rawValue }

    var label: String {
        switch self {
        case .protein: return "蛋白质"
        case .carb: return "碳水"
        case .fat: return "脂肪"
        case .dairy: return "乳制品"
        case .vegetable: return "蔬菜"
        case .fruit: return "水果"
        case .mixed: return "混合"
        case .supplement: return "补剂"
        }
    }
}

enum FoodUnit: String, Codable, CaseIterable, Identifiable {
    case g
    case ml
    case piece
    case slice

    var id: String { rawValue }

    var label: String {
        switch self {
        case .g: return "g"
        case .ml: return "ml"
        case .piece: return "个"
        case .slice: return "片"
        }
    }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "早餐"
    case lunch = "午餐"
    case dinner = "晚餐"
    case postWorkout = "练后"
    case snack = "加餐"

    var id: String { rawValue }
}

struct FoodMacros: Codable, Equatable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
}

struct FoodItem: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var category: FoodCategory
    var unit: FoodUnit
    var defaultServing: Double
    var caloriesPer100: Double
    var proteinPer100: Double
    var carbsPer100: Double
    var fatPer100: Double
    var isEditable: Bool
    var isBrandSensitive: Bool
    var notes: String

    func macros(for amount: Double) -> FoodMacros {
        let multiplier: Double
        switch unit {
        case .g, .ml:
            multiplier = amount / 100
        case .piece, .slice:
            multiplier = amount / max(defaultServing, 1)
        }
        return FoodMacros(
            calories: caloriesPer100 * multiplier,
            protein: proteinPer100 * multiplier,
            carbs: carbsPer100 * multiplier,
            fat: fatPer100 * multiplier
        )
    }
}

struct FoodEntry: Codable, Identifiable, Equatable {
    let id: String
    let dateString: String
    let foodItemId: String
    var foodName: String
    var mealType: MealType
    var amount: Double
    var unit: FoodUnit
    var calculatedCalories: Double
    var calculatedProtein: Double
    var calculatedCarbs: Double
    var calculatedFat: Double
}

struct DailyNutritionTarget: Equatable {
    var phaseID: String
    var trainingType: String
    var dietType: String
    var caloriesTarget: Double
    var proteinTarget: Double
    var carbsTarget: Double
    var fatTarget: Double
}

struct DailyNutritionLog: Equatable {
    var dateString: String
    var entries: [FoodEntry]
    var target: DailyNutritionTarget

    var totalCalories: Double { entries.reduce(0) { $0 + $1.calculatedCalories } }
    var totalProtein: Double { entries.reduce(0) { $0 + $1.calculatedProtein } }
    var totalCarbs: Double { entries.reduce(0) { $0 + $1.calculatedCarbs } }
    var totalFat: Double { entries.reduce(0) { $0 + $1.calculatedFat } }
    var remainingCalories: Double { target.caloriesTarget - totalCalories }
    var remainingProtein: Double { target.proteinTarget - totalProtein }
    var remainingCarbs: Double { target.carbsTarget - totalCarbs }
    var remainingFat: Double { target.fatTarget - totalFat }
}

enum NutritionDayMode: String, Codable, CaseIterable, Identifiable {
    case normal = "normal"
    case missedTraining = "missed-training"
    case flexible = "flexible"
    case plannedCheat = "planned-cheat"
    case rest = "rest"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .normal: return "正常训练日"
        case .missedTraining: return "断练"
        case .flexible: return "应酬 / 外出"
        case .plannedCheat: return "计划内放纵餐"
        case .rest: return "休息日"
        }
    }

    var guidance: String? {
        switch self {
        case .normal:
            return nil
        case .missedTraining, .rest:
            return "今日已切换为休息日摄入目标。已有记录会保留。"
        case .flexible:
            return "Flexible Day：早餐和午餐尽量保持高蛋白、低脂；晚餐可记录为应酬餐。第二天回归计划。"
        case .plannedCheat:
            return "Planned Cheat Meal：这不是违规。放纵餐后 1-3 天体重上涨通常来自水分和糖原，不作为失败判断。"
        }
    }
}

enum MealPresetVariant: String, Codable, CaseIterable, Identifiable {
    case standard
    case rice
    case noodle
    case beefBall
    case diverseA
    case diverseB
    case weekend

    var id: String { rawValue }

    var label: String {
        switch self {
        case .standard: return "固定食谱"
        case .rice: return "米饭版"
        case .noodle: return "面条版"
        case .beefBall: return "牛肉丸版"
        case .diverseA: return "多样化 A"
        case .diverseB: return "多样化 B"
        case .weekend: return "周末口味版"
        }
    }
}

enum MealPresetSource: String, Codable {
    case fixed
    case diverse
}

enum PresetApplyMode {
    case overwrite
    case append
}

enum PresetTrainingGroup: String, Codable {
    case shoulderChest
    case backLegs
    case rest

    var label: String {
        switch self {
        case .shoulderChest: return "肩 / 胸"
        case .backLegs: return "背 / 腿"
        case .rest: return "休息"
        }
    }
}

struct PresetFoodAmount: Identifiable, Equatable {
    let id = UUID()
    let foodItemId: String
    let amount: Double
}

struct PresetMeal: Identifiable, Equatable {
    let id = UUID()
    let mealType: MealType
    let items: [PresetFoodAmount]
}

struct MealPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let phaseID: String?
    let trainingGroup: PresetTrainingGroup
    let variant: MealPresetVariant
    let source: MealPresetSource
    let meals: [PresetMeal]
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
    var dayModeID: String

    init(
        cycleID: Int,
        trainingDay: String,
        phaseID: String = "buffer-3-8",
        recipeVariantID: String = "chicken",
        calorieAdjustmentID: String = "base",
        dayModeID: String = NutritionDayMode.normal.rawValue
    ) {
        self.cycleID = cycleID
        self.trainingDay = trainingDay
        self.phaseID = phaseID
        self.recipeVariantID = recipeVariantID
        self.calorieAdjustmentID = calorieAdjustmentID
        self.dayModeID = dayModeID
    }

    private enum CodingKeys: String, CodingKey {
        case cycleID
        case trainingDay
        case phaseID
        case recipeVariantID
        case calorieAdjustmentID
        case dayModeID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cycleID = try container.decode(Int.self, forKey: .cycleID)
        trainingDay = try container.decode(String.self, forKey: .trainingDay)
        phaseID = try container.decodeIfPresent(String.self, forKey: .phaseID) ?? "buffer-3-8"
        recipeVariantID = try container.decodeIfPresent(String.self, forKey: .recipeVariantID) ?? "chicken"
        calorieAdjustmentID = try container.decodeIfPresent(String.self, forKey: .calorieAdjustmentID) ?? "base"
        dayModeID = try container.decodeIfPresent(String.self, forKey: .dayModeID) ?? NutritionDayMode.normal.rawValue
    }
}

@MainActor
final class AthleteDataStore: ObservableObject {
    @Published private(set) var bodyEntries: [BodyEntry] = []
    @Published private(set) var nutritionLogs: [NutritionDayLog] = []
    @Published private(set) var foodEntries: [FoodEntry] = []
    @Published private(set) var trainingCalendarEntries: [TrainingCalendarEntry] = []
    @Published private(set) var exerciseLogs: [ExerciseLog] = []
    @Published private(set) var todayPlan = TodayPlan(cycleID: 1, trainingDay: "背")

    private let defaults: UserDefaults
    private let bodyEntriesKey = "ironprotocol.bodyEntries"
    private let nutritionLogsKey = "ironprotocol.nutritionLogs"
    private let foodEntriesKey = "ironprotocol.foodEntries"
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
        let completed = todayRecordedMealCount()
        return "\(min(completed, todayMealCount)) / \(todayMealCount) 餐次"
    }

    var todayNutritionCompletionRate: Double {
        Double(min(todayRecordedMealCount(), todayMealCount)) / Double(todayMealCount)
    }

    func nutritionCompletionText(for mealIDs: [String], on date: Date = Date()) -> String {
        let targetCount = mealIDs.isEmpty ? todayMealCount : mealIDs.count
        let completed = max(todayRecordedMealCount(on: date), completedMealCount(for: mealIDs, on: date))
        return "\(min(completed, targetCount)) / \(targetCount) 餐次"
    }

    func nutritionCompletionRate(for mealIDs: [String], on date: Date = Date()) -> Double {
        let targetCount = mealIDs.isEmpty ? todayMealCount : mealIDs.count
        guard targetCount > 0 else { return 0 }
        let completed = max(todayRecordedMealCount(on: date), completedMealCount(for: mealIDs, on: date))
        return Double(min(completed, targetCount)) / Double(targetCount)
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

    var isPlus100Enabled: Bool {
        todayPlan.calorieAdjustmentID == "plus-100"
    }

    var todayDayMode: NutritionDayMode {
        NutritionDayMode(rawValue: todayPlan.dayModeID) ?? .normal
    }

    var effectiveNutritionTrainingDay: String {
        switch todayDayMode {
        case .missedTraining, .rest:
            return "休息"
        case .normal, .flexible, .plannedCheat:
            return todayPlan.trainingDay
        }
    }

    var todayCaloriesText: String {
        "\(Int(todayNutritionTarget.caloriesTarget)) kcal"
    }

    var todayMacroTargets: (protein: String, carbs: String, fat: String) {
        let target = todayNutritionTarget
        return ("P \(Int(target.proteinTarget))", "C \(Int(target.carbsTarget))", "F \(Int(target.fatTarget))")
    }

    var foodLibrary: [FoodItem] {
        Self.defaultFoodLibrary
    }

    var todayNutritionTarget: DailyNutritionTarget {
        nutritionTarget(phaseID: todayPlan.phaseID, trainingDay: effectiveNutritionTrainingDay)
    }

    var todayNutritionLog: DailyNutritionLog {
        nutritionLog(on: Date())
    }

    func nutritionTarget(phaseID: String, trainingDay: String) -> DailyNutritionTarget {
        let dietType: String
        let isTrainingDay = trainingDay != "休息"
        let target: DailyNutritionTarget
        switch trainingDay {
        case "肩", "胸":
            dietType = "中碳日"
        case "背", "腿":
            dietType = "高碳日"
        default:
            dietType = "中低碳日"
        }

        switch phaseID {
        case "post-cut-1-2":
            target = isTrainingDay
                ? DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2300, proteinTarget: 180, carbsTarget: 250, fatTarget: 55)
                : DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2000, proteinTarget: 175, carbsTarget: 200, fatTarget: 60)
        case "stable-9-plus":
            switch trainingDay {
            case "肩", "胸":
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2600, proteinTarget: 190, carbsTarget: 305, fatTarget: 56)
            case "背", "腿":
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2850, proteinTarget: 190, carbsTarget: 365, fatTarget: 57)
            default:
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2300, proteinTarget: 178, carbsTarget: 235, fatTarget: 66)
            }
        default:
            switch trainingDay {
            case "肩", "胸":
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2400, proteinTarget: 180, carbsTarget: 265, fatTarget: 55)
            case "背", "腿":
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2650, proteinTarget: 190, carbsTarget: 320, fatTarget: 56)
            default:
                target = DailyNutritionTarget(phaseID: phaseID, trainingType: trainingDay, dietType: dietType, caloriesTarget: 2150, proteinTarget: 175, carbsTarget: 205, fatTarget: 65)
            }
        }
        return isPlus100Enabled ? plus100Target(from: target) : target
    }

    func nutritionLog(on date: Date = Date()) -> DailyNutritionLog {
        let key = Self.dateFormatter.string(from: date)
        let entries = foodEntries
            .filter { $0.dateString == key }
            .sorted { $0.mealType.rawValue < $1.mealType.rawValue }
        return DailyNutritionLog(dateString: key, entries: entries, target: todayNutritionTarget)
    }

    func addFoodEntry(foodItem: FoodItem, mealType: MealType, amount: Double, date: Date = Date()) {
        let normalizedAmount = max(amount, 0)
        let macros = foodItem.macros(for: normalizedAmount)
        let entry = foodEntry(foodItem: foodItem, mealType: mealType, amount: normalizedAmount, macros: macros, date: date)
        foodEntries.append(entry)
        foodEntries.sort { ($0.dateString, $0.mealType.rawValue, $0.foodName) < ($1.dateString, $1.mealType.rawValue, $1.foodName) }
        persistFoodEntries()
    }

    func deleteFoodEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }
        persistFoodEntries()
    }

    var hasFoodEntriesToday: Bool {
        !todayNutritionLog.entries.isEmpty
    }

    var fixedPresetForToday: MealPreset? {
        mealPreset(source: .fixed, variant: .standard)
    }

    var beefBallPresetForToday: MealPreset? {
        guard todayPlan.phaseID == "stable-9-plus" else { return nil }
        return mealPreset(source: .fixed, variant: .beefBall)
    }

    var diversePresetForToday: MealPreset? {
        let group = presetTrainingGroup(for: effectiveNutritionTrainingDay)
        let candidates = Self.diverseMealPresets.filter { preset in
            let phaseMatches = preset.phaseID == nil || preset.phaseID == todayPlan.phaseID
            return phaseMatches && preset.trainingGroup == group
        }
        return candidates.randomElement()
    }

    func applyPreset(_ preset: MealPreset, mode: PresetApplyMode, date: Date = Date()) {
        let key = Self.dateFormatter.string(from: date)
        if mode == .overwrite {
            foodEntries.removeAll { $0.dateString == key }
        }

        let libraryByID = Dictionary(uniqueKeysWithValues: foodLibrary.map { ($0.id, $0) })
        let newEntries = preset.meals.flatMap { meal in
            meal.items.compactMap { item -> FoodEntry? in
                guard let food = libraryByID[item.foodItemId] else { return nil }
                let amount = adjustedPresetAmount(item.amount, foodItemID: item.foodItemId, mealType: meal.mealType)
                let macros = food.macros(for: amount)
                return foodEntry(foodItem: food, mealType: meal.mealType, amount: amount, macros: macros, date: date)
            }
        }
        foodEntries.append(contentsOf: newEntries)
        foodEntries.sort { ($0.dateString, $0.mealType.rawValue, $0.foodName) < ($1.dateString, $1.mealType.rawValue, $1.foodName) }
        persistFoodEntries()
    }

    func addModeEstimate(for mode: NutritionDayMode, date: Date = Date()) {
        let foodID: String
        switch mode {
        case .flexible:
            foodID = "business-meal-estimate"
        case .plannedCheat:
            foodID = "planned-cheat-meal"
        case .normal, .missedTraining, .rest:
            return
        }
        guard let food = foodLibrary.first(where: { $0.id == foodID }) else { return }
        addFoodEntry(foodItem: food, mealType: .snack, amount: 1, date: date)
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
        calorieAdjustmentID: String? = nil,
        dayModeID: String? = nil
    ) {
        todayPlan = TodayPlan(
            cycleID: cycleID ?? todayPlan.cycleID,
            trainingDay: trainingDay ?? todayPlan.trainingDay,
            phaseID: phaseID ?? todayPlan.phaseID,
            recipeVariantID: recipeVariantID ?? todayPlan.recipeVariantID,
            calorieAdjustmentID: calorieAdjustmentID ?? todayPlan.calorieAdjustmentID,
            dayModeID: dayModeID ?? todayPlan.dayModeID
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

    private func todayRecordedMealCount(on date: Date = Date()) -> Int {
        let key = Self.dateFormatter.string(from: date)
        return Set(foodEntries.filter { $0.dateString == key }.map(\.mealType)).count
    }

    private func plus100Target(from target: DailyNutritionTarget) -> DailyNutritionTarget {
        DailyNutritionTarget(
            phaseID: target.phaseID,
            trainingType: target.trainingType,
            dietType: target.dietType,
            caloriesTarget: target.caloriesTarget + 100,
            proteinTarget: target.proteinTarget,
            carbsTarget: target.carbsTarget + 25,
            fatTarget: target.fatTarget
        )
    }

    private func adjustedPresetAmount(_ amount: Double, foodItemID: String, mealType: MealType) -> Double {
        guard isPlus100Enabled, mealType == .lunch || mealType == .dinner else {
            return amount
        }
        if foodItemID == "raw-rice" {
            return amount + 15
        }
        if foodItemID == "dry-noodles" {
            return amount + 10
        }
        return amount
    }

    private func foodEntry(
        foodItem: FoodItem,
        mealType: MealType,
        amount: Double,
        macros: FoodMacros,
        date: Date
    ) -> FoodEntry {
        FoodEntry(
            id: UUID().uuidString,
            dateString: Self.dateFormatter.string(from: date),
            foodItemId: foodItem.id,
            foodName: foodItem.name,
            mealType: mealType,
            amount: amount,
            unit: foodItem.unit,
            calculatedCalories: macros.calories,
            calculatedProtein: macros.protein,
            calculatedCarbs: macros.carbs,
            calculatedFat: macros.fat
        )
    }

    private func mealPreset(source: MealPresetSource, variant: MealPresetVariant) -> MealPreset? {
        let group = presetTrainingGroup(for: effectiveNutritionTrainingDay)
        return Self.fixedMealPresets.first { preset in
            preset.source == source &&
            preset.variant == variant &&
            preset.phaseID == todayPlan.phaseID &&
            preset.trainingGroup == group
        }
    }

    private func presetTrainingGroup(for trainingDay: String) -> PresetTrainingGroup {
        switch trainingDay {
        case "肩", "胸":
            return .shoulderChest
        case "背", "腿":
            return .backLegs
        default:
            return .rest
        }
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

        if let data = defaults.data(forKey: foodEntriesKey),
           let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            foodEntries = decoded.sorted { ($0.dateString, $0.mealType.rawValue, $0.foodName) < ($1.dateString, $1.mealType.rawValue, $1.foodName) }
        } else {
            foodEntries = []
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

    private func persistFoodEntries() {
        guard let data = try? JSONEncoder().encode(foodEntries) else { return }
        defaults.set(data, forKey: foodEntriesKey)
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

    private static func food(
        _ id: String,
        _ name: String,
        _ category: FoodCategory,
        _ unit: FoodUnit,
        _ serving: Double,
        _ calories: Double,
        _ protein: Double,
        _ carbs: Double,
        _ fat: Double,
        brandSensitive: Bool = false,
        notes: String = ""
    ) -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            category: category,
            unit: unit,
            defaultServing: serving,
            caloriesPer100: calories,
            proteinPer100: protein,
            carbsPer100: carbs,
            fatPer100: fat,
            isEditable: true,
            isBrandSensitive: brandSensitive,
            notes: notes
        )
    }

    private static func presetMeal(_ mealType: MealType, _ items: [(String, Double)]) -> PresetMeal {
        PresetMeal(
            mealType: mealType,
            items: items.map { PresetFoodAmount(foodItemId: $0.0, amount: $0.1) }
        )
    }

    private static func fixedPreset(
        _ id: String,
        _ name: String,
        phaseID: String,
        group: PresetTrainingGroup,
        variant: MealPresetVariant = .standard,
        breakfast: [(String, Double)],
        lunch: [(String, Double)],
        dinner: [(String, Double)],
        postWorkout: [(String, Double)] = [],
        snack: [(String, Double)]
    ) -> MealPreset {
        var meals = [
            presetMeal(.breakfast, breakfast),
            presetMeal(.lunch, lunch),
            presetMeal(.dinner, dinner)
        ]
        if !postWorkout.isEmpty {
            meals.append(presetMeal(.postWorkout, postWorkout))
        }
        if !snack.isEmpty {
            meals.append(presetMeal(.snack, snack))
        }
        return MealPreset(
            id: id,
            name: name,
            phaseID: phaseID,
            trainingGroup: group,
            variant: variant,
            source: .fixed,
            meals: meals
        )
    }

    private static func diversePreset(
        _ id: String,
        _ name: String,
        group: PresetTrainingGroup,
        variant: MealPresetVariant,
        phaseID: String? = nil,
        breakfast: [(String, Double)],
        lunch: [(String, Double)],
        dinner: [(String, Double)],
        postWorkout: [(String, Double)] = []
    ) -> MealPreset {
        var meals = [
            presetMeal(.breakfast, breakfast),
            presetMeal(.lunch, lunch),
            presetMeal(.dinner, dinner)
        ]
        if !postWorkout.isEmpty {
            meals.append(presetMeal(.postWorkout, postWorkout))
        }
        return MealPreset(
            id: id,
            name: name,
            phaseID: phaseID,
            trainingGroup: group,
            variant: variant,
            source: .diverse,
            meals: meals
        )
    }

    private static let fixedMealPresets: [MealPreset] = [
        fixedPreset(
            "phase0-training-standard",
            "Phase 0｜训练日固定食谱",
            phaseID: "post-cut-1-2",
            group: .shoulderChest,
            breakfast: [("oats", 60), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 10)],
            lunch: [("raw-rice", 100), ("chicken-breast", 220), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 100), ("chicken-breast", 220), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase0-training-standard-back-leg",
            "Phase 0｜训练日固定食谱",
            phaseID: "post-cut-1-2",
            group: .backLegs,
            breakfast: [("oats", 60), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 10)],
            lunch: [("raw-rice", 100), ("chicken-breast", 220), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 100), ("chicken-breast", 220), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase0-rest-standard",
            "Phase 0｜休息日固定食谱",
            phaseID: "post-cut-1-2",
            group: .rest,
            breakfast: [("oats", 50), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("raw-rice", 90), ("chicken-breast", 220), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 90), ("chicken-breast", 220), ("whole-egg", 1), ("mixed-vegetables", 200)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase1-shoulder-chest-standard",
            "Phase 1｜肩 / 胸日固定食谱",
            phaseID: "buffer-3-8",
            group: .shoulderChest,
            breakfast: [("oats", 60), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 10)],
            lunch: [("raw-rice", 110), ("chicken-breast", 220), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 110), ("chicken-breast", 220), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase1-back-leg-standard",
            "Phase 1｜背 / 腿日固定食谱",
            phaseID: "buffer-3-8",
            group: .backLegs,
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 15)],
            lunch: [("raw-rice", 130), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 130), ("chicken-breast", 230), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase1-rest-standard",
            "Phase 1｜休息日固定食谱",
            phaseID: "buffer-3-8",
            group: .rest,
            breakfast: [("oats", 50), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("raw-rice", 90), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 90), ("chicken-breast", 230), ("whole-egg", 2), ("mixed-vegetables", 200)],
            snack: [("cooking-oil", 25)]
        ),
        fixedPreset(
            "phase2-shoulder-chest-standard",
            "Phase 2｜肩 / 胸日固定食谱",
            phaseID: "stable-9-plus",
            group: .shoulderChest,
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 10)],
            lunch: [("raw-rice", 120), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 120), ("chicken-breast", 230), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase2-back-leg-standard",
            "Phase 2｜背 / 腿日固定食谱",
            phaseID: "stable-9-plus",
            group: .backLegs,
            breakfast: [("oats", 80), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 15)],
            lunch: [("raw-rice", 145), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 145), ("chicken-breast", 230), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase2-rest-standard",
            "Phase 2｜休息日固定食谱",
            phaseID: "stable-9-plus",
            group: .rest,
            breakfast: [("oats", 60), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("raw-rice", 100), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 100), ("chicken-breast", 230), ("whole-egg", 2), ("mixed-vegetables", 200)],
            snack: [("cooking-oil", 25)]
        ),
        fixedPreset(
            "phase2-shoulder-chest-beef-ball",
            "Phase 2｜肩 / 胸日｜牛肉丸版",
            phaseID: "stable-9-plus",
            group: .shoulderChest,
            variant: .beefBall,
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 10)],
            lunch: [("raw-rice", 105), ("low-fat-beef-ball", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 105), ("low-fat-beef-ball", 260), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase2-back-leg-beef-ball",
            "Phase 2｜背 / 腿日｜牛肉丸版",
            phaseID: "stable-9-plus",
            group: .backLegs,
            variant: .beefBall,
            breakfast: [("oats", 80), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 15)],
            lunch: [("raw-rice", 130), ("low-fat-beef-ball", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 130), ("low-fat-beef-ball", 260), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)],
            snack: [("cooking-oil", 20)]
        ),
        fixedPreset(
            "phase2-rest-beef-ball",
            "Phase 2｜休息日｜牛肉丸版",
            phaseID: "stable-9-plus",
            group: .rest,
            variant: .beefBall,
            breakfast: [("oats", 60), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("raw-rice", 85), ("low-fat-beef-ball", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 85), ("low-fat-beef-ball", 260), ("whole-egg", 2), ("mixed-vegetables", 200)],
            snack: [("cooking-oil", 25)]
        )
    ]

    private static let diverseMealPresets: [MealPreset] = [
        diversePreset(
            "medium-carb-diverse-a",
            "肩 / 胸日｜中碳多样化版 A",
            group: .shoulderChest,
            variant: .diverseA,
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("blueberry", 100)],
            lunch: [("raw-rice", 120), ("beef-tenderloin", 240), ("broccoli", 200)],
            dinner: [("sweet-potato", 350), ("chicken-breast", 230), ("whole-egg", 1), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)]
        ),
        diversePreset(
            "medium-carb-diverse-b",
            "肩 / 胸日｜中碳多样化版 B",
            group: .shoulderChest,
            variant: .diverseB,
            breakfast: [("bagel", 100), ("greek-yogurt", 200), ("whole-egg", 2), ("blueberry", 100)],
            lunch: [("pasta", 110), ("chicken-breast", 230), ("tomato", 200)],
            dinner: [("potato", 450), ("beef-shank", 260), ("mixed-vegetables", 200)],
            postWorkout: [("protein-powder", 30), ("banana", 100)]
        ),
        diversePreset(
            "high-carb-diverse-a",
            "背 / 腿日｜高碳多样化版 A",
            group: .backLegs,
            variant: .diverseA,
            breakfast: [("oats", 80), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3), ("honey", 15)],
            lunch: [("dry-noodles", 130), ("beef-shank", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 145), ("chicken-breast", 230), ("banana", 100), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)]
        ),
        diversePreset(
            "high-carb-diverse-b",
            "背 / 腿日｜高碳多样化版 B",
            group: .backLegs,
            variant: .diverseB,
            breakfast: [("oats", 70), ("greek-yogurt", 200), ("honey", 15), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("raw-rice", 140), ("pork-tenderloin", 250), ("mixed-vegetables", 200)],
            dinner: [("pasta", 130), ("shrimp", 300), ("tomato", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)]
        ),
        diversePreset(
            "rest-diverse-a",
            "休息日｜中低碳多样化版 A",
            group: .rest,
            variant: .diverseA,
            breakfast: [("oats", 60), ("greek-yogurt", 200), ("whole-egg", 2), ("egg-white", 3), ("blueberry", 100)],
            lunch: [("potato", 400), ("chicken-breast", 230), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 80), ("beef-tenderloin", 240), ("whole-egg", 1), ("mixed-vegetables", 200)]
        ),
        diversePreset(
            "rest-diverse-b",
            "休息日｜中低碳多样化版 B",
            group: .rest,
            variant: .diverseB,
            breakfast: [("whole-egg", 3), ("egg-white", 4), ("toast", 60), ("blueberry", 100)],
            lunch: [("sweet-potato", 300), ("cod", 300), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 80), ("beef-shank", 260), ("mixed-vegetables", 200)]
        ),
        diversePreset(
            "phase2-weekend-beef-ball-noodle",
            "周末口味版｜面条 + 牛肉丸",
            group: .shoulderChest,
            variant: .weekend,
            phaseID: "stable-9-plus",
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("dry-noodles", 110), ("low-fat-beef-ball", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 100), ("chicken-breast", 230), ("blueberry", 100), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)]
        ),
        diversePreset(
            "phase2-weekend-beef-ball-noodle-back-leg",
            "周末口味版｜面条 + 牛肉丸",
            group: .backLegs,
            variant: .weekend,
            phaseID: "stable-9-plus",
            breakfast: [("oats", 70), ("skim-milk", 250), ("whole-egg", 2), ("egg-white", 3)],
            lunch: [("dry-noodles", 110), ("low-fat-beef-ball", 260), ("mixed-vegetables", 200)],
            dinner: [("raw-rice", 100), ("chicken-breast", 230), ("blueberry", 100), ("mixed-vegetables", 200)],
            postWorkout: [("toast", 60), ("protein-powder", 30)]
        )
    ]

    private static let defaultFoodLibrary: [FoodItem] = [
        food("chicken-breast", "鸡小胸 / 鸡胸肉", .protein, .g, 100, 110, 23, 0, 1.5, notes: "生重"),
        food("skinless-chicken-leg", "去皮鸡腿肉", .protein, .g, 100, 130, 19, 0, 6, notes: "生重"),
        food("beef-shank", "牛腱", .protein, .g, 100, 130, 20.5, 0, 4.5, notes: "生重"),
        food("beef-tenderloin", "牛里脊", .protein, .g, 100, 125, 21, 0, 4, notes: "生重"),
        food("lean-ground-beef", "瘦牛肉馅", .protein, .g, 100, 165, 20, 0, 9, notes: "生重"),
        food("pork-tenderloin", "猪里脊", .protein, .g, 100, 125, 21, 0, 4, notes: "生重"),
        food("basa-fish", "巴沙鱼", .protein, .g, 100, 90, 17, 0, 2, notes: "生重"),
        food("cod", "鳕鱼", .protein, .g, 100, 85, 19, 0, 1, notes: "生重"),
        food("salmon", "三文鱼", .protein, .g, 100, 205, 20, 0, 13),
        food("shrimp", "虾仁", .protein, .g, 100, 80, 16, 1, 1),
        food("whole-egg", "全蛋", .protein, .piece, 1, 70, 6.5, 0.5, 5, notes: "1个约50g"),
        food("egg-white", "蛋清", .protein, .piece, 1, 17, 3.8, 0, 0, notes: "1个约30g"),
        food("protein-powder", "蛋白粉", .supplement, .g, 30, 400, 80, 10, 6.7, brandSensitive: true, notes: "按30g=120 kcal / P24 / C3 / F2换算"),
        food("low-fat-beef-ball", "低脂牛肉丸", .protein, .g, 100, 113, 19.8, 4.4, 1.7, brandSensitive: true),
        food("tofu", "豆腐", .protein, .g, 100, 85, 8, 3, 5),
        food("firm-tofu", "北豆腐 / 老豆腐", .protein, .g, 100, 120, 12, 3, 7),
        food("raw-rice", "生米", .carb, .g, 100, 350, 7, 78, 0.8, notes: "生重"),
        food("dry-noodles", "干面条", .carb, .g, 100, 350, 10, 72, 1.5, notes: "干重"),
        food("pasta", "意面", .carb, .g, 100, 360, 12, 72, 1.5, notes: "干重"),
        food("oats", "燕麦", .carb, .g, 100, 380, 12, 66, 7, notes: "干重"),
        food("potato", "土豆", .carb, .g, 100, 80, 2, 17, 0, notes: "生重"),
        food("sweet-potato", "红薯", .carb, .g, 100, 90, 1.5, 21, 0, notes: "生重"),
        food("corn", "玉米", .carb, .g, 100, 110, 3.5, 23, 1.5, notes: "可食部"),
        food("bagel", "贝果", .carb, .g, 100, 260, 10, 52, 2, brandSensitive: true),
        food("toast", "吐司", .carb, .g, 100, 270, 9, 50, 4, brandSensitive: true),
        food("steamed-bun", "馒头", .carb, .g, 100, 235, 7, 48, 1),
        food("banana", "香蕉", .fruit, .g, 100, 90, 1, 22, 0, notes: "可食部"),
        food("honey", "蜂蜜", .carb, .g, 100, 310, 0, 82, 0),
        food("blueberry", "蓝莓", .fruit, .g, 100, 55, 0.7, 14, 0.3),
        food("rice-noodles", "米粉 / 河粉", .carb, .g, 100, 350, 6, 78, 1, brandSensitive: true, notes: "干重或按包装"),
        food("cooking-oil", "食用油", .fat, .g, 100, 900, 0, 0, 100),
        food("olive-oil", "橄榄油", .fat, .g, 100, 900, 0, 0, 100),
        food("peanut-butter", "花生酱", .fat, .g, 100, 600, 23, 20, 50, brandSensitive: true),
        food("nuts", "坚果", .fat, .g, 100, 600, 20, 20, 50, brandSensitive: true),
        food("avocado", "牛油果", .fat, .g, 100, 160, 2, 9, 15),
        food("cheese-slice", "芝士片", .dairy, .g, 100, 320, 20, 4, 25, brandSensitive: true),
        food("skim-milk", "脱脂牛奶", .dairy, .ml, 100, 35, 3.4, 5, 0.2),
        food("low-fat-milk", "低脂牛奶", .dairy, .ml, 100, 50, 3.4, 5, 1.5),
        food("plain-yogurt", "无糖酸奶", .dairy, .g, 100, 65, 5, 6, 2, brandSensitive: true),
        food("greek-yogurt", "希腊酸奶", .dairy, .g, 100, 80, 10, 4, 2, brandSensitive: true),
        food("mixed-vegetables", "蔬菜", .vegetable, .g, 100, 30, 2, 6, 0, notes: "通用蔬菜估算"),
        food("broccoli", "西兰花", .vegetable, .g, 100, 35, 3, 7, 0, notes: "生重"),
        food("spinach", "菠菜", .vegetable, .g, 100, 25, 3, 4, 0, notes: "生重"),
        food("lettuce", "生菜", .vegetable, .g, 100, 15, 1, 3, 0, notes: "生重"),
        food("cucumber", "黄瓜", .vegetable, .g, 100, 15, 1, 3, 0, notes: "生重"),
        food("tomato", "番茄", .vegetable, .g, 100, 20, 1, 4, 0, notes: "生重"),
        food("carrot", "胡萝卜", .vegetable, .g, 100, 40, 1, 9, 0, notes: "生重"),
        food("mushroom", "蘑菇", .vegetable, .g, 100, 25, 3, 4, 0, notes: "生重"),
        food("onion", "洋葱", .vegetable, .g, 100, 40, 1, 9, 0, notes: "生重"),
        food("business-meal-estimate", "应酬餐估算", .mixed, .piece, 1, 800, 30, 80, 35, brandSensitive: true, notes: "1份估算"),
        food("planned-cheat-meal", "计划内放纵餐", .mixed, .piece, 1, 1000, 35, 120, 40, brandSensitive: true, notes: "1份估算")
    ]
}
