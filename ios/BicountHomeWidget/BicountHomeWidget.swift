import SwiftUI
import WidgetKit

private let widgetKind = "BicountHomeWidget"
private let widgetGroupId = "group.com.youngsolver.bicount"
private let listDelimiter = "|"

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
  let eyebrow: String
  let balance: String
  let balanceColor: Color
  let mainActionUrl: URL?

  let monthDeltaLabel: String
  let monthDeltaColor: Color
  let monthIncomeValue: Double
  let monthIncomeLabel: String
  let monthExpenseValue: Double
  let monthExpenseLabel: String

  let nextItemLabel: String
  let nextItemAmountLabel: String
  let nextItemAmountColor: Color
  let nextItemActionUrl: URL?

  let weekDayLabels: [String]
  let weekValues: [Double]
  let weekHighlightIndex: Int

  let recentItemLabel: String
  let recentItemAmountLabel: String
  let recentItemAmountColor: Color

  let singleButtonLabel: String
  let singleButtonActionUrl: URL?
  let incomeButtonLabel: String
  let incomeButtonActionUrl: URL?
  let expenseButtonLabel: String
  let expenseButtonActionUrl: URL?

  let monthSectionLabel: String
  let nextItemSectionLabel: String
  let weekSectionLabel: String
  let weekSectionCompactLabel: String
  let entriesLabel: String
  let exitsLabel: String

  let titleColor: Color
  let subtitleColor: Color
  let buttonTextColor: Color

  var backgroundColor: Color {
    isDarkTheme ? Color(argb: 0xFF2C2C2C) : Color(argb: 0xFFF9F9F9)
  }

  var borderColor: Color {
    isDarkTheme ? Color(argb: 0xFF3B3B3B) : Color(argb: 0xFFE8E8E8)
  }

  static var placeholder: BicountHomeWidgetEntry {
    BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: false,
      eyebrow: "BICOUNT",
      balance: "2 340 €",
      balanceColor: Color(argb: 0xFF212121),
      mainActionUrl: URL(string: "bicount://widget/open-home?homeWidget=1"),
      monthDeltaLabel: "+120 € ce mois",
      monthDeltaColor: Color(argb: 0xFF76A646),
      monthIncomeValue: 850,
      monthIncomeLabel: "850 €",
      monthExpenseValue: 420,
      monthExpenseLabel: "420 €",
      nextItemLabel: "Netflix — demain",
      nextItemAmountLabel: "-13,99 €",
      nextItemAmountColor: Color(argb: 0xFFF44336),
      nextItemActionUrl: URL(string: "bicount://widget/add-transaction?homeWidget=1"),
      weekDayLabels: ["L", "M", "M", "J", "V", "S", "D"],
      weekValues: [12, 18, 9, 22, 14, 16, 26],
      weekHighlightIndex: 6,
      recentItemLabel: "Boulangerie Marais",
      recentItemAmountLabel: "-4,50 €",
      recentItemAmountColor: Color(argb: 0xFFF44336),
      singleButtonLabel: "+ Ajouter",
      singleButtonActionUrl: URL(string: "bicount://widget/add-transaction?homeWidget=1"),
      incomeButtonLabel: "+ Revenu",
      incomeButtonActionUrl: URL(string: "bicount://widget/add-income?homeWidget=1"),
      expenseButtonLabel: "- Dépense",
      expenseButtonActionUrl: URL(string: "bicount://widget/add-expense?homeWidget=1"),
      monthSectionLabel: "CE MOIS",
      nextItemSectionLabel: "PROCHAIN ABONNEMENT",
      weekSectionLabel: "DÉPENSES · 7 DERNIERS JOURS",
      weekSectionCompactLabel: "DÉPENSES - 7J",
      entriesLabel: "Entrées",
      exitsLabel: "Sorties",
      titleColor: Color(argb: 0xFF212121),
      subtitleColor: Color(argb: 0xFF9AA0A6),
      buttonTextColor: Color(argb: 0xFFF9F9F9)
    )
  }

  static func current() -> BicountHomeWidgetEntry {
    let preferences = UserDefaults(suiteName: widgetGroupId)

    func str(_ key: String, default defaultValue: String = "") -> String {
      let value = preferences?.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines)
      return (value?.isEmpty == false) ? value! : defaultValue
    }

    func rawInt(_ key: String, default defaultValue: Int) -> Int {
      if let number = preferences?.object(forKey: key) as? NSNumber {
        return number.intValue
      }
      return defaultValue
    }

    func rawDouble(_ key: String) -> Double {
      if let number = preferences?.object(forKey: key) as? NSNumber {
        return number.doubleValue
      }
      return 0
    }

    func color(_ key: String, default defaultValue: Int) -> Color {
      Color(argb: rawInt(key, default: defaultValue))
    }

    func url(_ key: String) -> URL? {
      let value = preferences?.string(forKey: key) ?? ""
      return value.isEmpty ? nil : URL(string: value)
    }

    let isDarkTheme = preferences?.bool(forKey: "bicount_widget_theme_is_dark") ?? false
    let mainActionUrl = url("bicount_widget_main_action_uri")

    let weekDayLabels = str("bicount_widget_week_day_labels")
      .split(separator: Character(listDelimiter), omittingEmptySubsequences: true)
      .map(String.init)
    let weekValues = str("bicount_widget_week_values")
      .split(separator: Character(listDelimiter), omittingEmptySubsequences: true)
      .compactMap { Double($0) }

    return BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: isDarkTheme,
      eyebrow: str("bicount_widget_eyebrow", default: "BICOUNT"),
      balance: str("bicount_widget_balance", default: "Open Bicount"),
      balanceColor: color("bicount_widget_balance_color", default: 0xFF212121),
      mainActionUrl: mainActionUrl,
      monthDeltaLabel: str("bicount_widget_month_delta_label"),
      monthDeltaColor: color("bicount_widget_month_delta_color", default: 0xFF76A646),
      monthIncomeValue: rawDouble("bicount_widget_month_income_value"),
      monthIncomeLabel: str("bicount_widget_month_income_label"),
      monthExpenseValue: rawDouble("bicount_widget_month_expense_value"),
      monthExpenseLabel: str("bicount_widget_month_expense_label"),
      nextItemLabel: str("bicount_widget_next_item_label"),
      nextItemAmountLabel: str("bicount_widget_next_item_amount_label"),
      nextItemAmountColor: color("bicount_widget_next_item_amount_color", default: 0xFFF44336),
      nextItemActionUrl: url("bicount_widget_next_item_action_uri") ?? mainActionUrl,
      weekDayLabels: weekDayLabels,
      weekValues: weekValues,
      weekHighlightIndex: rawInt("bicount_widget_week_highlight_index", default: -1),
      recentItemLabel: str("bicount_widget_recent_item_label"),
      recentItemAmountLabel: str("bicount_widget_recent_item_amount_label"),
      recentItemAmountColor: color("bicount_widget_recent_item_amount_color", default: 0xFF212121),
      singleButtonLabel: str("bicount_widget_single_button_label", default: "Open app"),
      singleButtonActionUrl: url("bicount_widget_single_button_action_uri") ?? mainActionUrl,
      incomeButtonLabel: str("bicount_widget_income_button_label"),
      incomeButtonActionUrl: url("bicount_widget_income_button_action_uri") ?? mainActionUrl,
      expenseButtonLabel: str("bicount_widget_expense_button_label"),
      expenseButtonActionUrl: url("bicount_widget_expense_button_action_uri") ?? mainActionUrl,
      monthSectionLabel: str("bicount_widget_month_section_label"),
      nextItemSectionLabel: str("bicount_widget_next_item_section_label"),
      weekSectionLabel: str("bicount_widget_week_section_label"),
      weekSectionCompactLabel: str("bicount_widget_week_section_compact_label"),
      entriesLabel: str("bicount_widget_entries_label"),
      exitsLabel: str("bicount_widget_exits_label"),
      titleColor: color("bicount_widget_title_color", default: 0xFF212121),
      subtitleColor: color("bicount_widget_subtitle_color", default: 0xFF9AA0A6),
      buttonTextColor: color("bicount_widget_button_text_color", default: 0xFFF9F9F9)
    )
  }
}

// MARK: - Root view: picks the layout per widget family

struct BicountHomeWidgetEntryView: View {
  var entry: BicountHomeWidgetProvider.Entry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(entry.backgroundColor)
        .overlay(
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(entry.borderColor, lineWidth: 1)
        )

      Group {
        switch family {
        case .systemMedium:
          WideLayout(entry: entry)
        case .systemLarge:
          LargeLayout(entry: entry)
        default:
          SmallLayout(entry: entry)
        }
      }
      .padding(16)
    }
    .bicountWidgetBackground()
  }
}

// MARK: - Small: badge + balance + delta + single CTA

private struct SmallLayout: View {
  let entry: BicountHomeWidgetEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      EyebrowText(text: entry.eyebrow, color: entry.subtitleColor)

      Text(entry.balance)
        .font(.system(size: 22, weight: .bold))
        .foregroundColor(entry.balanceColor)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.top, 6)
        .frame(maxWidth: .infinity, alignment: .leading)

      if !entry.monthDeltaLabel.isEmpty {
        Text(entry.monthDeltaLabel)
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(entry.monthDeltaColor)
          .lineLimit(1)
          .padding(.top, 4)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      Spacer(minLength: 12)

      WidgetButton(
        label: entry.singleButtonLabel,
        textColor: entry.buttonTextColor,
        background: Color(argb: 0xFF76A646),
        actionUrl: entry.singleButtonActionUrl
      )
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - Medium (wide): balance+delta on the left, mini chart + stacked CTAs on the right

private struct WideLayout: View {
  let entry: BicountHomeWidgetEntry

  var body: some View {
    HStack(alignment: .center, spacing: 14) {
      VStack(alignment: .leading, spacing: 0) {
        EyebrowText(text: entry.eyebrow, color: entry.subtitleColor)

        Text(entry.balance)
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(entry.balanceColor)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          .padding(.top, 4)

        if !entry.monthDeltaLabel.isEmpty {
          Text(entry.monthDeltaLabel)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(entry.monthDeltaColor)
            .lineLimit(1)
            .padding(.top, 2)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Rectangle()
        .fill(entry.borderColor)
        .frame(width: 1)
        .padding(.vertical, 4)

      VStack(alignment: .leading, spacing: 8) {
        EyebrowText(text: entry.weekSectionCompactLabel, color: entry.subtitleColor, size: 9)

        BarChartView(
          values: entry.weekValues,
          highlightIndex: entry.weekHighlightIndex,
          barColor: Color(argb: 0xFFD5D8DC),
          highlightColor: Color(argb: 0xFF76A646)
        )
        .frame(width: 64, height: 26)

        HStack(spacing: 6) {
          WidgetButton(
            label: entry.incomeButtonLabel,
            textColor: .white,
            background: Color(argb: 0xFF76A646),
            actionUrl: entry.incomeButtonActionUrl,
            compact: true
          )
          WidgetButton(
            label: entry.expenseButtonLabel,
            textColor: .white,
            background: Color(argb: 0xFFF44336),
            actionUrl: entry.expenseButtonActionUrl,
            compact: true
          )
        }
      }
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Large: balance + weekly chart + two CTAs + recent transaction

private struct LargeLayout: View {
  let entry: BicountHomeWidgetEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      EyebrowText(text: entry.eyebrow, color: entry.subtitleColor)

      Text(entry.balance)
        .font(.system(size: 26, weight: .bold))
        .foregroundColor(entry.balanceColor)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .leading)

      EyebrowText(text: entry.weekSectionLabel, color: entry.subtitleColor, size: 10)
        .padding(.top, 14)

      BarChartView(
        values: entry.weekValues,
        highlightIndex: entry.weekHighlightIndex,
        barColor: Color(argb: 0xFFD5D8DC),
        highlightColor: Color(argb: 0xFF76A646)
      )
      .frame(height: 56)
      .padding(.top, 10)

      HStack(spacing: 0) {
        ForEach(Array(entry.weekDayLabels.enumerated()), id: \.offset) { _, label in
          Text(label)
            .font(.system(size: 10))
            .foregroundColor(entry.subtitleColor)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.top, 4)

      HStack(spacing: 8) {
        WidgetButton(
          label: entry.incomeButtonLabel,
          textColor: .white,
          background: Color(argb: 0xFF76A646),
          actionUrl: entry.incomeButtonActionUrl
        )
        WidgetButton(
          label: entry.expenseButtonLabel,
          textColor: .white,
          background: Color(argb: 0xFFF44336),
          actionUrl: entry.expenseButtonActionUrl
        )
      }
      .padding(.top, 14)

      if !entry.recentItemLabel.isEmpty {
        Rectangle()
          .fill(entry.borderColor)
          .frame(height: 1)
          .padding(.top, 14)
          .padding(.bottom, 10)

        HStack {
          Text(entry.recentItemLabel)
            .font(.system(size: 13))
            .foregroundColor(entry.titleColor)
            .lineLimit(1)
          Spacer()
          Text(entry.recentItemAmountLabel)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(entry.recentItemAmountColor)
        }
      } else {
        Spacer(minLength: 0)
      }
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - Shared pieces

private struct EyebrowText: View {
  let text: String
  let color: Color
  var size: CGFloat = 11

  var body: some View {
    Text(text)
      .font(.system(size: size, weight: .bold))
      .foregroundColor(color)
  }
}

private struct WidgetButton: View {
  let label: String
  let textColor: Color
  let background: Color
  let actionUrl: URL?
  var compact: Bool = false

  var body: some View {
    let content = Text(label)
      .font(.system(size: compact ? 11 : 13, weight: .semibold))
      .foregroundColor(textColor)
      .padding(.vertical, compact ? 8 : 12)
      .padding(.horizontal, compact ? 12 : 0)
      .frame(maxWidth: compact ? nil : .infinity)
      .background(
        RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous)
          .fill(background)
      )

    if let actionUrl {
      Link(destination: actionUrl) { content }
        .buttonStyle(.plain)
    } else {
      content
    }
  }
}

/// Hand-rolled bar chart — RemoteViews/WidgetKit can't host Flutter or a
/// third-party charting library, so bars are plain proportional rectangles.
private struct BarChartView: View {
  let values: [Double]
  let highlightIndex: Int
  let barColor: Color
  let highlightColor: Color

  var body: some View {
    GeometryReader { proxy in
      let maxValue = max(values.max() ?? 0, 0.01)
      HStack(alignment: .bottom, spacing: max(proxy.size.width * 0.06, 2)) {
        ForEach(Array(values.enumerated()), id: \.offset) { index, value in
          RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(index == highlightIndex ? highlightColor : barColor)
            .frame(height: max(proxy.size.height * CGFloat(value / maxValue), 4))
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
    }
  }
}

private extension View {
  @ViewBuilder
  func linkable(_ url: URL?) -> some View {
    if let url {
      Link(destination: url) { self }
        .buttonStyle(.plain)
    } else {
      self
    }
  }
}

struct BicountHomeWidget: Widget {
  let kind: String = widgetKind

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: BicountHomeWidgetProvider()) { entry in
      BicountHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Bicount overview")
    .description("Quick access to your balance and finance actions.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
