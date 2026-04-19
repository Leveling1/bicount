import SwiftUI
import WidgetKit

private let widgetKind = "BicountHomeWidget"
private let widgetGroupId = "group.com.youngsolver.bicount"

private let widgetThemeKey = "bicount_widget_theme_is_dark"
private let widgetBadgeKey = "bicount_widget_badge"
private let widgetTitleKey = "bicount_widget_title"
private let widgetAmountKey = "bicount_widget_amount"
private let widgetSubtitleKey = "bicount_widget_subtitle"
private let widgetButtonLabelKey = "bicount_widget_button_label"
private let widgetMainActionUriKey = "bicount_widget_main_action_uri"
private let widgetButtonActionUriKey = "bicount_widget_button_action_uri"
private let widgetTitleColorKey = "bicount_widget_title_color"
private let widgetAmountColorKey = "bicount_widget_amount_color"
private let widgetSubtitleColorKey = "bicount_widget_subtitle_color"
private let widgetButtonTextColorKey = "bicount_widget_button_text_color"

struct BicountHomeWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> BicountHomeWidgetEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (BicountHomeWidgetEntry) -> Void) {
    completion(.current())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<BicountHomeWidgetEntry>) -> Void) {
    completion(Timeline(entries: [.current()], policy: .atEnd))
  }
}

struct BicountHomeWidgetEntry: TimelineEntry {
  let date: Date
  let isDarkTheme: Bool
  let badge: String
  let title: String
  let amount: String
  let subtitle: String
  let buttonLabel: String
  let mainActionUrl: URL?
  let buttonActionUrl: URL?
  let titleColor: Color
  let amountColor: Color
  let subtitleColor: Color
  let buttonTextColor: Color

  var backgroundColor: Color {
    isDarkTheme ? Color(argb: 0xFF2C2C2C) : Color(argb: 0xFFF9F9F9)
  }

  var borderColor: Color {
    isDarkTheme ? Color(argb: 0xFF3B3B3B) : Color(argb: 0xFFE8E8E8)
  }

  var buttonBackgroundColor: Color {
    isDarkTheme ? Color(argb: 0xFFF9F9F9) : Color(argb: 0xFF2C2C2C)
  }

  static var placeholder: BicountHomeWidgetEntry {
    BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: false,
      badge: "Needs confirmation",
      title: "Bicount",
      amount: "12,400 CDF",
      subtitle: "Due on today",
      buttonLabel: "Add transaction",
      mainActionUrl: URL(string: "bicount://widget/open-home?homeWidget=1"),
      buttonActionUrl: URL(string: "bicount://widget/add-transaction?homeWidget=1"),
      titleColor: Color(argb: 0xFF212121),
      amountColor: Color(argb: 0xFF76A646),
      subtitleColor: Color(argb: 0xFF757575),
      buttonTextColor: Color(argb: 0xFFF9F9F9)
    )
  }

  static func current() -> BicountHomeWidgetEntry {
    let preferences = UserDefaults(suiteName: widgetGroupId)

    func storedString(_ key: String, default defaultValue: String) -> String {
      let value = preferences?.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines)
      return (value?.isEmpty == false) ? value! : defaultValue
    }

    func storedInt(_ key: String, default defaultValue: Int) -> Int {
      if let number = preferences?.object(forKey: key) as? NSNumber {
        return number.intValue
      }
      return defaultValue
    }

    let isDarkTheme = preferences?.bool(forKey: widgetThemeKey) ?? false
    let title = storedString(widgetTitleKey, default: "Open Bicount")
    let subtitle = storedString(
      widgetSubtitleKey,
      default: "Sign in to refresh your finance snapshot."
    )
    let buttonLabel = storedString(widgetButtonLabelKey, default: "Open app")
    let amount = preferences?.string(forKey: widgetAmountKey) ?? ""
    let badge = preferences?.string(forKey: widgetBadgeKey) ?? ""
    let mainActionUrl = URL(string: preferences?.string(forKey: widgetMainActionUriKey) ?? "")
    let buttonActionUrl = URL(string: preferences?.string(forKey: widgetButtonActionUriKey) ?? "")

    return BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: isDarkTheme,
      badge: badge,
      title: title,
      amount: amount,
      subtitle: subtitle,
      buttonLabel: buttonLabel,
      mainActionUrl: mainActionUrl,
      buttonActionUrl: buttonActionUrl,
      titleColor: Color(argb: storedInt(widgetTitleColorKey, default: 0xFF212121)),
      amountColor: Color(argb: storedInt(widgetAmountColorKey, default: 0xFF76A646)),
      subtitleColor: Color(argb: storedInt(widgetSubtitleColorKey, default: 0xFF757575)),
      buttonTextColor: Color(argb: storedInt(widgetButtonTextColorKey, default: 0xFFF9F9F9))
    )
  }
}

struct BicountHomeWidgetEntryView: View {
  var entry: BicountHomeWidgetProvider.Entry

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(entry.backgroundColor)
        .overlay(
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(entry.borderColor, lineWidth: 1)
        )

      VStack(alignment: .leading, spacing: 0) {
        if !entry.badge.isEmpty {
          Text(entry.badge)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
              Capsule(style: .continuous)
                .fill(Color(argb: 0xFF76A646))
            )
            .padding(.bottom, 10)
        }

        if let mainActionUrl = entry.mainActionUrl {
          Link(destination: mainActionUrl) {
            content
          }
          .buttonStyle(.plain)
        } else {
          content
        }

        Spacer(minLength: 16)

        if let buttonActionUrl = entry.buttonActionUrl {
          Link(destination: buttonActionUrl) {
            button
          }
          .buttonStyle(.plain)
        } else {
          button
        }
      }
      .padding(16)
    }
    .bicountWidgetBackground()
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(entry.title)
        .font(.system(size: 18, weight: .bold))
        .foregroundColor(entry.titleColor)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)

      if !entry.amount.isEmpty {
        Text(entry.amount)
          .font(.system(size: 24, weight: .bold))
          .foregroundColor(entry.amountColor)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      if !entry.subtitle.isEmpty {
        Text(entry.subtitle)
          .font(.system(size: 13, weight: .regular))
          .foregroundColor(entry.subtitleColor)
          .lineLimit(2)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var button: some View {
    Text(entry.buttonLabel)
      .font(.system(size: 14, weight: .semibold))
      .foregroundColor(entry.buttonTextColor)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .fill(entry.buttonBackgroundColor)
      )
  }
}

struct BicountHomeWidget: Widget {
  let kind: String = widgetKind

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BicountHomeWidgetProvider()) { entry in
      BicountHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Bicount overview")
    .description("Quick access to your next finance action.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

private extension View {
  @ViewBuilder
  func bicountWidgetBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self.containerBackground(for: .widget) {
        Color.clear
      }
    } else {
      self
    }
  }
}

private extension Color {
  init(argb: Int) {
    let value = UInt32(bitPattern: Int32(truncatingIfNeeded: argb))
    let alpha = Double((value >> 24) & 0xFF) / 255
    let red = Double((value >> 16) & 0xFF) / 255
    let green = Double((value >> 8) & 0xFF) / 255
    let blue = Double(value & 0xFF) / 255
    self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }
}