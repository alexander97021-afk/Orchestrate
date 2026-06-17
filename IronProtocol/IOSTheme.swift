import SwiftUI

enum IOSTheme {
    static let background = Color(hex: 0x0B0D10)
    static let surface = Color(hex: 0x171A20)
    static let surfaceRaised = Color(hex: 0x1D2128)
    static let line = Color(hex: 0x2A3038)
    static let ink = Color(hex: 0xF2F6F8)
    static let softInk = Color(hex: 0x8E98A6)
    static let accent = Color(hex: 0x00D1FF)
    static let green = Color(hex: 0x25D695)
    static let amber = Color(hex: 0xF0A33A)
    static let red = Color(hex: 0xEF5B4D)

    static var appBackground: some View {
        LinearGradient(
            colors: [
                accent.opacity(0.08),
                background,
                Color.black.opacity(0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct AthleteCard: ViewModifier {
    var radius: CGFloat = 14
    var border: Color = IOSTheme.line
    var fill: Color = IOSTheme.surface

    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
    }
}

extension View {
    func athleteCard(
        radius: CGFloat = 14,
        border: Color = IOSTheme.line,
        fill: Color = IOSTheme.surface
    ) -> some View {
        modifier(AthleteCard(radius: radius, border: border, fill: fill))
    }
}
