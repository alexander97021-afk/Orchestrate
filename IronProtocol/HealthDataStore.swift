import Foundation
import HealthKit

struct HealthSnapshot: Equatable {
    var steps: Double = 0
    var distanceMeters: Double = 0
    var activeEnergyKcal: Double = 0
    var restingHeartRate: Double?
    var sleepMinutes: Double = 0
    var inBedMinutes: Double = 0
    var lastUpdated: Date?
}

@MainActor
final class HealthDataStore: ObservableObject {
    @Published private(set) var snapshot = HealthSnapshot()
    @Published private(set) var isAvailable = HKHealthStore.isHealthDataAvailable()
    @Published private(set) var isAuthorized = false
    @Published private(set) var isLoading = false
    @Published private(set) var statusMessage = "尚未连接 Apple 健康"

    private let healthStore = HKHealthStore()
    private let defaults: UserDefaults
    private let calendar = Calendar.current
    private let hasRequestedAuthorizationKey = "ironprotocol.health.hasRequestedAuthorization"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isAuthorized = defaults.bool(forKey: hasRequestedAuthorizationKey)
        statusMessage = isAuthorized ? "Apple 健康已连接" : "尚未连接 Apple 健康"
    }

    func refreshIfPreviouslyAuthorized() async {
        guard defaults.bool(forKey: hasRequestedAuthorizationKey) else { return }
        await refresh()
    }

    func requestAuthorizationAndRefresh() async {
        guard isAvailable else {
            statusMessage = "当前设备不支持 Apple 健康数据"
            return
        }

        do {
            try await requestAuthorization()
            defaults.set(true, forKey: hasRequestedAuthorizationKey)
            isAuthorized = true
            await refresh()
        } catch {
            isAuthorized = false
            statusMessage = "Apple 健康授权失败，请在系统设置中检查权限"
        }
    }

    func refresh() async {
        guard isAvailable else {
            statusMessage = "当前设备不支持 Apple 健康数据"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            async let steps = quantitySum(.stepCount, unit: .count(), start: startOfToday, end: Date())
            async let distance = quantitySum(.distanceWalkingRunning, unit: .meter(), start: startOfToday, end: Date())
            async let energy = quantitySum(.activeEnergyBurned, unit: .kilocalorie(), start: startOfToday, end: Date())
            async let restingHeartRate = latestQuantity(.restingHeartRate, unit: HKUnit.count().unitDivided(by: .minute()))
            async let sleep = sleepSummary()

            let resolvedSleep = try await sleep
            snapshot = HealthSnapshot(
                steps: try await steps,
                distanceMeters: try await distance,
                activeEnergyKcal: try await energy,
                restingHeartRate: try await restingHeartRate,
                sleepMinutes: resolvedSleep.sleep,
                inBedMinutes: resolvedSleep.inBed,
                lastUpdated: Date()
            )
            isAuthorized = true
            defaults.set(true, forKey: hasRequestedAuthorizationKey)
            statusMessage = "Apple 健康已连接"
        } catch {
            statusMessage = "读取 Apple 健康数据失败，请确认已授权步数和睡眠"
        }
    }

    private var startOfToday: Date {
        calendar.startOfDay(for: Date())
    }

    private var lastNightSleepWindow: (start: Date, end: Date) {
        let today = startOfToday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let start = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday) ?? yesterday
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today) ?? Date()
        return (start, min(Date(), noon))
    }

    private func requestAuthorization() async throws {
        let readTypes = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .restingHeartRate),
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        ].compactMap { $0 })

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                success ? continuation.resume(returning: ()) : continuation.resume(throwing: HealthDataError.authorizationDenied)
            }
        }
    }

    private func quantitySum(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, start: Date, end: Date) async throws -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return 0 }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            healthStore.execute(query)
        }
    }

    private func latestQuantity(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }

    private func sleepSummary() async throws -> (sleep: Double, inBed: Double) {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return (0, 0) }
        let window = lastNightSleepWindow
        let predicate = HKQuery.predicateForSamples(withStart: window.start, end: window.end, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let categorySamples = samples as? [HKCategorySample] ?? []
                let inBedIntervals = categorySamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
                    .compactMap { Self.clampedInterval(for: $0, start: window.start, end: window.end) }
                let asleepIntervals = categorySamples
                    .filter { sample in
                        [
                            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                            HKCategoryValueSleepAnalysis.asleepREM.rawValue
                        ].contains(sample.value)
                    }
                    .compactMap { Self.clampedInterval(for: $0, start: window.start, end: window.end) }

                let asleep = Self.mergedMinutes(from: asleepIntervals)
                let rawInBed = Self.mergedMinutes(from: inBedIntervals)
                let normalizedInBed = Self.normalizedInBedMinutes(rawInBed: rawInBed, asleep: asleep)

                continuation.resume(returning: (asleep, normalizedInBed))
            }
            healthStore.execute(query)
        }
    }

    private static func clampedInterval(for sample: HKCategorySample, start: Date, end: Date) -> DateInterval? {
        let clampedStart = max(sample.startDate, start)
        let clampedEnd = min(sample.endDate, end)
        guard clampedEnd > clampedStart else { return nil }
        return DateInterval(start: clampedStart, end: clampedEnd)
    }

    private static func mergedMinutes(from intervals: [DateInterval]) -> Double {
        let sorted = intervals.sorted { $0.start < $1.start }
        guard var current = sorted.first else { return 0 }
        var merged: [DateInterval] = []

        for interval in sorted.dropFirst() {
            if interval.start <= current.end {
                current = DateInterval(start: current.start, end: max(current.end, interval.end))
            } else {
                merged.append(current)
                current = interval
            }
        }
        merged.append(current)

        return merged.reduce(0) { $0 + $1.duration / 60 }
    }

    private static func normalizedInBedMinutes(rawInBed: Double, asleep: Double) -> Double {
        guard rawInBed > 0 else { return asleep }
        guard asleep > 0 else { return rawInBed }
        return max(asleep, min(rawInBed, asleep + 120))
    }
}

private enum HealthDataError: Error {
    case authorizationDenied
}
