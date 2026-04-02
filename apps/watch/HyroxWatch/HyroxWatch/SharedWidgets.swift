import SwiftUI

// ── Shared UI components used across watch views ─────────────────────────────

/// A single metric column: label on top, monospaced value below.
struct _WatchMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundColor(.init(white: 0.4))
                .tracking(1)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Nothing-design segmented progress bar: rectangular blocks, 2 pt gaps.
struct _SegmentedBar: View {
    let total: Int
    let completed: Int
    let accentCurrent: Bool

    private let gap: CGFloat = 2
    private let height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let totalGaps = CGFloat(max(total - 1, 0)) * gap
            let blockWidth = (geo.size.width - totalGaps) / CGFloat(max(total, 1))

            HStack(spacing: gap) {
                ForEach(0..<total, id: \.self) { i in
                    Rectangle()
                        .fill(blockColor(for: i))
                        .frame(width: max(blockWidth, 1), height: height)
                }
            }
        }
        .frame(height: height)
    }

    private func blockColor(for i: Int) -> Color {
        if i < completed {
            return Color(white: 0.25)          // done — dimmed
        } else if i == completed {
            return accentCurrent
                ? Color(red: 0.843, green: 0.098, blue: 0.129) // accent red
                : Color.white                                    // white
        } else {
            return Color(white: 0.12)          // future — very dark
        }
    }
}
