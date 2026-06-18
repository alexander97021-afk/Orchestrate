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
    case today = "今日"
    case training = "训练"
    case nutrition = "饮食"
    case progress = "趋势"
    case templates = "设置"

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
        case .shoulders: return "肩"
        case .back: return "背"
        case .chest: return "胸"
        case .legs: return "腿"
        case .rest: return "休息"
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

private enum RecipeVariant: String, CaseIterable, Identifiable {
    case chicken = "chicken"
    case beef = "beef"
    case beefBall = "beef-ball"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .chicken: return "纯鸡胸"
        case .beef: return "带牛肉"
        case .beefBall: return "牛肉丸"
        }
    }
}

private enum CalorieAdjustment: String, CaseIterable, Identifiable {
    case base = "base"
    case plus100 = "plus-100"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .base: return "标准"
        case .plus100: return "+100 kcal"
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
            name: "C1",
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
            name: "C2",
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
            name: "C3",
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
            name: "C4",
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

    static func meals(
        for day: TrainingDay,
        phaseID: String,
        variantID: String,
        calorieAdjustmentID: String
    ) -> [MealTemplate] {
        let variant = RecipeVariant(rawValue: variantID) ?? .chicken
        let resolvedVariant = phaseID == "stable-9-plus" ? variant : (variant == .beefBall ? .beef : variant)
        let needsPlus100 = calorieAdjustmentID == CalorieAdjustment.plus100.rawValue
        let idPrefix = "\(phaseID)-\(day.rawValue)-\(resolvedVariant.rawValue)-\(calorieAdjustmentID)"
        let meals: [MealTemplate]

        switch phaseID {
        case "post-cut-1-2":
            if day == .rest {
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    meal(idPrefix, "lunch", "午餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "蔬菜"]),
                    meal(idPrefix, "dinner", "晚餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "全蛋 1 个", "蔬菜"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            }
            meals = [
                meal(idPrefix, "breakfast", "早餐", ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                meal(idPrefix, "lunch", "午餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "蔬菜"]),
                meal(idPrefix, "dinner", "晚餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "全蛋 1 个", "蔬菜"]),
                meal(idPrefix, "post-workout", "练后", ["吐司 2 片", "蛋白粉 30g"])
            ]
            return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
        case "stable-9-plus":
            switch day {
            case .shoulders, .chest:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 70g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    meal(idPrefix, "lunch", "午餐", stableLunchDinnerFoods(rice: 120, beefBallRice: 105, variant: resolvedVariant, includesEgg: false)),
                    meal(idPrefix, "dinner", "晚餐", stableLunchDinnerFoods(rice: 120, beefBallRice: 105, variant: resolvedVariant, includesEgg: true, oil: "20g")),
                    meal(idPrefix, "post-workout", "练后", ["吐司 2 片", "蛋白粉 30g"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            case .back, .legs:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 80g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 15g"]),
                    meal(idPrefix, "lunch", "午餐", stableLunchDinnerFoods(rice: 145, beefBallRice: 130, variant: resolvedVariant, includesEgg: false)),
                    meal(idPrefix, "dinner", "晚餐", stableLunchDinnerFoods(rice: 145, beefBallRice: 130, variant: resolvedVariant, includesEgg: true, oil: "20g")),
                    meal(idPrefix, "post-workout", "练后", ["吐司 2 片", "蛋白粉 30g"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            case .rest:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个"]),
                    meal(idPrefix, "lunch", "午餐", stableLunchDinnerFoods(rice: 100, beefBallRice: 85, variant: resolvedVariant, includesEgg: false)),
                    meal(idPrefix, "dinner", "晚餐", stableLunchDinnerFoods(rice: 100, beefBallRice: 85, variant: resolvedVariant, includesEgg: true, eggCount: 2, oil: "25g"))
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            }
        default:
            switch day {
            case .shoulders, .chest:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 60g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 10g"]),
                    meal(idPrefix, "lunch", "午餐", ["生米 125g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "蔬菜"]),
                    meal(idPrefix, "dinner", "晚餐", ["生米 125g", protein(for: resolvedVariant, chicken: "鸡小胸 220g", beef: "牛腱 250g / 牛里脊 235g"), "全蛋 1 个", "蔬菜"]),
                    meal(idPrefix, "post-workout", "练后", ["吐司 2 片", "蛋白粉 30g"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            case .back, .legs:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 70g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个", "蜂蜜 15g"]),
                    meal(idPrefix, "lunch", "午餐", ["生米 145g", protein(for: resolvedVariant, chicken: "鸡小胸 230g", beef: "牛腱 260g / 牛里脊 245g"), "蔬菜"]),
                    meal(idPrefix, "dinner", "晚餐", ["生米 145g", protein(for: resolvedVariant, chicken: "鸡小胸 230g", beef: "牛腱 260g / 牛里脊 245g"), "全蛋 1 个", "蔬菜"]),
                    meal(idPrefix, "post-workout", "练后", ["吐司 2 片", "蛋白粉 30g"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            case .rest:
                meals = [
                    meal(idPrefix, "breakfast", "早餐", ["燕麦 50g", "脱脂奶 250ml", "全蛋 2 个", "蛋清 3 个"]),
                    meal(idPrefix, "lunch", "午餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 230g", beef: "牛腱 260g / 牛里脊 245g"), "蔬菜"]),
                    meal(idPrefix, "dinner", "晚餐", ["生米 100g", protein(for: resolvedVariant, chicken: "鸡小胸 230g", beef: "牛腱 260g / 牛里脊 245g"), "全蛋 2 个", "蔬菜"])
                ]
                return applyCalorieAdjustmentIfNeeded(meals, needsPlus100: needsPlus100)
            }
        }
    }

    private static func meal(_ prefix: String, _ id: String, _ name: String, _ foods: [String]) -> MealTemplate {
        MealTemplate(id: "\(prefix)-\(id)", name: name, foods: foods)
    }

    private static func protein(for variant: RecipeVariant, chicken: String, beef: String) -> String {
        switch variant {
        case .chicken:
            return chicken
        case .beef, .beefBall:
            return beef
        }
    }

    private static func stableLunchDinnerFoods(
        rice: Int,
        beefBallRice: Int,
        variant: RecipeVariant,
        includesEgg: Bool,
        eggCount: Int = 1,
        oil: String? = nil
    ) -> [String] {
        var foods: [String]
        switch variant {
        case .beefBall:
            foods = ["生米 \(beefBallRice)g", "牛肉丸 260g"]
        case .beef:
            foods = ["生米 \(rice)g", "牛腱 260g / 牛里脊 245g"]
        case .chicken:
            foods = ["生米 \(rice)g", "鸡小胸 230g"]
        }
        if includesEgg {
            foods.append("全蛋 \(eggCount) 个")
        }
        foods.append("蔬菜")
        if let oil {
            foods.append("用油 \(oil)")
        }
        return foods
    }

    private static func applyCalorieAdjustmentIfNeeded(_ meals: [MealTemplate], needsPlus100: Bool) -> [MealTemplate] {
        guard needsPlus100 else { return meals }
        return meals.map { meal in
            guard meal.name == "午餐" else { return meal }
            return MealTemplate(
                id: meal.id,
                name: meal.name,
                foods: meal.foods + ["+100 kcal：午/晚餐合计加生米 25g"]
            )
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
        AppScreen(title: "今日", eyebrow: "今日训练与饮食") {
            TodayPlanPicker()
            HeroCard()
            DashboardGrid {
                selectedTab = .training
            }
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
                StatusPill("C\(dataStore.todayPlan.cycleID)")
                Spacer()
                StatusPill(dataStore.todayDietTypeText, color: IOSTheme.accent)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("\(selectedDay.rawValue)日 / \(dataStore.todayCaloriesText)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(IOSTheme.ink)
                Text("今日目标：\(dataStore.todayPhaseText) · \(selectedDay == .rest ? "恢复日" : "C\(dataStore.todayPlan.cycleID) \(selectedDay.rawValue)训练") · \(dataStore.todayDietTypeText) · \(dataStore.todayRecipeVariantText) · \(dataStore.todayCalorieAdjustmentText)。")
                    .font(.footnote)
                    .foregroundStyle(IOSTheme.ink.opacity(0.78))
            }
            HStack(spacing: 9) {
                HeroStat(value: dataStore.todayMacroTargets.protein, label: "蛋白质 g")
                HeroStat(value: dataStore.todayMacroTargets.carbs, label: "碳水 g")
                HeroStat(value: dataStore.todayMacroTargets.fat, label: "脂肪 g")
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
            SectionHeader("今日计划", action: dataStore.todayPhaseText)
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
                eyebrow: "今日训练",
                title: todayDay == .rest ? "休息日" : "C\(dataStore.todayPlan.cycleID) · \(todayDay.rawValue) · \(todayTemplate?.exercises.count ?? 0) 动作",
                description: todayDay == .rest
                    ? "今天不安排力量训练，执行恢复日饮食模板。"
                    : todayTemplate.map {
                        dataStore.latestTrainingSummary(
                            cycleID: dataStore.todayPlan.cycleID,
                            day: todayDay.rawValue,
                            exerciseIDs: $0.exercises.map(\.id)
                        )
                    } ?? "等待补充训练模板。",
                action: todayDay == .rest ? nil : "开始训练",
                onAction: todayDay == .rest ? nil : onStartWorkout
            )
            HStack(spacing: 10) {
                DashboardCard(
                    eyebrow: "饮食",
                    title: "\(dataStore.todayNutritionLog.target.dietType) · \(dataStore.todayCalorieAdjustmentText)",
                    description: "\(dataStore.todayNutritionLog.entries.count) 项记录 · \(Int(dataStore.todayNutritionLog.totalCalories.rounded())) / \(Int(dataStore.todayNutritionLog.target.caloriesTarget)) kcal。到 Nutrition 执行食谱或记录实际摄入。"
                )
                DashboardCard(
                    eyebrow: "身体趋势",
                    title: "\(dataStore.formattedWeight(dataStore.sevenDayAverageWeight)) 均重",
                    description: "\(dataStore.formattedDelta(dataStore.twoWeekWeightDelta)) · \(dataStore.trendStatusText)。\(dataStore.coachInsightText)"
                )
            }
            HStack(spacing: 10) {
                DashboardCard(eyebrow: "本周执行", title: "3/5 次训练", description: "饮食模板 86%，步数均值 8.2k，放纵餐 0/1。")
                DashboardCard(eyebrow: "教练建议", title: "待判断", description: "体重偏低且力量无提升，建议启用当前阶段 +100 kcal。")
            }
        }
    }
}

private struct MealCompactCard: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    private var meals: [MealTemplate] {
        AthleteSeed.meals(
            for: TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back,
            phaseID: dataStore.todayPlan.phaseID,
            variantID: dataStore.todayPlan.recipeVariantID,
            calorieAdjustmentID: dataStore.todayPlan.calorieAdjustmentID
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            MealRow(meal: meals[0], isDone: dataStore.isMealCompleted(meals[0].id)) {
                dataStore.toggleMeal(meals[0].id)
            }
            Divider().overlay(IOSTheme.line)
            MealRow(meal: meals[1], isDone: dataStore.isMealCompleted(meals[1].id), statusText: "下一餐") {
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
    @State private var selectedCalendarDate = Date()

    private var selectedCycle: WorkoutCycle {
        AthleteSeed.cycles.first { $0.id == selectedCycleID } ?? AthleteSeed.cycles[0]
    }

    private var selectedTemplate: WorkoutDayTemplate? {
        selectedCycle.dayTemplates.first { $0.day == selectedDay }
    }

    var body: some View {
        AppScreen(title: "训练", eyebrow: "训练模板") {
            TrainingMonthCalendar(selectedDate: $selectedCalendarDate) { date in
                if let entry = dataStore.trainingCalendarEntry(on: date) {
                    selectedCycleID = entry.cycleID
                    selectedDay = TrainingDay(rawValue: entry.trainingDay) ?? .back
                } else if Calendar.current.isDateInToday(date) {
                    selectedCycleID = dataStore.todayPlan.cycleID
                    selectedDay = TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
                } else {
                    selectedCycleID = 1
                    selectedDay = .rest
                }
            }
            CycleSelector(selectedCycleID: $selectedCycleID)
            DaySelector(selectedDay: $selectedDay)
            SaveDayPlanButton(date: selectedCalendarDate, cycleID: selectedCycleID, day: selectedDay)

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

            NoteCard("C1-C4 动作模板已录入。当前按每个动作的目标组数逐组记录实际重量和次数；目标肌群暂不作为记录字段。")
        }
        .onAppear {
            selectedCalendarDate = Date()
            selectedCycleID = dataStore.todayPlan.cycleID
            selectedDay = TrainingDay(rawValue: dataStore.todayPlan.trainingDay) ?? .back
        }
    }
}

private struct SaveDayPlanButton: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    let date: Date
    let cycleID: Int
    let day: TrainingDay

    var body: some View {
        Button {
            dataStore.saveTrainingCalendarEntry(date: date, cycleID: cycleID, trainingDay: day.rawValue)
            if Calendar.current.isDateInToday(date) {
                dataStore.setTodayPlan(cycleID: cycleID, trainingDay: day.rawValue)
            }
        } label: {
                    Label("\(Self.dayFormatter.string(from: date)) 保存训练安排", systemImage: "calendar.badge.checkmark")
                .font(.caption.weight(.heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.black)
        .background(IOSTheme.accent)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter
    }()
}

private struct CalendarDaySlot: Identifiable {
    let id = UUID()
    let date: Date?
}

private struct TrainingMonthCalendar: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    @State private var monthDate = Date()

    private let calendar = Calendar.current
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var monthTitle: String {
        Self.monthFormatter.string(from: monthDate)
    }

    private var selectedEntry: TrainingCalendarEntry? {
        dataStore.trainingCalendarEntry(on: selectedDate)
    }

    private var daySlots: [CalendarDaySlot] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate),
              let dayRange = calendar.range(of: .day, in: .month, for: monthDate) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyCount = (firstWeekday + 5) % 7
        var slots = (0..<leadingEmptyCount).map { _ in CalendarDaySlot(date: nil) }

        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                slots.append(CalendarDaySlot(date: date))
            }
        }

        while slots.count % 7 != 0 {
            slots.append(CalendarDaySlot(date: nil))
        }
        return slots
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader("训练月历", action: monthTitle)
                Spacer()
                MonthStepButton(systemName: "chevron.left") {
                    shiftMonth(-1)
                }
                MonthStepButton(systemName: "chevron.right") {
                    shiftMonth(1)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(IOSTheme.softInk)
                        .frame(maxWidth: .infinity)
                }

                ForEach(daySlots) { slot in
                    if let date = slot.date {
                        TrainingCalendarDayCell(
                            date: date,
                            entry: dataStore.trainingCalendarEntry(on: date),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date)
                        ) {
                            select(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            HStack {
                Text(Self.dayFormatter.string(from: selectedDate))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Spacer()
                StatusPill(selectedEntry == nil ? "未记录" : "已记录", color: selectedEntry == nil ? IOSTheme.amber : IOSTheme.green)
            }
        }
        .athleteCard(border: IOSTheme.accent.opacity(0.22), fill: IOSTheme.surfaceRaised)
        .onAppear {
            select(Date())
        }
    }

    private func select(_ date: Date) {
        selectedDate = date
        onDateSelected(date)
    }

    private func shiftMonth(_ value: Int) {
        monthDate = calendar.date(byAdding: .month, value: value, to: monthDate) ?? monthDate
        if !calendar.isDate(selectedDate, equalTo: monthDate, toGranularity: .month),
           let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start {
            select(monthStart)
        }
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()
}

private struct TrainingCalendarDayCell: View {
    let date: Date
    let entry: TrainingCalendarEntry?
    let isSelected: Bool
    let isToday: Bool
    let onSelect: () -> Void

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    private var label: String {
        guard let entry else { return "" }
        return entry.trainingDay == "休息" ? "休" : "C\(entry.cycleID) \(entry.trainingDay)"
    }

    private var fill: Color {
        if isSelected { return IOSTheme.accent.opacity(0.18) }
        if entry != nil { return IOSTheme.surfaceRaised }
        return IOSTheme.surface
    }

    private var border: Color {
        if isSelected { return IOSTheme.accent.opacity(0.65) }
        if isToday { return IOSTheme.green.opacity(0.5) }
        return IOSTheme.line
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(isToday ? IOSTheme.green : IOSTheme.ink)
                Text(label.isEmpty ? " " : label)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(entry == nil ? IOSTheme.softInk.opacity(0.25) : IOSTheme.softInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MonthStepButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.caption.weight(.heavy))
                .foregroundStyle(IOSTheme.ink)
                .frame(width: 30, height: 30)
                .background(IOSTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(IOSTheme.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct RestDayTrainingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("休息日")
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
                Text("今日记录")
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
    @State private var showingAddFood = false
    @State private var pendingPreset: MealPreset?
    @State private var showingPresetConfirmation = false

    private var selectedPhaseBinding: Binding<String> {
        Binding(
            get: { dataStore.todayPlan.phaseID },
            set: { dataStore.setTodayPlan(phaseID: $0) }
        )
    }

    private var plus100Binding: Binding<Bool> {
        Binding(
            get: { dataStore.isPlus100Enabled },
            set: { dataStore.setTodayPlan(calorieAdjustmentID: $0 ? "plus-100" : "base") }
        )
    }

    private var dayModeBinding: Binding<String> {
        Binding(
            get: { dataStore.todayPlan.dayModeID },
            set: { dataStore.setTodayPlan(dayModeID: $0) }
        )
    }

    var body: some View {
        AppScreen(title: "饮食", eyebrow: "Nutrition Dashboard") {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("今日摄入目标", action: dataStore.todayCaloriesText)
                PhaseSelector(selectedPhaseID: selectedPhaseBinding)
                NutritionTargetDashboard(
                    log: dataStore.todayNutritionLog,
                    phaseText: dataStore.todayPhaseText,
                    modeText: dataStore.todayDayMode.label
                )
                NutritionActionPanel(
                    plus100Enabled: plus100Binding,
                    selectedModeID: dayModeBinding,
                    fixedPreset: dataStore.fixedPresetForToday,
                    beefPreset: dataStore.beefPresetForToday,
                    beefBallPreset: dataStore.beefBallPresetForToday,
                    hasDiversePreset: dataStore.diversePresetForToday != nil,
                    dayMode: dataStore.todayDayMode,
                    onApplyPreset: { queuePreset($0) },
                    onGenerateDiverse: queueDiversePreset,
                    onAddModeEstimate: {
                        dataStore.addModeEstimate(for: dataStore.todayDayMode)
                    }
                )
            }
            .athleteCard(border: IOSTheme.accent.opacity(0.22), fill: IOSTheme.surfaceRaised)

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("今日已记录食物", action: "\(dataStore.todayNutritionLog.entries.count) 项")
                Button {
                    showingAddFood = true
                } label: {
                    Label("添加食物", systemImage: "plus.circle.fill")
                        .font(.headline.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.black)
                .background(IOSTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                ForEach(MealType.allCases) { mealType in
                    MealEntrySection(
                        mealType: mealType,
                        entries: dataStore.todayNutritionLog.entries.filter { $0.mealType == mealType }
                    )
                }
            }
            .athleteCard()
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodEntrySheet()
                .environmentObject(dataStore)
        }
        .confirmationDialog("今日已有记录，如何处理？", isPresented: $showingPresetConfirmation, titleVisibility: .visible) {
            Button("覆盖今日记录", role: .destructive) {
                applyPendingPreset(.overwrite)
            }
            Button("追加到今日记录") {
                applyPendingPreset(.append)
            }
            Button("取消", role: .cancel) {
                pendingPreset = nil
            }
        } message: {
            Text(pendingPreset?.name ?? "")
        }
    }

    private func queuePreset(_ preset: MealPreset) {
        pendingPreset = preset
        if dataStore.hasFoodEntriesToday {
            showingPresetConfirmation = true
        } else {
            applyPendingPreset(.overwrite)
        }
    }

    private func queueDiversePreset() {
        guard let preset = dataStore.diversePresetForToday else { return }
        queuePreset(preset)
    }

    private func applyPendingPreset(_ mode: PresetApplyMode) {
        guard let preset = pendingPreset else { return }
        dataStore.applyPreset(preset, mode: mode)
        pendingPreset = nil
    }
}

private struct NutritionTargetDashboard: View {
    let log: DailyNutritionLog
    let phaseText: String
    let modeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(phaseText)｜\(log.target.trainingType)｜\(log.target.dietType)｜\(modeText)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(IOSTheme.softInk)
                    Text("\(Int(log.totalCalories.rounded())) / \(Int(log.target.caloriesTarget)) kcal")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(IOSTheme.ink)
                }
                Spacer()
                Text(remainingText(log.remainingCalories, unit: "kcal"))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(log.remainingCalories >= 0 ? IOSTheme.green : IOSTheme.amber)
            }

            IntakeProgressRow(title: "Calories", current: log.totalCalories, target: log.target.caloriesTarget, unit: "kcal")
            IntakeProgressRow(title: "Protein", current: log.totalProtein, target: log.target.proteinTarget, unit: "g")
            IntakeProgressRow(title: "Carbs", current: log.totalCarbs, target: log.target.carbsTarget, unit: "g")
            IntakeProgressRow(title: "Fat", current: log.totalFat, target: log.target.fatTarget, unit: "g")
        }
    }
}

private struct NutritionActionPanel: View {
    @Binding var plus100Enabled: Bool
    @Binding var selectedModeID: String
    let fixedPreset: MealPreset?
    let beefPreset: MealPreset?
    let beefBallPreset: MealPreset?
    let hasDiversePreset: Bool
    let dayMode: NutritionDayMode
    let onApplyPreset: (MealPreset) -> Void
    let onGenerateDiverse: () -> Void
    let onAddModeEstimate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Button {
                    if let fixedPreset {
                        onApplyPreset(fixedPreset)
                    }
                } label: {
                    Label("使用固定食谱", systemImage: "list.bullet.clipboard.fill")
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.black)
                .background(fixedPreset == nil ? IOSTheme.softInk.opacity(0.28) : IOSTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .disabled(fixedPreset == nil)

                Button {
                    onGenerateDiverse()
                } label: {
                    Label("生成多样化食谱", systemImage: "shuffle")
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(IOSTheme.ink)
                .background(IOSTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(IOSTheme.line, lineWidth: 1)
                )
                .disabled(!hasDiversePreset)
            }

            if let beefBallPreset {
                HStack(spacing: 8) {
                    if let beefPreset {
                        Button {
                            onApplyPreset(beefPreset)
                        } label: {
                            Label("使用牛肉版", systemImage: "fork.knife")
                                .font(.caption.weight(.heavy))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(IOSTheme.ink)
                        .background(IOSTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(IOSTheme.line, lineWidth: 1)
                        )
                    }

                    Button {
                        onApplyPreset(beefBallPreset)
                    } label: {
                        Label("使用牛肉丸版", systemImage: "flame.fill")
                            .font(.caption.weight(.heavy))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(IOSTheme.ink)
                    .background(IOSTheme.amber.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(IOSTheme.amber.opacity(0.34), lineWidth: 1)
                    )
                }
            } else if let beefPreset {
                Button {
                    onApplyPreset(beefPreset)
                } label: {
                    Label("使用牛肉版", systemImage: "fork.knife")
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(IOSTheme.ink)
                .background(IOSTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(IOSTheme.line, lineWidth: 1)
                )
            }

            HStack(spacing: 10) {
                Toggle("+100 kcal", isOn: $plus100Enabled)
                    .toggleStyle(.switch)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)

                Spacer()

                Picker("今日模式", selection: $selectedModeID) {
                    ForEach(NutritionDayMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(IOSTheme.accent)
            }
            .padding(10)
            .background(IOSTheme.background.opacity(0.58))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if plus100Enabled {
                Text("+100 kcal 已启用：目标 Calories +100、Carbs +25g；填充含生米的食谱时午餐和晚餐各 +15g 生米。")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(IOSTheme.softInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let guidance = dayMode.guidance {
                VStack(alignment: .leading, spacing: 8) {
                    Text(guidance)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(IOSTheme.softInk)
                        .fixedSize(horizontal: false, vertical: true)

                    if dayMode == .flexible || dayMode == .plannedCheat {
                        Button {
                            onAddModeEstimate()
                        } label: {
                            Label(dayMode == .flexible ? "添加应酬餐估算" : "添加放纵餐估算", systemImage: "plus.circle")
                                .font(.caption.weight(.heavy))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(IOSTheme.accent)
                    }
                }
                .padding(10)
                .background(IOSTheme.background.opacity(0.58))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}

private struct IntakeProgressRow: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(max(current / target, 0), 1.15)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.softInk)
                    .frame(width: 68, alignment: .leading)
                Text("\(formatNumber(current)) / \(formatNumber(target))\(unit == "kcal" ? "" : unit)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Spacer()
                Text(remainingText(target - current, unit: unit))
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(current <= target ? IOSTheme.green : IOSTheme.amber)
            }
            ProgressView(value: progress)
                .tint(current <= target ? IOSTheme.accent : IOSTheme.amber)
        }
    }
}

private struct MealEntrySection: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    let mealType: MealType
    let entries: [FoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mealType.rawValue)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Spacer()
                Text("\(Int(entries.reduce(0) { $0 + $1.calculatedCalories }.rounded())) kcal")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.softInk)
            }

            if entries.isEmpty {
                Text("未记录")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(IOSTheme.softInk.opacity(0.72))
                    .padding(.vertical, 6)
            } else {
                ForEach(entries) { entry in
                    FoodEntryRow(entry: entry) {
                        dataStore.deleteFoodEntry(entry)
                    }
                    if entry.id != entries.last?.id {
                        Divider().overlay(IOSTheme.line)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(entry.foodName)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Text("\(formatNumber(entry.amount))\(entry.unit.label) · \(Int(entry.calculatedCalories.rounded())) kcal / P \(formatNumber(entry.calculatedProtein)) / C \(formatNumber(entry.calculatedCarbs)) / F \(formatNumber(entry.calculatedFat))")
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(IOSTheme.softInk)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
    }
}

private struct AddFoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataStore: AthleteDataStore
    @State private var mealType: MealType = .breakfast
    @State private var selectedCategory: FoodCategory?
    @State private var searchText = ""
    @State private var foodForAmount: FoodItem?

    private var foods: [FoodItem] {
        dataStore.foodLibrary.filter { item in
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("餐次")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(IOSTheme.softInk)
                        Picker("餐次", selection: $mealType) {
                            ForEach(MealType.allCases) { meal in
                                Text(meal.rawValue).tag(meal)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .athleteCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("选择食物")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(IOSTheme.softInk)
                        TextField("搜索食物名", text: $searchText)
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(IOSTheme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(IOSTheme.background.opacity(0.78))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FoodCategoryChip(title: "全部", isSelected: selectedCategory == nil) {
                                    selectedCategory = nil
                                }
                                ForEach(FoodCategory.allCases) { category in
                                    FoodCategoryChip(title: category.label, isSelected: selectedCategory == category) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }

                        VStack(spacing: 0) {
                            ForEach(foods) { food in
                                FoodPickerRow(food: food) {
                                    foodForAmount = food
                                }
                                if food.id != foods.last?.id {
                                    Divider().overlay(IOSTheme.line)
                                }
                            }
                        }
                        .background(IOSTheme.background.opacity(0.42))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .athleteCard()
                }
                .padding(16)
            }
            .background(IOSTheme.background.ignoresSafeArea())
            .navigationTitle("添加食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismissKeyboard()
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $foodForAmount) { food in
            FoodAmountSheet(food: food, mealType: mealType) { amount in
                dataStore.addFoodEntry(foodItem: food, mealType: mealType, amount: amount)
                dismissKeyboard()
                foodForAmount = nil
                dismiss()
            }
        }
    }
}

private struct FoodCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(isSelected ? Color.black : IOSTheme.softInk)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isSelected ? IOSTheme.accent : IOSTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct FoodPickerRow: View {
    let food: FoodItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(IOSTheme.accent)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(IOSTheme.ink)
                    Text("\(food.category.label) · 默认 \(formatNumber(food.defaultServing))\(food.unit.label)\(food.notes.isEmpty ? "" : " · \(food.notes)")")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(IOSTheme.softInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct FoodAmountSheet: View {
    @Environment(\.dismiss) private var dismiss
    let food: FoodItem
    let mealType: MealType
    let onSave: (Double) -> Void
    @State private var amountText: String

    init(food: FoodItem, mealType: MealType, onSave: @escaping (Double) -> Void) {
        self.food = food
        self.mealType = mealType
        self.onSave = onSave
        _amountText = State(initialValue: formatNumber(food.defaultServing))
    }

    private var amount: Double {
        Double(amountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private var previewMacros: FoodMacros {
        food.macros(for: amount)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(mealType.rawValue)
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(IOSTheme.accent)
                    Text(food.name)
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(IOSTheme.ink)
                    Text("\(food.category.label) · 默认 \(formatNumber(food.defaultServing))\(food.unit.label)\(food.notes.isEmpty ? "" : " · \(food.notes)")")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(IOSTheme.softInk)
                }
                .athleteCard(border: IOSTheme.accent.opacity(0.22), fill: IOSTheme.surfaceRaised)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("输入数量")
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(IOSTheme.softInk)
                        Spacer()
                        Text(food.unit.label)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(IOSTheme.accent)
                    }
                    TextField("输入数量", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(IOSTheme.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .background(IOSTheme.background.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text("\(Int(previewMacros.calories.rounded())) kcal / P \(formatNumber(previewMacros.protein)) / C \(formatNumber(previewMacros.carbs)) / F \(formatNumber(previewMacros.fat))")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(IOSTheme.softInk)
                }
                .athleteCard()

                Button {
                    guard amount > 0 else { return }
                    onSave(amount)
                    dismiss()
                } label: {
                    Text("确认添加")
                        .font(.headline.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.black)
                .background(amount > 0 ? IOSTheme.accent : IOSTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(amount <= 0)

                Spacer()
            }
            .padding(16)
            .background(IOSTheme.background.ignoresSafeArea())
            .navigationTitle("记录数量")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("返回") {
                        dismissKeyboard()
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private func formatNumber(_ value: Double) -> String {
    if value.rounded() == value {
        return String(Int(value))
    }
    return String(format: "%.1f", value)
}

private func remainingText(_ value: Double, unit: String) -> String {
    if value >= 0 {
        return "剩余 \(formatNumber(value))\(unit)"
    }
    return "超出 \(formatNumber(abs(value)))\(unit)"
}

private struct ProgressScreen: View {
    @EnvironmentObject private var dataStore: AthleteDataStore
    @State private var weightText = ""
    @State private var waistText = ""

    var body: some View {
        AppScreen(title: "趋势", eyebrow: "身体数据") {
            BodyInputCard(weightText: $weightText, waistText: $waistText) {
                dataStore.saveToday(weightText: weightText, waistText: waistText)
            }

            HStack(spacing: 10) {
                RecordBox(title: "今日空腹体重", value: dataStore.formattedWeight(dataStore.todayEntry?.weightKg), note: "每天记录")
                RecordBox(title: "本周腰围", value: dataStore.formattedWaist(dataStore.latestWaist), note: "每周一次")
            }

            WeightChart(points: dataStore.chartPoints)

            RecentBodyRecords(entries: Array(dataStore.recentBodyEntries.prefix(14)))

            VStack(spacing: 0) {
                MetricRow(
                    title: "体重趋势",
                    value: "7 日平均 \(dataStore.formattedWeight(dataStore.sevenDayAverageWeight))",
                    status: dataStore.formattedDelta(dataStore.twoWeekWeightDelta),
                    statusColor: dataStore.trendStatusText == "正常" ? IOSTheme.green : IOSTheme.amber
                )
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "两周变化", value: dataStore.formattedDelta(dataStore.twoWeekWeightDelta), status: dataStore.trendStatusText, statusColor: dataStore.trendStatusText == "正常" ? IOSTheme.green : IOSTheme.amber)
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "训练表现", value: "主要动作无明显提升", status: "观察", statusColor: IOSTheme.amber)
                Divider().overlay(IOSTheme.line)
                MetricRow(title: "增重速度", value: dataStore.formattedGainRate(dataStore.monthlyGainRate), status: "月速率", statusColor: IOSTheme.amber)
            }
            .athleteCard()

            CoachInsightCard(text: dataStore.coachInsightText)
            PlaceholderCard(title: "阶段时间线", description: "减脂结束 -> 缓冲期 -> +100 kcal。确认调整后，时间线会标记为热量调整。", ready: true)
            PlaceholderCard(title: "体型照片", description: "每周照片占位：正面 / 侧面 / 背面 / 自媒体精选照。")
        }
        .onAppear {
            weightText = dataStore.todayEntry?.weightKg.map { String(format: "%.1f", $0) } ?? ""
            waistText = dataStore.todayEntry?.waistCm.map { String(format: "%.1f", $0) } ?? ""
        }
    }
}

private struct RecentBodyRecords: View {
    let entries: [BodyEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("最近身体记录", action: "\(entries.count) 条")
            if entries.isEmpty {
                Text("暂无历史体重记录")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(IOSTheme.softInk)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 0) {
                    ForEach(entries) { entry in
                        HStack {
                            Text(entry.dateString)
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(IOSTheme.ink)
                            Spacer()
                            Text(entry.weightKg.map { String(format: "%.1fkg", $0) } ?? "--")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(IOSTheme.softInk)
                            Text(entry.waistCm.map { String(format: "%.1fcm", $0) } ?? "--")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(IOSTheme.softInk)
                                .frame(width: 62, alignment: .trailing)
                        }
                        .padding(.vertical, 9)
                        if entry.id != entries.last?.id {
                            Divider().overlay(IOSTheme.line)
                        }
                    }
                }
            }
        }
        .athleteCard()
    }
}

private struct TemplatesScreen: View {
    var body: some View {
        AppScreen(title: "模板", eyebrow: "设置") {
            ForEach(AthleteSeed.cycles) { cycle in
                let exerciseCount = cycle.dayTemplates.reduce(0) { $0 + $1.exercises.count }
                PlaceholderCard(
                    title: "\(cycle.name) 已录入",
                    description: "肩、背、胸、腿共 \(exerciseCount) 个动作。训练时可按组填写实际重量、次数和动作备注。",
                    ready: true
                )
            }

            PlaceholderCard(
                title: "饮食模板",
                description: "减脂后1-2周 / 3-8周缓冲 / 9周后稳定增肌 / +100 kcal 将在这里编辑。"
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

private struct RecipeVariantSelector: View {
    @Binding var selectedVariantID: String
    let phaseID: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RecipeVariant.allCases) { variant in
                let isEnabled = variant != .beefBall || phaseID == "stable-9-plus"
                let isSelected = selectedVariantID == variant.rawValue && isEnabled
                Button {
                    selectedVariantID = variant.rawValue
                } label: {
                    Text(variant.label)
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? IOSTheme.accent.opacity(0.12) : IOSTheme.surface)
                        .foregroundStyle(isEnabled ? (isSelected ? IOSTheme.ink : IOSTheme.softInk) : IOSTheme.softInk.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? IOSTheme.accent.opacity(0.5) : IOSTheme.line, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            }
        }
    }
}

private struct CalorieAdjustmentSelector: View {
    @Binding var selectedAdjustmentID: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CalorieAdjustment.allCases) { adjustment in
                Button {
                    selectedAdjustmentID = adjustment.rawValue
                } label: {
                    Text(adjustment.label)
                        .font(.caption.weight(.heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedAdjustmentID == adjustment.rawValue ? IOSTheme.accent.opacity(0.12) : IOSTheme.surface)
                        .foregroundStyle(selectedAdjustmentID == adjustment.rawValue ? IOSTheme.ink : IOSTheme.softInk)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(selectedAdjustmentID == adjustment.rawValue ? IOSTheme.accent.opacity(0.5) : IOSTheme.line, lineWidth: 1)
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

    private var movementNames: [String] {
        guard exercise.isCombo else { return [exercise.name] }
        let parts = exercise.name
            .components(separatedBy: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? [exercise.name] : parts
    }

    private var setsPerMovement: Int {
        max(exercise.setTargets.count, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(IOSTheme.ink)
                Spacer()
                if exercise.isCombo {
                    StatusPill("组合", color: IOSTheme.amber)
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

            if exercise.isCombo {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(movementNames.indices, id: \.self) { movementIndex in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(movementNames[movementIndex])
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(IOSTheme.accent)
                            trainingSetHeader
                            ForEach(exercise.setTargets.indices, id: \.self) { setIndex in
                                TrainingSetLogRow(
                                    index: setIndex,
                                    setLog: bindingForSet(movementIndex: movementIndex, setIndex: setIndex)
                                ) {
                                    saveDraft()
                                }
                            }
                        }
                        .padding(8)
                        .background(IOSTheme.background.opacity(0.46))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    trainingSetHeader
                    ForEach(exercise.setTargets.indices, id: \.self) { index in
                        TrainingSetLogRow(
                            index: index,
                            setLog: bindingForSet(movementIndex: 0, setIndex: index)
                        ) {
                            saveDraft()
                        }
                    }
                }
                .padding(8)
                .background(IOSTheme.background.opacity(0.46))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

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
                } label: {
                    Label(isDone ? "已完成" : "标记完成", systemImage: isDone ? "checkmark.circle.fill" : "circle")
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
                    Text("保存")
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
        .onChange(of: note) { _ in
            saveDraft()
        }
    }

    private var trainingSetHeader: some View {
        HStack(spacing: 8) {
            Text("组")
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
    }

    private func bindingForSet(movementIndex: Int, setIndex: Int) -> Binding<ExerciseSetLog> {
        Binding(
            get: {
                let index = flatIndex(movementIndex: movementIndex, setIndex: setIndex)
                return setLogs.indices.contains(index) ? setLogs[index] : fallbackSetLog(movementIndex: movementIndex, setIndex: setIndex)
            },
            set: { newValue in
                let index = flatIndex(movementIndex: movementIndex, setIndex: setIndex)
                guard setLogs.indices.contains(index) else { return }
                setLogs[index] = newValue
                saveDraft()
            }
        )
    }

    private func syncFromStore() {
        let log = dataStore.exerciseLog(cycleID: cycleID, day: day.rawValue, exerciseID: exercise.id)
        setLogs = mergedSetLogs(stored: log.setLogs)
        note = log.note
        isDone = log.isDone || (!setLogs.isEmpty && setLogs.allSatisfy(\.isDone))
    }

    private func saveDraft() {
        save(dismiss: false)
    }

    private func save() {
        save(dismiss: true)
    }

    private func save(dismiss: Bool) {
        isDone = !setLogs.isEmpty && setLogs.allSatisfy(\.isDone)
        dataStore.saveExerciseLog(
            cycleID: cycleID,
            day: day.rawValue,
            exerciseID: exercise.id,
            setLogs: setLogs,
            note: note,
            isDone: isDone
        )
        if dismiss {
            dismissKeyboard()
        }
    }

    private func mergedSetLogs(stored: [ExerciseSetLog]) -> [ExerciseSetLog] {
        let targets = exercise.setTargets
        let totalCount = exercise.isCombo ? movementNames.count * targets.count : targets.count
        return (0..<totalCount).map { index in
            let movementIndex = exercise.isCombo ? index / setsPerMovement : 0
            let setIndex = exercise.isCombo ? index % setsPerMovement : index
            let expectedID = setID(movementIndex: movementIndex, setIndex: setIndex)
            let storedSet = stored.first { $0.id == expectedID } ?? (index < stored.count ? stored[index] : nil)
            return ExerciseSetLog(
                id: expectedID,
                targetReps: targets[setIndex],
                weightText: storedSet?.weightText ?? "",
                repsText: storedSet?.repsText ?? "",
                isDone: storedSet?.isDone ?? false
            )
        }
    }

    private func flatIndex(movementIndex: Int, setIndex: Int) -> Int {
        exercise.isCombo ? movementIndex * setsPerMovement + setIndex : setIndex
    }

    private func setID(movementIndex: Int, setIndex: Int) -> String {
        exercise.isCombo ? "movement-\(movementIndex + 1)-set-\(setIndex + 1)" : "set-\(setIndex + 1)"
    }

    private func fallbackSetLog(movementIndex: Int, setIndex: Int) -> ExerciseSetLog {
        ExerciseSetLog(
            id: setID(movementIndex: movementIndex, setIndex: setIndex),
            targetReps: exercise.setTargets[setIndex],
            weightText: "",
            repsText: "",
            isDone: false
        )
    }
}

private struct TrainingSetLogRow: View {
    let index: Int
    @Binding var setLog: ExerciseSetLog
    let onChange: () -> Void

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

            TextField("次数", text: $setLog.repsText)
                .keyboardType(.numbersAndPunctuation)
                .trainingSetInputStyle()

            Button {
                setLog.isDone.toggle()
                onChange()
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
                Text(statusText ?? (isDone ? "已完成" : "待吃"))
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
            Text("全天目标")
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
            Text("今日记录")
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
            Text("体重趋势")
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
    var text = "两周均重增长偏低，建议启用当前阶段背/腿 +100 kcal 米饭版；点击确认后再套用。"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("教练建议")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(IOSTheme.ink)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(IOSTheme.softInk)
            }
            Spacer()
            StatusPill("确认", color: IOSTheme.amber)
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
            Text(ready ? "已就绪" : "占位")
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

#Preview("Iron Protocol") {
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
