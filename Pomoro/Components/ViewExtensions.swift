import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Apply a modifier only on iOS
    @ViewBuilder
    func iOSOnly<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        #if os(iOS)
        transform(self)
        #else
        self
        #endif
    }

    /// Apply a modifier only on macOS
    @ViewBuilder
    func macOSOnly<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        #if os(macOS)
        transform(self)
        #else
        self
        #endif
    }
}

// MARK: - .sensoryFeedback cross-platform

extension View {
    /// Cross-platform sensory feedback (no-op on macOS)
    func sensoryFeedbackCompat(_ trigger: some Equatable) -> some View {
        #if os(iOS)
        return self.sensoryFeedback(.impact(weight: .medium), trigger: trigger)
        #else
        return self
        #endif
    }
}

// MARK: - Presentation Detents (iOS only)

extension View {
    @ViewBuilder
    func presentationDetentsCompat(_ detents: Set<PresentationDetent>) -> some View {
        #if os(iOS)
        self.presentationDetents(detents)
        #else
        self
        #endif
    }
}

// MARK: - Status Bar Hidden (iOS only)

extension View {
    @ViewBuilder
    func statusBarHiddenCompat(_ hidden: Bool = true) -> some View {
        #if os(iOS)
        self.statusBarHidden(hidden)
        #else
        self
        #endif
    }
}

// MARK: - Persistent System Overlays (iOS only)

extension View {
    @ViewBuilder
    func persistentSystemOverlaysCompat(_ visibility: Visibility) -> some View {
        #if os(iOS)
        self.persistentSystemOverlays(visibility)
        #else
        self
        #endif
    }
}
