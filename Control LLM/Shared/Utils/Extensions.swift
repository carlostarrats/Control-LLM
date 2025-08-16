import SwiftUI
import Foundation

// MARK: - Notification Extensions
extension Notification.Name {
    static let modelDidChange = Notification.Name("modelDidChange")
}

// MARK: - Color Extensions
extension Color {
    static let customPrimary = Color("PrimaryColor")
    static let customSecondary = Color("SecondaryColor")
    static let customBackground = Color("BackgroundColor")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Interpolate between two colors
    func interpolated(to other: Color, amount: Double) -> Color {
        let amount = max(0, min(1, amount)) // Clamp between 0 and 1
        
        // Convert to UIColor for easier manipulation
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(other)
        
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        uiColor1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        uiColor2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        let interpolatedRed = red1 + (red2 - red1) * amount
        let interpolatedGreen = green1 + (green2 - green1) * amount
        let interpolatedBlue = blue1 + (blue2 - blue1) * amount
        let interpolatedAlpha = alpha1 + (alpha2 - alpha1) * amount
        
        return Color(
            .sRGB,
            red: interpolatedRed,
            green: interpolatedGreen,
            blue: interpolatedBlue,
            opacity: interpolatedAlpha
        )
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmptyOrWhitespace: Bool {
        self.trimmed.isEmpty
    }
    
    func truncate(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            let safeLength = min(length, self.count)
            return String(self.prefix(safeLength)) + trailing
        } else {
            return self
        }
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Haptic Feedback
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
} 