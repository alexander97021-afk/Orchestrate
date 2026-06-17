import SwiftUI

@main
struct IronProtocolApp: App {
    @StateObject private var dataStore = AthleteDataStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                IOSRootView()
                    .environmentObject(dataStore)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 1_250_000_000)
                withAnimation(.easeOut(duration: 0.15)) {
                    showSplash = false
                }
            }
        }
    }
}

private struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image("SplashBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.18))

            VStack(spacing: 8) {
                Text("DESIDERATUS")
                Text("FATUM")
            }
            .font(.system(size: 28, weight: .semibold, design: .serif))
            .tracking(3.5)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.85), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 34)
        }
    }
}
