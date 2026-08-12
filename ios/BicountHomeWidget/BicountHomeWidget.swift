import SwiftUI
import WidgetKit

private let widgetKind = "BicountHomeWidget"
private let widgetGroupId = "group.com.youngsolver.bicount"
private let listDelimiter: Character = "|"

private let incomeColor = Color(argb: 0xFF76A646)
private let expenseColor = Color(argb: 0xFFF44336)

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

/// One recent-transaction row, deep-linking to its own transaction.
struct BicountRecentItem: Identifiable {
  let id = UUID()
  let label: String
  let amountLabel: String
  let amountColor: Color
  let actionUrl: URL?
}

struct BicountHomeWidgetEntry: TimelineEntry {
  let date: Date
  let isDarkTheme: Bool
  let eyebrow: String
  let balance: String
  let balanceColor: Color
  let mainActionUrl: URL?

  let monthIncomeValue: Double
  let monthIncomeLabel: String
  /// Turns red when the month opens on a carried-over overdraft.
  let monthIncomeColor: Color
  let monthExpenseValue: Double
  let monthExpenseLabel: String

  let monthDailyIncome: [Double]
  let monthDailyExpense: [Double]

  let recentItems: [BicountRecentItem]

  let singleButtonLabel: String
  let singleButtonActionUrl: URL?
  let incomeButtonLabel: String
  let incomeButtonActionUrl: URL?
  let expenseButtonLabel: String
  let expenseButtonActionUrl: URL?

  let monthSectionLabel: String
  let monthCurveLabel: String
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

  /// "In 480 $" / "Out 100 $" — legend word and amount in one string so the
  /// narrow layouts can show both on a single line. Mirrors the Android
  /// `incomeTotalText` / `expenseTotalText` helpers.
  var incomeTotalText: String {
    [entriesLabel, monthIncomeLabel].filter { !$0.isEmpty }.joined(separator: " ")
  }

  var expenseTotalText: String {
    [exitsLabel, monthExpenseLabel].filter { !$0.isEmpty }.joined(separator: " ")
  }

  static var placeholder: BicountHomeWidgetEntry {
    BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: false,
      eyebrow: "BICOUNT",
      balance: "2 340 €",
      balanceColor: Color(argb: 0xFF212121),
      mainActionUrl: URL(string: "bicount://widget/open-home?homeWidget=1"),
      monthIncomeValue: 850,
      monthIncomeLabel: "850 €",
      monthIncomeColor: incomeColor,
      monthExpenseValue: 420,
      monthExpenseLabel: "420 €",
      monthDailyIncome: [0, 120, 0, 0, 300, 0, 430],
      monthDailyExpense: [40, 0, 90, 120, 0, 70, 100],
      recentItems: [],
      singleButtonLabel: "+ Ajouter",
      singleButtonActionUrl: URL(string: "bicount://widget/add-transaction?homeWidget=1"),
      incomeButtonLabel: "+ Revenu",
      incomeButtonActionUrl: URL(string: "bicount://widget/add-income?homeWidget=1"),
      expenseButtonLabel: "- Dépense",
      expenseButtonActionUrl: URL(string: "bicount://widget/add-expense?homeWidget=1"),
      monthSectionLabel: "CE MOIS",
      monthCurveLabel: "ENTRÉES ET SORTIES · CE MOIS",
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

    func doubleSeries(_ key: String) -> [Double] {
      str(key)
        .split(separator: listDelimiter, omittingEmptySubsequences: true)
        .compactMap { Double($0) }
    }

    // Stored as JSON because transaction names are free text: a
    // delimiter-joined string could not survive them safely.
    func parseRecentItems(_ key: String, fallbackColor: Color) -> [BicountRecentItem] {
      let raw = str(key)
      guard
        !raw.isEmpty,
        let data = raw.data(using: .utf8),
        let array = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]]
      else {
        return []
      }
      return array.map { item in
        BicountRecentItem(
          label: item["label"] as? String ?? "",
          amountLabel: item["amount"] as? String ?? "",
          amountColor: (item["color"] as? NSNumber).map { Color(argb: $0.intValue) } ?? fallbackColor,
          actionUrl: URL(string: item["uri"] as? String ?? "")
        )
      }
    }

    let isDarkTheme = preferences?.bool(forKey: "bicount_widget_theme_is_dark") ?? false
    let mainActionUrl = url("bicount_widget_main_action_uri")
    let titleColor = color("bicount_widget_title_color", default: 0xFF212121)

    return BicountHomeWidgetEntry(
      date: Date(),
      isDarkTheme: isDarkTheme,
      eyebrow: str("bicount_widget_eyebrow", default: "BICOUNT"),
      balance: str("bicount_widget_balance", default: "Open Bicount"),
      balanceColor: color("bicount_widget_balance_color", default: 0xFF212121),
      mainActionUrl: mainActionUrl,
      monthIncomeValue: rawDouble("bicount_widget_month_income_value"),
      monthIncomeLabel: str("bicount_widget_month_income_label"),
      monthIncomeColor: color("bicount_widget_month_income_color", default: 0xFF76A646),
      monthExpenseValue: rawDouble("bicount_widget_month_expense_value"),
      monthExpenseLabel: str("bicount_widget_month_expense_label"),
      monthDailyIncome: doubleSeries("bicount_widget_month_daily_income"),
      monthDailyExpense: doubleSeries("bicount_widget_month_daily_expense"),
      recentItems: parseRecentItems("bicount_widget_recent_items", fallbackColor: titleColor),
      singleButtonLabel: str("bicount_widget_single_button_label", default: "Open app"),
      singleButtonActionUrl: url("bicount_widget_single_button_action_uri") ?? mainActionUrl,
      incomeButtonLabel: str("bicount_widget_income_button_label"),
      incomeButtonActionUrl: url("bicount_widget_income_button_action_uri") ?? mainActionUrl,
      expenseButtonLabel: str("bicount_widget_expense_button_label"),
      expenseButtonActionUrl: url("bicount_widget_expense_button_action_uri") ?? mainActionUrl,
      monthSectionLabel: str("bicount_widget_month_section_label"),
      monthCurveLabel: str("bicount_widget_month_curve_label"),
      entriesLabel: str("bicount_widget_entries_label"),
      exitsLabel: str("bicount_widget_exits_label"),
      titleColor: titleColor,
      subtitleColor: color("bicount_widget_subtitle_color", default: 0xFF9AA0A6),
      buttonTextColor: color("bicount_widget_button_text_color", default: 0xFFF9F9F9)
    )
  }
}

// MARK: - Root view: one layout per widget family

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
          MediumLayout(entry: entry)
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

// MARK: - Small: eyebrow, centred balance + month totals, single CTA

private struct SmallLayout: View {
  let entry: BicountHomeWidgetEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      EyebrowText(text: entry.eyebrow, color: entry.subtitleColor)
        .frame(maxWidth: .infinity, alignment: .center)

      // Balance and totals share one expanding block so they stay centred
      // between the eyebrow and the button (mirrors the Android XS layout).
      VStack(spacing: 4) {
        Spacer(minLength: 0)
        Text(entry.balance)
          .font(.system(size: 22, weight: .bold))
          .foregroundColor(entry.balanceColor)
          .lineLimit(1)
          .minimumScaleFactor(0.6)

        Text(entry.incomeTotalText)
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(entry.monthIncomeColor)
          .lineLimit(1)
          .minimumScaleFactor(0.7)

        Text(entry.expenseTotalText)
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(expenseColor)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity)

      WidgetButton(
        label: entry.singleButtonLabel,
        textColor: entry.buttonTextColor,
        background: incomeColor,
        actionUrl: entry.singleButtonActionUrl
      )
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - Medium: balance, month totals, two CTAs

private struct MediumLayout: View {
  let entry: BicountHomeWidgetEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        EyebrowText(text: entry.eyebrow, color: entry.subtitleColor)
        Spacer()
        Text(entry.balance)
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(entry.balanceColor)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }

      Rectangle()
        .fill(entry.borderColor)
        .frame(height: 1)
        .padding(.vertical, 12)

      EyebrowText(text: entry.monthSectionLabel, color: entry.subtitleColor, size: 10)

      VStack(spacing: 6) {
        Spacer(minLength: 0)
        MoneyRow(
          label: entry.entriesLabel,
          amount: entry.monthIncomeLabel,
          labelColor: entry.subtitleColor,
          amountColor: entry.monthIncomeColor
        )
        MoneyRow(
          label: entry.exitsLabel,
          amount: entry.monthExpenseLabel,
          labelColor: entry.subtitleColor,
          amountColor: expenseColor
        )
        Spacer(minLength: 0)
      }
      .padding(.top, 8)

      HStack(spacing: 8) {
        WidgetButton(
          label: entry.incomeButtonLabel,
          textColor: .white,
          background: incomeColor,
          actionUrl: entry.incomeButtonActionUrl
        )
        WidgetButton(
          label: entry.expenseButtonLabel,
          textColor: .white,
          background: expenseColor,
          actionUrl: entry.expenseButtonActionUrl
        )
      }
      .padding(.top, 14)
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - Large: balance, month curves + totals, two CTAs, recent list

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

      EyebrowText(text: entry.monthCurveLabel, color: entry.subtitleColor, size: 10)
        .padding(.top, 14)

      // The curves show the month's shape; these totals give the figures a
      // curve alone cannot convey.
      HStack {
        Text(entry.incomeTotalText)
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(entry.monthIncomeColor)
          .lineLimit(1)
        Spacer()
        Text(entry.expenseTotalText)
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(expenseColor)
          .lineLimit(1)
      }
      .padding(.top, 6)

      DualLineChart(
        incomeSeries: entry.monthDailyIncome,
        expenseSeries: entry.monthDailyExpense
      )
      .frame(minHeight: 48)
      .padding(.top, 8)

      HStack(spacing: 8) {
        WidgetButton(
          label: entry.incomeButtonLabel,
          textColor: .white,
          background: incomeColor,
          actionUrl: entry.incomeButtonActionUrl
        )
        WidgetButton(
          label: entry.expenseButtonLabel,
          textColor: .white,
          background: expenseColor,
          actionUrl: entry.expenseButtonActionUrl
        )
      }
      .padding(.top, 12)

      if !entry.recentItems.isEmpty {
        Rectangle()
          .fill(entry.borderColor)
          .frame(height: 1)
          .padding(.top, 12)
          .padding(.bottom, 6)

        // systemLarge fits roughly three rows; the rest of the payload
        // stays unused rather than overflowing the card.
        ForEach(entry.recentItems.prefix(3)) { item in
          RecentRow(item: item, titleColor: entry.titleColor)
        }
      }

      Spacer(minLength: 0)
    }
    .linkable(entry.mainActionUrl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - Shared pieces

private struct MoneyRow: View {
  let label: String
  let amount: String
  let labelColor: Color
  let amountColor: Color

  var body: some View {
    HStack {
      Text(label)
        .font(.system(size: 13))
        .foregroundColor(labelColor)
        .lineLimit(1)
      Spacer()
      Text(amount)
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(amountColor)
        .lineLimit(1)
    }
  }
}

private struct RecentRow: View {
  let item: BicountRecentItem
  let titleColor: Color

  var body: some View {
    let row = HStack {
      Text(item.label)
        .font(.system(size: 13))
        .foregroundColor(titleColor)
        .lineLimit(1)
      Spacer()
      Text(item.amountLabel)
        .font(.system(size: 13, weight: .bold))
        .foregroundColor(item.amountColor)
        .lineLimit(1)
    }
    .padding(.vertical, 5)

    // Each row opens its own transaction rather than the card action.
    if let actionUrl = item.actionUrl {
      Link(destination: actionUrl) { row }.buttonStyle(.plain)
    } else {
      row
    }
  }
}

private struct EyebrowText: View {
  let text: String
  let color: Color
  var size: CGFloat = 11

  var body: some View {
    Text(text)
      .font(.system(size: size, weight: .bold))
      .foregroundColor(color)
      .lineLimit(1)
  }
}

private struct WidgetButton: View {
  let label: String
  let textColor: Color
  let background: Color
  let actionUrl: URL?

  var body: some View {
    let content = Text(label)
      .font(.system(size: 13, weight: .semibold))
      .foregroundColor(textColor)
      .lineLimit(1)
      .padding(.vertical, 12)
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .fill(background)
      )

    if let actionUrl {
      Link(destination: actionUrl) { content }.buttonStyle(.plain)
    } else {
      content
    }
  }
}

/// Two overlaid curves (daily income vs daily expense over the month).
/// Hand-rolled for the same reason as on Android: a widget process cannot
/// host Flutter or a charting library.
private struct DualLineChart: View {
  let incomeSeries: [Double]
  let expenseSeries: [Double]

  var body: some View {
    GeometryReader { proxy in
      // Both curves share one scale so they stay visually comparable.
      let maxValue = max(
        incomeSeries.max() ?? 0,
        expenseSeries.max() ?? 0,
        0.01
      )
      ZStack {
        curve(for: incomeSeries, maxValue: maxValue, size: proxy.size)
          .stroke(incomeColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        curve(for: expenseSeries, maxValue: maxValue, size: proxy.size)
          .stroke(expenseColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
      }
    }
  }

  private func curve(for series: [Double], maxValue: Double, size: CGSize) -> Path {
    Path { path in
      guard series.count > 1 else { return }
      let inset: CGFloat = 2
      let usableHeight = size.height - inset * 2
      let stepX = (size.width - inset * 2) / CGFloat(series.count - 1)
      for (index, value) in series.enumerated() {
        let ratio = CGFloat(min(max(value / maxValue, 0), 1))
        let point = CGPoint(
          x: inset + stepX * CGFloat(index),
          y: inset + usableHeight * (1 - ratio)
        )
        if index == 0 {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
    }
  }
}

private extension View {
  @ViewBuilder
  func linkable(_ url: URL?) -> some View {
    if let url {
      Link(destination: url) { self }.buttonStyle(.plain)
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
