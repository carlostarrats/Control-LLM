import SwiftUI

// MARK: - App Colors
struct AppColors {
    static let primary = Color.blue
    static let secondary = Color.gray
    static let accent = Color.orange
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    static let text = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
}

// MARK: - App Fonts
struct AppFonts {
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let callout = Font.callout
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - App Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - App Corner Radius
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - App Shadows
struct AppShadows {
    static let small = Shadow(
        color: .black.opacity(0.1),
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let medium = Shadow(
        color: .black.opacity(0.15),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let large = Shadow(
        color: .black.opacity(0.2),
        radius: 8,
        x: 0,
        y: 4
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - App Button Styles
struct AppButtonStyle {
    static let primary = ButtonStyle(
        backgroundColor: AppColors.primary,
        foregroundColor: .white,
        cornerRadius: AppCornerRadius.medium,
        shadow: AppShadows.small
    )
    
    static let secondary = ButtonStyle(
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: AppColors.text,
        cornerRadius: AppCornerRadius.medium,
        shadow: AppShadows.small
    )
    
    static let outline = ButtonStyle(
        backgroundColor: .clear,
        foregroundColor: AppColors.primary,
        cornerRadius: AppCornerRadius.medium,
        shadow: AppShadows.small,
        borderColor: AppColors.primary,
        borderWidth: 1
    )
}

struct ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let shadow: Shadow
    let borderColor: Color?
    let borderWidth: CGFloat?
    
    init(
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat,
        shadow: Shadow,
        borderColor: Color? = nil,
        borderWidth: CGFloat? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

// MARK: - Custom Button Modifier
struct CustomButtonStyle: ViewModifier {
    let style: ButtonStyle
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
            .shadow(
                color: style.shadow.color,
                radius: style.shadow.radius,
                x: style.shadow.x,
                y: style.shadow.y
            )
            .overlay(
                Group {
                    if let borderColor = style.borderColor,
                       let borderWidth = style.borderWidth {
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
    }
}

extension View {
    func customButtonStyle(_ style: ButtonStyle) -> some View {
        modifier(CustomButtonStyle(style: style))
    }
} 