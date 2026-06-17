import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private func dismissKeyboard() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}

private enum AthleteTab: String, CaseIterable {
    case today = "Today"
    case training = "Train"
    case nutrition = "Food"
    case progress = "Progress"
    case templates = "Setup"

    var systemImage: String {
        switch self {
        case .today: return "house"
        case .training: return "square.grid.2x2"
        case .nutrition: return "clock"
        case .progress: return "waveform.path.ecg"
        case .templates: return "gearshape"
        }
    }
}

private enum TrainingDay: String, CaseIterable, Identifiable {
    case shoulders = "肩"
    case back = "背"
    case chest = "胸"
    case legs = "腿"
    case rest = "休息"

    var id: String { rawValue }

    var englishName: String {
        switch self {
        case .shoulders: return "Shoulders"
        case .back: return "Back"
        case .chest: return "Chest"
        case .legs: return "Legs"
        case .rest: return "Rest"
        }
    }
}

private enum NutritionPhase: String, CaseIterable, Identifiable {
    case postCut = "post-cut-1-2"
    case buffer = "buffer-3-8"
    case stableGain = "stable-9-plus"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .postCut: return "1-2周"
        case .buffer: return "3-8周"
        case .stableGain: return "9周+"
        }
    }

    var title: String {
        switch self {
        case .postCut: return "减脂后1-2周"
        case .buffer: return "3-8周缓冲"
        case .stableGain: return "9周后稳定增肌"
        }
    }
}

private struct WorkoutCycle: Identifiable {
    let id: Int
    let name: String
    let dayTemplates: [WorkoutDayTemplate]
}

private struct WorkoutDayTemplate: Identifiable {
    let id = UUID()
    let day: TrainingDay
    let exercises: [ExerciseTemplate]
}

private struct ExerciseTemplate: Identifiable {
    let id: String
    let name: String
    let target: String
    let reps: String
    let weights: String
    let note: String
    let isCombo: Bool

    var setTargets: [String] {
        Self.parseSetTargets(from: reps)
    }

    private static func parseSetTargets(from reps: String) -> [String] {
        let normalized = reps
            .replacingOccurrences(of: "×", with: "x")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if normalized.contains("组") {
            let setCount = Int(normalized.prefix { $0.isNumber }) ?? 1
            let target: String
            if let range = normalized.range(of: "每组") {
                target = String(normalized[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                target = normalized
            }
            return Array(repeating: target.isEmpty ? normalized : target, count: max(setCount, 1))
        }

        let compact = normalized.replacingOccurrences(of: " ", with: "")
        if compact.contains("x") {
            let parts = compact.split(separator: "x").compactMap { Int($0) }
            if parts.count == 2 {
                let first = parts[0]
                let second = parts[1]
                let setCount = first < second ? first : second
                let targetReps = first < second ? second : first
                return Array(repeating: "\(targetReps)", count: max(setCount, 1))
            }
        }

        let slashTargets = normalized
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return slashTargets.isEmpty ? [normalized] : slashTargets
    }
}

private struct MealTemplate: Identifiable {
    let id: String
    let name: String
    let foods: [String]
}

private enum AthleteSeed {
    static let cycles: [WorkoutCycle] = [
        WorkoutCycle(
            id: 1,
            name: "Cycle 1",
            dayTemplates: [
                WorkoutDayTemplate(day: .shoulders, exercises: [
                    exercise("c1-shoulder-db-lateral", "哑铃嘎吱侧平举", "20 / 16 / 12 / 10 / 8", "5 / 6 / 7 / 8 / 9kg"),
                    exercise("c1-shoulder-cable-lateral-front-press", "双臂拉力器过头侧平举 + 坐姿杠铃颈前推举", "12 / 10 / 8", "6 / 6 / 7kg + 35 / 35 / 42kg", combo: true),
                    exercise("c1-shoulder-side-lying-external-rotation", "侧卧哑铃旋外举", "12 / 10 / 8", "10 / 12.5 / 15kg"),
                    exercise("c1-shoulder-bent-single-arm-side-pull", "俯身单臂侧拉", "15 / 12 / 10 / 8", "5 / 6 / 7.5 / 8.5kg"),
                    exercise("c1-shoulder-cable-external-rotation", "龙门旋外拉", "15 / 12 / 10 / 8", "2.5 / 3.5 / 4.5 / 5.5kg"),
                    exercise("c1-shoulder-incline-db-rotation-front-raise", "仰卧哑铃 45 度内外旋转前平举 + 俯身哑铃 45 度前平举", "12 / 10 / 8", "5 / 6 / 7kg + 7 / 8 / 9kg", combo: true),
                    exercise("c1-shoulder-arnold-press", "坐姿哑铃阿诺德推举", "10 x 7", "15 / 15 / 12.5 / 12.5 / 10 / 10 / 10kg"),
                    exercise("c1-shoulder-low-cable-shrug", "低位拉力器耸肩", "12 / 10 / 8", "47.5 / 57.5 / 67.5kg"),
                    exercise("c1-shoulder-seated-row-shrug", "坐姿平拉耸肩", "12 / 10 / 8", "60 / 70 / 80kg"),
                    exercise("c1-shoulder-pulldown-shrug", "高位下拉耸肩", "12 / 10 / 8", "70 / 80 / 90kg"),
                    exercise("c1-shoulder-hanging-leg-raise", "悬垂抬腿", "30 / 25 / 20")
                ]),
                WorkoutDayTemplate(day: .back, exercises: [
                    exercise("c1-back-lat-pulldown-wide", "大宽把高位下拉", "15 / 12 / 10 / 8", "65 / 70 / 75 / 80kg"),
                    exercise("c1-back-cable-squeeze", "龙门夹背", "15 / 12 / 10 / 8", "12 / 15 / 17 / 20kg"),
                    exercise("c1-back-single-arm-db-row", "俯身反向单臂哑铃划船", "12 / 10 / 8", "待记录"),
                    exercise("c1-back-rotating-side-bend-pulldown", "单臂高位沉肩转体侧屈下拉", "12 / 10 / 8", "20 / 25 / 30kg"),
                    exercise("c1-back-cable-rotation-pulldown", "单臂拉力器下拉转体", "12 / 10 / 8", "22 / 25 / 27kg"),
                    exercise("c1-back-tbar-row", "俯身 T 杠划船", "12 / 10 / 8", "40 / 50 / 60kg"),
                    exercise("c1-back-barbell-row-hyperextension", "杠铃划船山羊挺身", "12 / 10 / 8", "小曲杆 15 / 20 / 25kg"),
                    exercise("c1-back-21-curl", "21 响礼炮", "21 / 21 / 21", "25kg"),
                    exercise("c1-back-cable-elbow-curl", "拉力器夹肘弯举", "12 / 10 / 8", "7.5 / 7.5 / 10kg"),
                    exercise("c1-back-elbow-forward-curl", "挺肘弯举", "12 / 10 / 8", "待记录"),
                    exercise("c1-back-preacher-curl", "牧师凳弯举", "12 / 10 / 8", "15 / 20 / 20kg"),
                    exercise("c1-back-reverse-barbell-curl", "杠铃反手弯举", "12 / 10 / 8", "20 / 25 / 30kg")
                ]),
                WorkoutDayTemplate(day: .chest, exercises: [
                    exercise("c1-chest-gachi-bench", "嘎吱卧推", "20 / 16 / 12 / 10 / 8", "待记录"),
                    exercise("c1-chest-fly-incline-pullover", "站姿哑铃夹胸 + 上斜杠铃卧推 + 仰卧屈臂上拉", "12 / 10 / 8", "5 / 7 / 10kg + 50 / 55 / 60kg + 10 / 12 / 15kg", combo: true),
                    exercise("c1-chest-bent-fly-reverse-tbar", "屈体哑铃夹胸 + 反向 T 杠推胸", "12 / 10 / 8", "8 / 9 / 10kg + 20 / 25 / 30kg", combo: true),
                    exercise("c1-chest-decline-bench", "下斜杠铃卧推", "15 / 12 / 10 / 8", "70 / 75 / 80 / 85kg"),
                    exercise("c1-chest-weighted-dip", "双杠臂屈伸负重", "15 / 12 / 10 / 8", "10 / 10 / 15 / 20kg"),
                    exercise("c1-chest-flat-db-internal-press", "平板哑铃内旋卧推", "15 / 12 / 10 / 8", "17.5 / 20 / 22 / 25kg"),
                    exercise("c1-chest-rope-pressdown-abduction", "绳索下压水平外展", "15 / 12 / 10 / 8", "2.5 / 5 / 7.5 / 10kg"),
                    exercise("c1-chest-bent-high-cable-overhead-extension", "俯身高位颈后绳索臂屈伸", "12 / 10 / 8", "17.5 / 20 / 22.5kg"),
                    exercise("c1-chest-close-bench-reverse-pressdown", "平板杠铃窄距离卧推 + 双把手反手下压", "12 / 10 / 8", "待记录", combo: true),
                    exercise("c1-chest-wheel-pressdown-extension", "车轮下压臂屈伸", "12 / 10 / 8", "待记录"),
                    exercise("c1-chest-weighted-crunch", "负重卷腹", "30 / 25 / 20", "15 / 15 / 15kg"),
                    exercise("c1-chest-russian-twist", "俄罗斯大扭转", "30 / 25 / 20")
                ]),
                WorkoutDayTemplate(day: .legs, exercises: [
                    exercise("c1-legs-squat", "杠铃嘎吱深蹲", "20 / 16 / 12 / 10 / 8", "60 / 65 / 70 / 75 / 80kg"),
                    exercise("c1-legs-single-leg-squat", "单腿深蹲", "12 / 10 / 8", "待记录"),
                    exercise("c1-legs-crotch-squat", "胯下蹲起", "12 / 10 / 8", "60 / 70 / 80kg"),
                    exercise("c1-legs-wide-leg-press", "大宽距外八字全程倒蹬", "15 / 12 / 10 / 8", "80 / 90 / 100 / 110kg"),
                    exercise("c1-legs-duck-walk", "矮子步", "50 / 50 / 50"),
                    exercise("c1-legs-prone-single-leg-curl", "俯卧单腿弯举", "12 / 10 / 8", "35 / 42 / 50kg"),
                    exercise("c1-legs-db-stiff-deadlift", "哑铃直腿硬拉", "15 / 12 / 10 / 8", "35 / 40 / 45kg"),
                    exercise("c1-legs-reverse-barbell-stiff-raise", "反向杠铃直腿起", "12 / 10 / 8"),
                    exercise("c1-legs-bent-knee-hyperextension", "屈膝山羊挺身", "12 / 10 / 8"),
                    exercise("c1-legs-sumo-deadlift", "相扑硬拉", "12 / 10 / 8", "60 / 70 / 70kg"),
                    exercise("c1-legs-leg-press-calf-raise", "倒蹬机提踵", "12 / 10 / 8"),
                    exercise("c1-legs-squat-calf-raise", "蹲式提踵", "30 / 25 / 20")
                ])
            ]
        ),
        WorkoutCycle(
            id: 2,
            name: "Cycle 2",
            dayTemplates: [
                WorkoutDayTemplate(day: .shoulders, exercises: [
                    exercise("c2-shoulder-side-lying-cable-lateral", "侧卧上斜单臂拉力器侧平举", "15 / 12 / 10 / 8"),
                    exercise("c2-shoulder-db-overhead-lateral-machine-press", "哑铃过头侧平举 + 坐姿固定器械推举", "15 / 12 / 10 / 8", combo: true),
                    exercise("c2-shoulder-single-arm-side-pull-low-cable-rear-raise", "俯身单臂侧拉 + 低位拉力器后拉翻举", "12 / 10 / 8", combo: true),
                    exercise("c2-shoulder-rear-fly-triple", "俯身哑铃飞鸟上翻举 + 俯身哑铃飞鸟 + 俯身哑铃旋外举", "12 / 10 / 8", combo: true),
                    exercise("c2-shoulder-cable-external-rotation", "龙门旋外拉", "15 / 12 / 10 / 8"),
                    exercise("c2-shoulder-incline-barbell-front-raise-pair", "仰卧上斜杠铃宽握前平举 + 俯卧上斜杠铃宽握前平举", "12 / 10 / 8", combo: true),
                    exercise("c2-shoulder-low-cable-shrug", "低位拉力器耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c2-shoulder-seated-row-shrug", "坐姿平拉耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c2-shoulder-bent-barbell-shrug", "俯身杠铃耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c2-shoulder-pulldown-shrug", "高位下拉耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c2-shoulder-standing-calf-raise", "站姿提踵", "30 / 25 / 20", note: "小腿"),
                    exercise("c2-shoulder-seated-calf-raise", "坐姿提踵", "30 / 25 / 20", note: "小腿")
                ]),
                WorkoutDayTemplate(day: .back, exercises: [
                    exercise("c2-back-wide-grip-pulldown", "大宽距离宽握下拉", "15 / 12 / 10 / 8"),
                    exercise("c2-back-incline-straight-arm-pulldown", "仰卧上斜宽握直臂下拉", "15 / 12 / 10 / 8"),
                    exercise("c2-back-single-arm-high-side-pulldown", "单臂高位侧屈下拉", "15 / 12 / 10 / 8"),
                    exercise("c2-back-single-arm-cable-rotation-pulldown", "单臂拉力器下拉转体", "12 / 10 / 8"),
                    exercise("c2-back-machine-neutral-row-incline-db-row", "坐姿器械对握划船 + 俯卧上斜双臂哑铃划船", "15 / 12 / 10 / 8", combo: true),
                    exercise("c2-back-barbell-row-hyperextension", "杠铃划船山羊挺身", "15 / 12 / 10 / 8"),
                    exercise("c2-back-db-three-way-curl", "哑铃三面弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c2-back-squat-overhead-curl", "蹲式过头弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c2-back-behind-head-adduction-curl", "拉力器头后内收弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c2-back-elbow-forward-curl", "挺肘弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c2-back-rope-curl", "绳索弯举", "12 / 10 / 8", note: "肱二")
                ]),
                WorkoutDayTemplate(day: .chest, exercises: [
                    exercise("c2-chest-incline-barbell-bench", "上斜杠铃卧推", "15 / 12 / 10 / 8"),
                    exercise("c2-chest-standing-db-fly-pullover-press", "站姿哑铃夹胸 + 仰卧屈臂上拉上推", "12 / 10 / 8", combo: true),
                    exercise("c2-chest-flat-db-internal-press", "平板哑铃内旋推胸", "15 / 12 / 10 / 8"),
                    exercise("c2-chest-weighted-dip", "负重双杠臂屈伸", "15 / 12 / 10 / 8"),
                    exercise("c2-chest-seated-machine-press-high-seat", "坐姿器械推胸（坐位调高一些）", "15 / 12 / 10 / 8"),
                    exercise("c2-chest-reverse-tbar-press", "反向 T 杠推胸", "12 / 10 / 8"),
                    exercise("c2-chest-db-three-way-extension", "俯身哑铃三面臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c2-chest-elbow-split-pressdown", "分肘下压臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c2-chest-seated-machine-pressdown", "坐姿器械下压", "12 / 10 / 8", note: "肱三"),
                    exercise("c2-chest-bent-overhead-rope-extension", "俯身颈后绳索臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c2-chest-rope-pressdown-horizontal-abduction", "绳索下压水平外展", "12 / 10 / 8", note: "肱三"),
                    exercise("c2-chest-weighted-crunch", "负重卷腹", "30 / 25 / 20", note: "腹肌"),
                    exercise("c2-chest-hanging-leg-raise", "悬垂抬腿", "30 / 25 / 20", note: "腹肌")
                ]),
                WorkoutDayTemplate(day: .legs, exercises: [
                    exercise("c2-legs-leg-extension-rotation", "坐姿腿屈伸内外旋转", "12 / 10 / 8"),
                    exercise("c2-legs-smith-abduction-squat", "史密斯杠铃外展深蹲", "15 / 12 / 10 / 8"),
                    exercise("c2-legs-barbell-lunge", "杠铃冲步蹲", "12 / 10 / 8"),
                    exercise("c2-legs-single-leg-shuttle-kick", "单腿踢毽子动作", "12 / 10 / 8"),
                    exercise("c2-legs-duck-walk", "矮子步", "3 组，每组单侧 50 步"),
                    exercise("c2-legs-prone-kneeling-leg-curl", "俯卧跪姿腿弯举", "12 / 10 / 8", note: "腘绳肌"),
                    exercise("c2-legs-db-step-stiff-deadlift", "哑铃台阶直腿硬拉", "12 / 10 / 8", note: "腘绳肌"),
                    exercise("c2-legs-bent-knee-hyperextension", "屈膝山羊挺身", "12 / 10 / 8", note: "腘绳肌"),
                    exercise("c2-legs-hip-thrust", "臀推", "12 / 10 / 8", note: "臀部"),
                    exercise("c2-legs-seated-hip-abduction", "坐姿髋外展", "12 / 10 / 8", note: "臀部"),
                    exercise("c2-legs-tbar-reverse-lunge-squat", "T 杠后撤步蹲起", "12 / 10 / 8", note: "臀部")
                ])
            ]
        ),
        WorkoutCycle(
            id: 3,
            name: "Cycle 3",
            dayTemplates: [
                WorkoutDayTemplate(day: .shoulders, exercises: [
                    exercise("c3-shoulder-side-lying-db-lateral", "侧卧上斜双臂哑铃侧平举", "12 / 10 / 8"),
                    exercise("c3-shoulder-db-overhead-lateral-behind-neck-press", "哑铃过头侧平举 + 坐姿杠铃颈后推举", "15 / 12 / 10 / 8", combo: true),
                    exercise("c3-shoulder-single-arm-side-pull-cross-rear-raise", "俯身单臂侧拉 + 低位拉力器交叉后拉翻举", "12 / 10 / 8", combo: true),
                    exercise("c3-shoulder-reverse-v-rear-pull-db-external", "坐姿反手 V 把后拉 + 俯身哑铃旋外举", "12 / 10 / 8", combo: true),
                    exercise("c3-shoulder-cable-external-rotation", "龙门旋外拉", "15 / 12 / 10 / 8"),
                    exercise("c3-shoulder-behind-back-barbell-shrug", "身后杠铃耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c3-shoulder-seated-row-shrug", "坐姿平拉耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c3-shoulder-pulldown-shrug", "高位下拉耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c3-shoulder-donkey-calf-raise", "驴式提踵", "30 / 25 / 20", note: "小腿"),
                    exercise("c3-shoulder-seated-calf-raise", "坐姿提踵", "30 / 25 / 20", note: "小腿")
                ]),
                WorkoutDayTemplate(day: .back, exercises: [
                    exercise("c3-back-opposite-pullup", "对拉引体向上", "12 / 10 / 8"),
                    exercise("c3-back-neutral-pullup", "对握引体向上", "15 / 12 / 10 / 8"),
                    exercise("c3-back-cable-rotation-pulldown", "拉力器下拉转体", "12 / 10 / 8"),
                    exercise("c3-back-incline-db-row", "俯卧上斜双臂哑铃划船", "12 / 10 / 8"),
                    exercise("c3-back-tbar-row", "俯身 T 杠划船", "12 / 10 / 8"),
                    exercise("c3-back-straight-arm-pullup", "直臂引体向上", "12 / 10 / 8"),
                    exercise("c3-back-v-row-hyperextension", "V 把划船山羊挺身", "12 / 10 / 8"),
                    exercise("c3-back-db-three-way-curl", "哑铃三面弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c3-back-high-behind-neck-curl", "高位颈后弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c3-back-cable-adduction-curl", "拉力器内收弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c3-back-bent-single-arm-db-curl", "俯身单臂哑铃弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c3-back-reverse-barbell-curl", "杠铃反手弯举", "12 / 10 / 8", note: "肱二")
                ]),
                WorkoutDayTemplate(day: .chest, exercises: [
                    exercise("c3-chest-low-cable-fly-incline-machine", "低位拉力器夹胸 + 坐姿器械上斜推胸", "12 / 10 / 8", combo: true),
                    exercise("c3-chest-pullover-press", "仰卧屈臂上拉上推", "12 / 10 / 8"),
                    exercise("c3-chest-flat-db-outward-press", "平板哑铃向外推胸", "15 / 12 / 10 / 8"),
                    exercise("c3-chest-weighted-dip", "负重双杠臂屈伸", "15 / 12 / 10 / 8"),
                    exercise("c3-chest-seated-machine-decline-press", "坐姿器械下斜推胸", "15 / 12 / 10 / 8"),
                    exercise("c3-chest-bent-db-fly", "屈体哑铃夹胸", "12 / 10 / 8"),
                    exercise("c3-chest-db-three-way-extension", "俯身哑铃三面臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c3-chest-elbow-split-pressdown", "分肘下压臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c3-chest-incline-barbell-extension", "仰卧上斜杠铃臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c3-chest-dual-handle-reverse-pressdown", "双把手反手下压", "12 / 10 / 8", note: "肱三"),
                    exercise("c3-chest-cross-pressdown-horizontal-abduction", "拉力器交叉下压水平外展", "12 / 10 / 8", note: "肱三"),
                    exercise("c3-chest-dragon-flag", "龙旗", "10 / 10 / 10", note: "腹肌"),
                    exercise("c3-chest-hanging-leg-raise", "悬垂抬腿", "30 / 25 / 20", note: "腹肌")
                ]),
                WorkoutDayTemplate(day: .legs, exercises: [
                    exercise("c3-legs-leg-extension-rotation", "坐姿腿屈伸内外旋转", "15 / 12 / 10 / 8"),
                    exercise("c3-legs-abduction-squat", "外展深蹲", "12 / 10 / 8"),
                    exercise("c3-legs-supine-hip-thrust", "仰卧挺髋起", "12 / 10 / 8"),
                    exercise("c3-legs-side-lying-single-leg-hyperextension", "侧卧单腿山羊挺身", "12 / 10 / 8"),
                    exercise("c3-legs-duck-walk", "矮子步", "3 组，每组单侧 50 步"),
                    exercise("c3-legs-wide-stance-full-leg-press", "宽距离外八字全程倒蹬", "15 / 12 / 10 / 8"),
                    exercise("c3-legs-prone-single-leg-curl", "俯卧单腿弯举", "12 / 10 / 8", note: "腘绳肌"),
                    exercise("c3-legs-barbell-stiff-deadlift", "杠铃直腿硬拉", "15 / 12 / 10 / 8", note: "腘绳肌"),
                    exercise("c3-legs-bent-knee-hyperextension", "屈膝山羊挺身", "12 / 10 / 8", note: "腘绳肌"),
                    exercise("c3-legs-line-hip-thrust-squat", "一字挺髋蹲", "12 / 10 / 8", note: "臀部")
                ])
            ]
        ),
        WorkoutCycle(
            id: 4,
            name: "Cycle 4",
            dayTemplates: [
                WorkoutDayTemplate(day: .shoulders, exercises: [
                    exercise("c4-shoulder-db-lateral-combo-press", "哑铃侧平举 + 坐姿杠铃组合推举", "12 / 10 / 8", note: "下半程颈前，中半程颈后，全程颈前", combo: true),
                    exercise("c4-shoulder-prone-incline-db-front-raise", "俯卧上斜哑铃前平举", "15 / 12 / 10 / 8"),
                    exercise("c4-shoulder-supine-incline-wide-barbell-front-raise", "仰卧上斜杠铃宽握前平举", "12 / 10 / 8"),
                    exercise("c4-shoulder-single-arm-side-pull-cable-lateral", "俯身单臂侧拉 + 单臂拉力器侧平举", "12 / 10 / 8", combo: true),
                    exercise("c4-shoulder-cable-external-rotation", "龙门旋外拉", "15 / 12 / 10 / 8"),
                    exercise("c4-shoulder-rear-fly-upper-fly", "俯身哑铃飞鸟上翻举 + 俯身哑铃飞鸟", "12 / 10 / 8", combo: true),
                    exercise("c4-shoulder-bilateral-cable-overhead-lateral", "双臂拉力器过头侧平举", "7 x 10"),
                    exercise("c4-shoulder-bent-barbell-shrug", "俯身杠铃耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c4-shoulder-high-cable-shrug", "高位拉力器耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c4-shoulder-pulldown-shrug", "高位下拉耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c4-shoulder-straight-arm-pullup-shrug", "直臂引体向上耸肩", "12 / 10 / 8", note: "斜方肌"),
                    exercise("c4-shoulder-standing-db-shrug", "站姿哑铃耸肩", "12 / 10 / 8", note: "斜方肌")
                ]),
                WorkoutDayTemplate(day: .back, exercises: [
                    exercise("c4-back-pullup-9-sets", "引体向上 9 组：正手颈前宽握 / 正手颈后中握 / 对握窄距", "12 / 10 / 8"),
                    exercise("c4-back-single-arm-high-side-pulldown", "单臂高位侧屈下拉", "12 / 10 / 8"),
                    exercise("c4-back-elbow-side-pulldown", "屈肘侧屈下拉", "12 / 10 / 8"),
                    exercise("c4-back-single-arm-cable-rotation-pulldown", "单臂拉力器下拉转体", "12 / 10 / 8"),
                    exercise("c4-back-neutral-tbar-row", "俯身对握 T 杠划船", "12 / 10 / 8"),
                    exercise("c4-back-db-row-hyperextension", "哑铃划船山羊挺身", "15 / 12 / 10 / 8"),
                    exercise("c4-back-high-behind-neck-curl", "高位颈后弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c4-back-overhead-cable-curl", "拉力器过头弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c4-back-preacher-curl", "牧师凳弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c4-back-elbow-forward-curl", "挺肘弯举", "12 / 10 / 8", note: "肱二"),
                    exercise("c4-back-reverse-barbell-curl", "杠铃反手弯举", "12 / 10 / 8", note: "肱二")
                ]),
                WorkoutDayTemplate(day: .chest, exercises: [
                    exercise("c4-chest-incline-barbell-bench", "上斜杠铃卧推", "15 / 12 / 10 / 8"),
                    exercise("c4-chest-pullover", "仰卧屈臂上拉", "12 / 10 / 8"),
                    exercise("c4-chest-flat-db-outward-press", "平板哑铃向外推举", "15 / 12 / 10 / 8"),
                    exercise("c4-chest-bent-db-fly-reverse-tbar", "屈体哑铃夹胸 + 反向 T 杠推胸", "15 / 12 / 10 / 8", combo: true),
                    exercise("c4-chest-weighted-dip", "双杠臂屈伸负重", "15 / 12 / 10 / 8"),
                    exercise("c4-chest-seated-machine-press", "坐姿器械推胸", "15 / 12 / 10 / 8"),
                    exercise("c4-chest-rope-pressdown-abduction", "绳索下压水平外展", "15 / 12 / 10 / 8", note: "肱三"),
                    exercise("c4-chest-behind-back-barbell-extension", "俯身身后杠铃臂屈伸", "12 / 10 / 8", note: "肱三"),
                    exercise("c4-chest-close-grip-bench", "平板杠铃窄距离卧推", "12 / 10 / 8", note: "肱三"),
                    exercise("c4-chest-bent-high-rope-elbow-pressdown", "俯身高位绳索分肘下压", "15 / 12 / 10 / 8", note: "肱三"),
                    exercise("c4-chest-weighted-crunch", "负重卷腹", "30 / 25 / 20", note: "腹部"),
                    exercise("c4-chest-lying-leg-raise", "仰卧抬腿", "30 / 25 / 20", note: "腹部"),
                    exercise("c4-chest-lying-twist-crunch", "仰卧转体卷腹", "15 / 15 / 15", note: "腹部")
                ]),
                WorkoutDayTemplate(day: .legs, exercises: [
                    exercise("c4-legs-behind-neck-squat", "杠铃颈后嘎吱深蹲", "20 / 16 / 12 / 10 / 8"),
                    exercise("c4-legs-lunge", "冲步蹲", "12 / 10 / 8"),
                    exercise("c4-legs-extension-rotation-leg-press", "坐姿腿屈伸内外旋转 + 倒蹬", "12 / 10 / 8", combo: true),
                    exercise("c4-legs-squat-walk", "蹲步走", "3 组，每组单侧 30 步"),
                    exercise("c4-legs-prone-leg-curl", "俯卧腿弯举", "12 / 10 / 8", note: "股二"),
                    exercise("c4-legs-barbell-stiff-deadlift", "杠铃直腿硬拉", "15 / 12 / 10 / 8", note: "股二"),
                    exercise("c4-legs-kneeling-leg-curl", "跪姿腿弯举", "12 / 10 / 8", note: "股二"),
                    exercise("c4-legs-seated-hip-abduction", "坐姿髋外展", "30 / 25 / 20", note: "臀部"),
                    exercise("c4-legs-sumo-deadlift", "相扑硬拉", "12 / 10 / 8", note: "臀部"),
                    exercise("c4-legs-standing-calf-raise", "站姿提踵", "12 / 10 / 8", note: "小腿"),
                    exercise("c4-legs-seated-calf-raise", "坐姿提踵", "12 / 10 / 8", note: "小腿")
                ])
            ]
        )
    ]

    private static func exercise(
        _ id: String,
        _ name: String,
        _ reps: String,
        _ weights: String = "待记录",
        note: String = "",
        combo: Bool = false
    ) -> ExerciseTemplate {
        ExerciseTemplate(
            id: id,
            name: name,
            target: "",
            reps: reps,
            weights: weights,
            note: note.isEmpty ? "模板动作" : note,
            isCombo: combo
        )
    }

    static let meals: [MealTemplate] = [
        MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 70g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 15g"]),
        MealTemplate(id: "lunch", name: "午餐", foods: ["生米 145g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "蔬菜"]),
        MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 145g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "全蛋 1 个"]),
        MealTemplate(id: "post-workout", name: "练后", foods: ["吐司 2 片", "蛋白粉 30g"])
    ]

    static func meals(for day: TrainingDay, phaseID: String) -> [MealTemplate] {
        switch phaseID {
        case "post-cut-1-2":
            if day == .rest {
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 100g", "鸡小胸 220g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 100g", "鸡小胸 220g", "全蛋 1 个", "蔬菜"])
                ]
            }
            return [
                MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                MealTemplate(id: "lunch", name: "午餐", foods: ["生米 100g", "鸡小胸 220g", "蔬菜"]),
                MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 100g", "鸡小胸 220g", "全蛋 1 个", "蔬菜"]),
                MealTemplate(id: "post-workout", name: "练后", foods: ["吐司 2 片", "蛋白粉 30g"])
            ]
        case "stable-9-plus":
            switch day {
            case .shoulders, .chest:
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 70g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 135g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 135g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "全蛋 1 个"]),
                    MealTemplate(id: "post-workout", name: "练后", foods: ["吐司 2 片", "蛋白粉 30g"])
                ]
            case .back, .legs:
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 80g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 15g"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 160g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 160g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "全蛋 1 个"]),
                    MealTemplate(id: "post-workout", name: "练后", foods: ["吐司 2 片", "蛋白粉 30g"])
                ]
            case .rest:
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 110g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 110g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "全蛋 2 个"])
                ]
            }
        default:
            switch day {
            case .shoulders, .chest:
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 125g", "鸡小胸 220g / 牛腱 250g / 牛里脊 235g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 125g", "鸡小胸 220g / 牛腱 250g / 牛里脊 235g", "全蛋 1 个"]),
                    MealTemplate(id: "post-workout", name: "练后", foods: ["吐司 2 片", "蛋白粉 30g"])
                ]
            case .back, .legs:
                return meals
            case .rest:
                return [
                    MealTemplate(id: "breakfast", name: "早餐", foods: ["燕麦 50g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个"]),
                    MealTemplate(id: "lunch", name: "午餐", foods: ["生米 100g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "蔬菜"]),
                    MealTemplate(id: "dinner", name: "晚餐", foods: ["生米 100g", "鸡小胸 230g / 牛腱 260g / 牛里脊 245g", "全蛋 2 个"])
                ]
            }
        }
    }

}

struct IOSRootView: View {
    @State private var selectedTab: AthleteTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayDashboard(selectedTab: $selectedTab)
                .tag(AthleteTab.today)
                .tabItem { Label(AthleteTab.today.rawValue, systemImage: AthleteTab.today.systemImage) }

            TrainingScreen()
                .tag(AthleteTab.training)
                .tabItem { Label(AthleteTab.training.rawValue, systemImage: AthleteTab.training.systemImage) }

            NutritionScreen()
                .tag(AthleteTab.nutrition)
                .tabItem { Label(AthleteTab.nutrition.rawValue, systemImage: AthleteTab.nutrition.systemImage) }

            ProgressScreen()
                .tag(AthleteTab.progress)
                .tabItem { Label(AthleteTab.progress.rawValue, systemImage: AthleteTab.progress.systemImage) }

            TemplatesScreen()
                .tag(AthleteTab.templates)
                .tabItem { Label(AthleteTab.templates.rawValue, systemImage: AthleteTab.templates.systemImage) }
        }
        .tint(IOSTheme.accent)
        .preferredColorScheme(.dark)
    }
}

private struct AppScreen<Content: View>: View {
    let title: String
    let eyebrow: String
    @ViewBuilder var content: Content

    var body: some View {
        NavigationStack {
            ZStack {
                IOSTheme.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(eyebrow.uppercased())
                                .font(.caption.weight(.bold))
                                .foregroundStyle(IOSTheme.softInk)
                            Text(title)
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundStyle(IOSTheme.ink)
                        }
                        content
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        dismissKeyboard()
                    }
                    .font(.headline)
                    .foregroundStyle(IOSTheme.accent)
                }
            }
        }
    }
}

private struct TodayDashboard: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    @Binding var selectedTab: AthleteTab

    var body: some View {
        AppScreen(title: "Today", eyebrow: "6月16日 周二 · Phase 1 · Week 4") {
            TodayPlanPicker()
            HeroCard()
            DashboardGrid {
                selectedTab = .training
            }
            MealCompactCard()
        }
    }
}

private struct HeroCard: View {
    @EnvironmentObject private var dataStore: AthleteDataStore

    private var selectedDay: TrainingDay {
        TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                StatusPill("Cycle \(dataStore.todayPlan.cycleID)")
                Spacer()
                StatusPill(dataStore.todayDietTypeText, color: IOSTheme.accent)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("\(selectedDay.englishName) Day / \(dataStore.todayCaloriesText)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(IOSTheme.ink)
                Text("今日目标：\(dataStore.todayPhaseText) · \(selectedDay == .rest ? "恢复日" : "Cycle \(dataStore.todayPlan.cycleID) \(selectedDay.rawValue)训练") · \(dataStore.todayDietTypeText)模板。")
                    .font(.footnote)
                    .foregroundStyle(IOSTheme.ink.opacity(0.78))
            }
            HStack(spacing: 9) {
                HeroStat(value: dataStore.todayMacroTargets.protein, label: "protein g")
                HeroStat(value: dataStore.todayMacroTargets.carbs, label: "carbs g")
                HeroStat(value: dataStore.todayMacroTargets.fat, label: "fat g")
            }
        }
        .athleteCard(
            radius: 16,
            border: IOSTheme.accent.opacity(0.28),
            fill: IOSTheme.surfaceRaised
        )
        .background(
            LinearGradient(
                colors: [IOSTheme.accent.opacity(0.18), .clear],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
    }
}

private struct TodayPlanPicker: View {
    @EnvironmentObject private var dataStore: AthleteDataStore

    private var selectedDayBinding: Binding<TrainingDay> {
        Binding(
            get: { TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back },
            set: { dataStore.setTodayPlan(trainingDay: $0.rawValue) }
        )
    }

    private var selectedCycleBinding: Binding<Int> {
        Binding(
            get: { dataStore.todayPlan.cycleID },
            set: { dataStore.setTodayPlan(cycleID: $0) }
        )
    }

    private var selectedPhaseBinding: Binding<String> {
        Binding(
            get: { dataStore.todayPlan.phaseID },
            set: { dataStore.setTodayPlan(phaseID: $0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("Today Plan", action: dataStore.todayPhaseText)
            PhaseSelector(selectedPhaseID: selectedPhaseBinding)
            CycleSelector(selectedCycleID: selectedCycleBinding)
            DaySelector(selectedDay: selectedDayBinding)
        }
        .athleteCard(border: IOSTheme.accent.opacity(0.22), fill: IOSTheme.surfaceRaised)
    }
}

private struct DashboardGrid: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    let onStartWorkout: () -> Void

    private var todayTemplate: WorkoutDayTemplate? {
        let selectedDay = TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
        guard selectedDay != .rest else { return nil }
        return AthleteSeed.cycles
            .first { $0.id == dataStore.todayPlan.cycleID }?
            .dayTemplates
            .first { $0.day == selectedDay }
    }

    private var todayDay: TrainingDay {
        TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
    }

    var body: some View {
        VStack(spacing: 10) {
            DashboardCard(
                eyebrow: "Today's Workout",
                title: todayDay == .rest ? "Rest Day" : "C\(dataStore.todayPlan.cycleID) · \(todayDay.rawValue) · \(todayTemplate?.exercises.count ?? 0) 动作",
                description: todayDay == .rest
                    ? "今天不安排力量训练，执行恢复日饮食模板。"
                    : todayTemplate.map {
                        dataStore.latestTrainingSummary(
                            cycleID: dataStore.todayPlan.cycleID,
                            day: todayDay.rawValue,
                            exerciseIDs: $0.exercises.map(\.id)
                        )
                    } ?? "等待补充训练模板。",
                action: todayDay == .rest ? nil : "Start Workout",
                onAction: todayDay == .rest ? nil : onStartWorkout
            )
            HStack(spacing: 10) {
                DashboardCard(
                    eyebrow: "Nutrition",
                    title: "\(dataStore.todayDietTypeText) · \(dataStore.todayNutritionCompletionText)",
                    description: dataStore.todayNutritionCompletionRate >= 1
                        ? "今日饮食模板已完成。"
                        : "\(dataStore.todayCaloriesText)。训练日变化后，饮食类型会跟随切换。"
                )
                DashboardCard(
                    eyebrow: "Body Trend",
                    title: "\(dataStore.formattedWeight(dataStore.sevenDayAverageWeight)) avg",
                    description: "\(dataStore.formattedDelta(dataStore.twoWeekWeightDelta)) · \(dataStore.trendStatusText)。\(dataStore.coachInsightText)"
                )
            }
            HStack(spacing: 10) {
                DashboardCard(eyebrow: "Weekly Execution", title: "3/5 workouts", description: "饮食模板 86%，步数均值 8.2k，放纵餐 0/1。")
                DashboardCard(eyebrow: "Coach Insight", title: "Pending", description: "体重偏低且力量无提升，建议启用 Phase 1 +100 kcal。")
            }
        }
    }
}

private struct MealCompactCard: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    private var meals: [MealTemplate] {
        AthleteSeed.meals(
            for: TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back,
            phaseID: dataStore.todayPlan.phaseID
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            MealRow(meal: meals[0], isDone: dataStore.isMealCompleted(meals[0].id)) {
                dataStore.toggleMeal(meals[0].id)
            }
            Divider().overlay(IOSTheme.line)
            MealRow(meal: meals[1], isDone: dataStore.isMealCompleted(meals[1].id), statusText: "next") {
                dataStore.toggleMeal(meals[1].id)
            }
        }
        .athleteCard()
    }
}

private struct TrainingScreen: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    @State private var selectedCycleID = 1
    @State private var selectedDay: TrainingDay = .back

    private var selectedCycle: WorkoutCycle {
        AthleteSeed.cycles.first { $0.id == selectedCycleID } ?? AthleteSeed.cycles[0]
    }

    private var selectedTemplate: WorkoutDayTemplate? {
        selectedCycle.dayTemplates.first { $0.day == selectedDay }
    }

    var body: some View {
        AppScreen(title: "Training", eyebrow: "Workout Templates") {
            CycleSelector(selectedCycleID: $selectedCycleID)
            DaySelector(selectedDay: $selectedDay)

            if selectedDay == .rest {
                RestDayTrainingCard()
            } else if let selectedTemplate {
                let exerciseIDs = selectedTemplate.exercises.map(\.id)
                TrainingSummaryCard(
                    title: "\(selectedCycle.name) · \(selectedDay.rawValue)",
                    completed: dataStore.completedExerciseCount(
                        cycleID: selectedCycle.id,
                        day: selectedDay.rawValue,
                        exerciseIDs: exerciseIDs
                    ),
                    total: selectedTemplate.exercises.count
                )

                VStack(spacing: 0) {
                    ForEach(selectedTemplate.exercises) { exercise in
                        ExerciseRow(cycleID: selectedCycle.id, day: selectedDay, exercise: exercise)
                        if exercise.id != selectedTemplate.exercises.last?.id {
                            Divider().overlay(IOSTheme.line)
                        }
                    }
                }
                .athleteCard()
            } else {
                PlaceholderCard(
                    title: "\(selectedCycle.name) · \(selectedDay.rawValue) 待补",
                    description: "这里会保留动作、目标次数、重量和备注占位。后续补充计划后，会自动进入训练记录和历史对比。"
                )
            }

            NoteCard("Cycle 1-4 动作模板已录入。当前按每个动作的目标组数逐组记录实际重量和次数；目标肌群暂不作为记录字段。")
        }
        .onAppear {
            selectedCycleID = dataStore.todayPlan.cycleID
            selectedDay = TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
        }
        .onChange(of: selectedCycleID) { newValue in
            dataStore.setTodayPlan(cycleID: newValue, trainingDay: selectedDay.rawValue)
        }
        .onChange(of: selectedDay) { newValue in
            dataStore.setTodayPlan(cycleID: selectedCycleID, trainingDay: newValue.rawValue)
        }
    }
}

private struct RestDayTrainingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rest Day")
                .font(.headline.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
            Text("今天不安排力量训练。保留步数、拉伸、恢复状态和休息日饮食模板。")
                .font(.caption)
                .foregroundStyle(IOSTheme.softInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .athleteCard(border: IOSTheme.green.opacity(0.28), fill: IOSTheme.surfaceRaised)
    }
}

private struct TrainingSummaryCard: View {
    let title: String
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's Log")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(IOSTheme.softInk)
                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Text(total == 0 ? "等待补充训练模板" : "完成 \(completed)/\(total) 个动作")
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
            }
            Spacer()
            CircularProgress(value: total == 0 ? 0 : Double(completed) / Double(total))
        }
        .athleteCard(border: IOSTheme.accent.opacity(0.25), fill: IOSTheme.surfaceRaised)
    }
}

private struct WorkoutLogScreen: View {
    var body: some View {
        AppScreen(title: "高位下拉", eyebrow: "记录训练") {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    StatusPill("背")
                    Spacer()
                    StatusPill("第 1 个动作")
                }
                Text("目标 15 / 12 / 10 / 8")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                Text("上次最高 80kg x 8；今天建议维持或小幅增加最后一组。")
                    .font(.footnote)
                    .foregroundStyle(IOSTheme.softInk)
            }
            .athleteCard(border: IOSTheme.accent.opacity(0.25), fill: IOSTheme.surfaceRaised)

            VStack(alignment: .leading, spacing: 10) {
                SectionHeader("逐组记录", action: "上次数据")
                SetRow(index: 1, weight: "65kg", reps: "15", done: true)
                SetRow(index: 2, weight: "70kg", reps: "12", done: true)
                SetRow(index: 3, weight: "75kg", reps: "10", done: false)
                SetRow(index: 4, weight: "80kg", reps: "8", done: false)
            }

            VStack(spacing: 0) {
                MetricRow(title: "动作备注", value: "沉肩更稳定，最后两组别耸肩", status: "编辑")
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "完成后", value: "自动跳到龙门夹背", status: "下一项")
            }
            .athleteCard()

            Button {
            } label: {
                Text("完成当前动作")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(IOSTheme.accent)
            .foregroundStyle(Color.black)
        }
    }
}

private struct NutritionScreen: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    private var selectedDay: TrainingDay {
        TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
    }
    private var meals: [MealTemplate] {
        AthleteSeed.meals(for: selectedDay, phaseID: dataStore.todayPlan.phaseID)
    }

    var body: some View {
        AppScreen(title: "Nutrition", eyebrow: "Template Nutrition") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ChoiceCard(title: "Phase", value: dataStore.todayPhaseText, active: true)
                ChoiceCard(title: "Carb base", value: "米饭版", active: false)
                ChoiceCard(title: "Day type", value: dataStore.todayDietTypeText, active: true)
                ChoiceCard(title: "Calories", value: dataStore.todayCaloriesText, active: true)
            }

            CoachInsightCard()
            MacroTargetCard(
                calories: dataStore.todayCaloriesText,
                protein: dataStore.todayMacroTargets.protein,
                carbs: dataStore.todayMacroTargets.carbs,
                fat: dataStore.todayMacroTargets.fat
            )

            VStack(spacing: 0) {
                ForEach(meals) { meal in
                    MealRow(meal: meal, isDone: dataStore.isMealCompleted(meal.id)) {
                        dataStore.toggleMeal(meal.id)
                    }
                    if meal.id != meals.last?.id {
                        Divider().overlay(IOSTheme.line)
                    }
                }
            }
            .athleteCard()

            NoteCard("如果下周腰围增长过快，系统会优先建议回调休息日碳水，而不是直接降低训练日摄入。")
        }
    }
}

private struct ProgressScreen: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    @State private var weightText = ""
    @State private var waistText = ""

    var body: some View {
        AppScreen(title: "Trend", eyebrow: "Progress") {
            BodyInputCard(weightText: $weightText, waistText: $waistText) {
                dataStore.saveToday(weightText: weightText, waistText: waistText)
            }

            HStack(spacing: 10) {
                RecordBox(title: "今日空腹体重", value: dataStore.formattedWeight(dataStore.todayEntry?.weightKg), note: "每天记录")
                RecordBox(title: "本周腰围", value: dataStore.formattedWaist(dataStore.latestWaist), note: "每周一次")
            }

            WeightChart(points: dataStore.chartPoints)

            VStack(spacing: 0) {
                MetricRow(
                    title: "Body Weight Trend",
                    value: "7 日平均 \(dataStore.formattedWeight(dataStore.sevenDayAverageWeight))",
                    status: dataStore.formattedDelta(dataStore.twoWeekWeightDelta),
                    statusColor: dataStore.trendStatusText == "正常" ? IOSTheme.green : IOSTheme.amber
                )
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "2 Week Delta", value: dataStore.formattedDelta(dataStore.twoWeekWeightDelta), status: dataStore.trendStatusText, statusColor: dataStore.trendStatusText == "正常" ? IOSTheme.green : IOSTheme.amber)
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "Performance", value: "主要动作无明显提升", status: "观察", statusColor: IOSTheme.amber)
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "Gain Rate", value: dataStore.formattedGainRate(dataStore.monthlyGainRate), status: "月速率", statusColor: IOSTheme.amber)
            }
            .athleteCard()

            CoachInsightCard(text: dataStore.coachInsightText)
            PlaceholderCard(title: "Phase Timeline", description: "Cut End -> Phase 1 -> +100 kcal。确认调整后，时间线会标记为 +100 kcal adjustment。", ready: true)
            PlaceholderCard(title: "Physique Gallery", description: "每周照片占位：正面 / 侧面 / 背面 / 自媒体精选照。")
        }
        .onAppear {
            weightText = dataStore.todayEntry?.weightKg.map { String(format: "%.1f", $0) } ?? ""
            waistText = dataStore.todayEntry?.waistCm.map { String(format: "%.1f", $0) } ?? ""
        }
    }
}

private struct TemplatesScreen: View {
    var body: some View {
        AppScreen(title: "Templates", eyebrow: "Setup") {
            ForEach(AthleteSeed.cycles) { cycle in
                let exerciseCount = cycle.dayTemplates.reduce(0) { $0 + $1.exercises.count }
                PlaceholderCard(
                    title: "\(cycle.name) 已录入",
                    description: "肩、背、胸、腿共 \(exerciseCount) 个动作。训练时可按组填写实际重量、次数和动作备注。",
                    ready: true
                )
            }

            PlaceholderCard(
                title: "Nutrition Templates",
                description: "Phase 0 / Phase 1 / Phase 1 +100 kcal / Phase 2 / Phase 2 +100 kcal 将在这里编辑。"
            )
        }
    }
}

private struct PhaseSelector: View {
    @Binding var selectedPhaseID: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(NutritionPhase.allCases) { phase in
                Button {
                    selectedPhaseID = phase.rawValue
                } label: {
                    VStack(spacing: 3) {
                        Text(phase.label)
                            .font(.caption.weight(.heavy))
                        Text(phase.title)
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(selectedPhaseID == phase.rawValue ? IOSTheme.accent.opacity(0.12) : IOSTheme.surface)
                    .foregroundStyle(selectedPhaseID == phase.rawValue ? IOSTheme.ink : IOSTheme.softInk)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selectedPhaseID == phase.rawValue ? IOSTheme.accent.opacity(0.5) : IOSTheme.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CycleSelector: View {
    @Binding var selectedCycleID: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AthleteSeed.cycles) { cycle in
                Button {
                    selectedCycleID = cycle.id
                } label: {
                    VStack(spacing: 3) {
                        Text("C\(cycle.id)")
                            .font(.caption.weight(.heavy))
                        Text("\(cycle.dayTemplates.reduce(0) { $0 + $1.exercises.count })项")
                            .font(.caption2.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(selectedCycleID == cycle.id ? IOSTheme.accent.opacity(0.12) : IOSTheme.surface)
                    .foregroundStyle(selectedCycleID == cycle.id ? IOSTheme.ink : IOSTheme.softInk)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selectedCycleID == cycle.id ? IOSTheme.accent.opacity(0.5) : IOSTheme.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct DaySelector: View {
    @Binding var selectedDay: TrainingDay

    var body: some View {
        Picker("训练日", selection: $selectedDay) {
            ForEach(TrainingDay.allCases) { day in
                Text(day.rawValue).tag(day)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct DashboardCard: View {
    let eyebrow: String
    let title: String
    let description: String
    var action: String?
    var onAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            Text(title)
                .font(.headline.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
            Text(description)
                .font(.caption)
                .foregroundStyle(IOSTheme.softInk)
                .fixedSize(horizontal: false, vertical: true)
            if let action {
                Button {
                    onAction?()
                } label: {
                    Text(action)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(IOSTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .athleteCard()
    }
}

private struct ExerciseRow: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    let cycleID: Int
    let day: TrainingDay
    let exercise: ExerciseTemplate
    @State private var setLogs: [ExerciseSetLog] = []
    @State private var note = ""
    @State private var isDone = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(IOSTheme.ink)
                Spacer()
                if exercise.isCombo {
                    StatusPill("Combo", color: IOSTheme.amber)
                }
            }
            HStack(spacing: 8) {
                MetaPill(exercise.target)
                MetaPill(exercise.reps)
                MetaPill(exercise.weights)
            }
            Text(exercise.note)
                .font(.caption)
                .foregroundStyle(IOSTheme.softInk)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text("SET")
                        .frame(width: 34, alignment: .leading)
                    Text("目标")
                        .frame(width: 58, alignment: .leading)
                    Text("重量")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("次数")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("")
                        .frame(width: 30)
                }
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)

                ForEach(setLogs.indices, id: \.self) { index in
                    TrainingSetLogRow(
                        index: index,
                        setLog: Binding(
                            get: { setLogs[index] },
                            set: { setLogs[index] = $0 }
                        )
                    )
                }
            }
            .padding(8)
            .background(IOSTheme.background.opacity(0.46))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            TextField("备注，例如最后一组状态 / 动作感觉", text: $note)
                .font(.caption.weight(.semibold))
                .foregroundStyle(IOSTheme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(IOSTheme.background.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack(spacing: 10) {
                Button {
                    let nextDoneState = !isDone
                    isDone = nextDoneState
                    setLogs = setLogs.map {
                        ExerciseSetLog(
                            id: $0.id,
                            targetReps: $0.targetReps,
                            weightText: $0.weightText,
                            repsText: $0.repsText,
                            isDone: nextDoneState
                        )
                    }
                    save()
                    dismissKeyboard()
                } label: {
                    Label(isDone ? "Completed" : "Mark Done", systemImage: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(isDone ? Color.black : IOSTheme.ink)
                .background(isDone ? IOSTheme.green : IOSTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Button {
                    save()
                    dismissKeyboard()
                } label: {
                    Text("Save")
                        .font(.caption.weight(.heavy))
                        .frame(width: 74)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.black)
                .background(IOSTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(.vertical, 10)
        .onAppear(perform: syncFromStore)
        .onChange(of: dataStore.exerciseLogs) { _ in
            syncFromStore()
        }
    }

    private func syncFromStore() {
        let log = dataStore.exerciseLog(cycleID: cycleID, day: day.rawValue, exerciseID: exercise.id)
        setLogs = mergedSetLogs(stored: log.setLogs)
        note = log.note
        isDone = log.isDone || (!setLogs.isEmpty && setLogs.allSatisfy(\.isDone))
    }

    private func save() {
        isDone = !setLogs.isEmpty && setLogs.allSatisfy(\.isDone)
        dataStore.saveExerciseLog(
            cycleID: cycleID,
            day: day.rawValue,
            exerciseID: exercise.id,
            setLogs: setLogs,
            note: note,
            isDone: isDone
        )
    }

    private func mergedSetLogs(stored: [ExerciseSetLog]) -> [ExerciseSetLog] {
        let targets = exercise.setTargets
        return targets.indices.map { index in
            let storedSet = index < stored.count ? stored[index] : nil
            return ExerciseSetLog(
                id: "set-\(index + 1)",
                targetReps: targets[index],
                weightText: storedSet?.weightText ?? "",
                repsText: storedSet?.repsText ?? "",
                isDone: storedSet?.isDone ?? false
            )
        }
    }
}

private struct TrainingSetLogRow: View {
    let index: Int
    @Binding var setLog: ExerciseSetLog

    var body: some View {
        HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
                .frame(width: 34, height: 30)
                .background(IOSTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(setLog.targetReps)
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
                .frame(width: 58, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            TextField("kg", text: $setLog.weightText)
                .keyboardType(.numbersAndPunctuation)
                .trainingSetInputStyle()

            TextField("reps", text: $setLog.repsText)
                .keyboardType(.numbersAndPunctuation)
                .trainingSetInputStyle()

            Button {
                setLog.isDone.toggle()
                dismissKeyboard()
            } label: {
                Image(systemName: setLog.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(setLog.isDone ? IOSTheme.green : IOSTheme.softInk)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
    }
}

private extension View {
    func trainingSetInputStyle() -> some View {
        self
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(IOSTheme.ink)
            .padding(.horizontal, 9)
            .padding(.vertical, 8)
            .background(IOSTheme.background.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

private struct LogInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(IOSTheme.softInk)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
                .padding(.horizontal, 9)
                .padding(.vertical, 8)
                .background(IOSTheme.background.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MealRow: View {
    let meal: MealTemplate
    let isDone: Bool
    var statusText: String?
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.title3.weight(.semibold))
                    .foregroundStyle(isDone ? IOSTheme.green : IOSTheme.softInk)
                VStack(alignment: .leading, spacing: 5) {
                    Text(meal.name)
                        .font(.headline)
                        .foregroundStyle(IOSTheme.ink)
                    Text(meal.foods.joined(separator: " / "))
                        .font(.caption)
                        .foregroundStyle(IOSTheme.softInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Text(statusText ?? (isDone ? "done" : "待吃"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isDone ? IOSTheme.green : IOSTheme.softInk)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
    }
}

private struct MacroTargetCard: View {
    var calories = "2750 kcal"
    var protein = "P 185"
    var carbs = "C 335"
    var fat = "F 55"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Target")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            Text(calories)
                .font(.title3.weight(.heavy))
            MacroBar(label: "P", value: protein.replacingOccurrences(of: "P ", with: "") + "g", progress: 0.68)
            MacroBar(label: "C", value: carbs.replacingOccurrences(of: "C ", with: "") + "g", progress: 0.54)
            MacroBar(label: "F", value: fat.replacingOccurrences(of: "F ", with: "") + "g", progress: 0.42)
        }
        .athleteCard()
    }
}

private struct MacroBar: View {
    let label: String
    let value: String
    let progress: Double

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
                .frame(width: 18, alignment: .leading)
            ProgressView(value: progress)
                .tint(IOSTheme.accent)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(IOSTheme.ink)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

private struct CircularProgress: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(IOSTheme.line, lineWidth: 8)
            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(IOSTheme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(value * 100))%")
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
        }
        .frame(width: 58, height: 58)
    }
}

private struct BodyInputCard: View {
    @Binding var weightText: String
    @Binding var waistText: String
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Check-in")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            HStack(spacing: 10) {
                DataInputField(title: "空腹体重 kg", text: $weightText)
                DataInputField(title: "腰围 cm", text: $waistText)
            }
            Button {
                onSave()
                dismissKeyboard()
            } label: {
                Text("保存今日数据")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(IOSTheme.accent)
            .foregroundStyle(Color.black)
        }
        .athleteCard(border: IOSTheme.accent.opacity(0.25), fill: IOSTheme.surfaceRaised)
    }
}

private struct DataInputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(IOSTheme.softInk)
            TextField("--", text: $text)
                .keyboardType(.decimalPad)
                .font(.title3.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(IOSTheme.background.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WeightChart: View {
    let points: [BodyMetricPoint]
    private var minValue: Double { (points.map(\.value).min() ?? 71) - 0.2 }
    private var maxValue: Double { (points.map(\.value).max() ?? 73) + 0.2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Body Weight Trend")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            if points.isEmpty {
                Text("记录体重后，这里会显示每日体重和最近 7 天趋势。")
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            } else {
                HStack(alignment: .bottom, spacing: 9) {
                    ForEach(points) { point in
                        VStack(spacing: 7) {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(point.isToday ? IOSTheme.accent : IOSTheme.accent.opacity(0.28))
                                .frame(height: barHeight(for: point.value))
                            Text(point.day)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(IOSTheme.softInk)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 140, alignment: .bottom)
            }
        }
        .athleteCard()
    }

    private func barHeight(for value: Double) -> CGFloat {
        let range = max(maxValue - minValue, 0.1)
        let normalized = (value - minValue) / range
        return CGFloat(44 + normalized * 78)
    }
}

private struct SetRow: View {
    let index: Int
    let weight: String
    let reps: String
    let done: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text("\(index)")
                .font(.caption.weight(.heavy))
                .frame(width: 30, height: 30)
                .background(IOSTheme.surfaceRaised)
                .clipShape(Circle())
            FieldBox(title: "重量", value: weight)
            FieldBox(title: "次数", value: reps)
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(done ? IOSTheme.green : IOSTheme.softInk)
        }
        .padding(9)
        .background(IOSTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(IOSTheme.line, lineWidth: 1)
        )
    }
}

private struct FieldBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(IOSTheme.softInk)
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(IOSTheme.background.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct MetricRow: View {
    let title: String
    let value: String
    let status: String
    var statusColor: Color = IOSTheme.accent

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
                Text(value)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
            }
            Spacer()
            Text(status)
                .font(.caption.weight(.heavy))
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 10)
    }
}

private struct RecordBox: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
            Text(note)
                .font(.caption2)
                .foregroundStyle(IOSTheme.softInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .athleteCard()
    }
}

private struct ChoiceCard: View {
    let title: String
    let value: String
    let active: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .athleteCard(
            border: active ? IOSTheme.accent.opacity(0.45) : IOSTheme.line,
            fill: active ? IOSTheme.accent.opacity(0.08) : IOSTheme.surface
        )
    }
}

private struct CoachInsightCard: View {
    var text = "两周均重增长偏低，建议启用 Phase 1 背/腿 +100 kcal 米饭版；点击确认后再套用。"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Coach Insight")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
            }
            Spacer()
            StatusPill("Confirm", color: IOSTheme.amber)
        }
        .athleteCard(border: IOSTheme.amber.opacity(0.35), fill: IOSTheme.amber.opacity(0.10))
    }
}

private struct PlaceholderCard: View {
    let title: String
    let description: String
    var ready = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(ready ? "Ready" : "Placeholder")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(IOSTheme.softInk)
            Text(title)
                .font(.headline.weight(.heavy))
            Text(description)
                .font(.caption)
                .foregroundStyle(IOSTheme.softInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .athleteCard(
            border: ready ? IOSTheme.line : IOSTheme.line.opacity(0.8),
            fill: ready ? IOSTheme.surface : IOSTheme.surface.opacity(0.72)
        )
    }
}

private struct NoteCard: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(IOSTheme.amber)
            .frame(maxWidth: .infinity, alignment: .leading)
            .athleteCard(border: IOSTheme.amber.opacity(0.32), fill: IOSTheme.amber.opacity(0.10))
    }
}

private struct HeroStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.heavy))
            Text(label)
                .font(.caption2)
                .foregroundStyle(IOSTheme.ink.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct StatusPill: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = IOSTheme.ink.opacity(0.16)) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.heavy))
            .foregroundStyle(color == IOSTheme.ink.opacity(0.16) ? IOSTheme.ink : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(color.opacity(0.16))
            .clipShape(Capsule())
    }
}

private struct MetaPill: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(IOSTheme.softInk)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(IOSTheme.background.opacity(0.72))
            .clipShape(Capsule())
    }
}

private struct SectionHeader: View {
    let title: String
    let action: String

    init(_ title: String, action: String) {
        self.title = title
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.heavy))
            Spacer()
            Text(action)
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.accent)
        }
    }
}

#Preview("Orchestrate App") {
    IOSRootView()
        .environmentObject(AthleteDataStore(defaults: .standard))
}

#Preview("Today") {
    TodayDashboard(selectedTab: .constant(.today))
        .environmentObject(AthleteDataStore(defaults: .standard))
}

#Preview("Training") {
    TrainingScreen()
        .environmentObject(AthleteDataStore(defaults: .standard))
}

#Preview("Nutrition") {
    NutritionScreen()
        .environmentObject(AthleteDataStore(defaults: .standard))
}

#Preview("Progress") {
    ProgressScreen()
        .environmentObject(AthleteDataStore(defaults: .standard))
}
