import SwiftUI

/// Screen 01 — Splash.
///
/// Background, rainbow, mark and wordmark positions are all transcribed from the
/// design's exported `Splash.svg` (see `AtlasMark` for how the mark itself is
/// built) — the outer SVG frame is 417×822 with the actual screen content living
/// inside a 361×771 inset at (26, 24); `point(_:_:)` maps that design space onto
/// whatever size this view actually renders at.
///
/// `LaunchScreen.storyboard` (the system-rendered screen shown before this view ever
/// runs) is solid blue with no mark or wordmark — it can't load the bundled display
/// font, so any text or logo placed there would either flash in the wrong font or
/// pop in a beat before this view takes over. The background gradient's top color
/// is close enough to the launch screen's blue that the handoff still reads as
/// smooth once the mark and wordmark fade in.
struct SplashView: View {
  @State private var isVisible = false

  var body: some View {
    GeometryReader { geometry in
      let scaleX = geometry.size.width / 361
      let scaleY = geometry.size.height / 771
      let point: (CGFloat, CGFloat) -> CGPoint = { x, y in
        CGPoint(x: (x - 26) * scaleX, y: (y - 24) * scaleY)
      }

      ZStack {
        LinearGradient(
          colors: [.white, Color(hex: 0x08A0FF)],
          startPoint: UnitPoint(x: 0.5, y: -0.024),
          endPoint: UnitPoint(x: 0.5, y: 0.6)
        )

        Canvas { context, _ in
          func radial(_ inner: UInt32, _ outer: UInt32, centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> GraphicsContext.Shading {
            .radialGradient(
              Gradient(colors: [Color(hex: inner), Color(hex: outer)]),
              center: point(centerX, centerY),
              startRadius: 0,
              endRadius: radius * scaleX
            )
          }

          var band0 = Path()
          band0.move(to: point(-27.9068, 742.079))
          band0.addLine(to: point(-5.63291, 719.805))
          band0.addCurve(to: point(414.102, 723.761), control1: point(109.181, 604.991), control2: point(297.103, 606.762))
          band0.addLine(to: point(436.8, 746.459))
          band0.addLine(to: point(481.347, 701.911))
          band0.addCurve(to: point(480.924, 656.94), control1: point(493.649, 689.61), control2: point(493.459, 669.475))
          band0.addCurve(to: point(-73.7261, 651.711), control1: point(326.318, 502.334), control2: point(77.9925, 499.993))
          band0.addCurve(to: point(-73.3023, 696.683), control1: point(-86.0277, 664.013), control2: point(-85.8379, 684.147))
          band0.addLine(to: point(-27.9068, 742.079))
          band0.closeSubpath()
          context.fill(band0, with: radial(0xFF4000, 0x8754C9, centerX: 203.8, centerY: 623.2, radius: 300))

          var band1 = Path()
          band1.move(to: point(-35.4727, 734.513))
          band1.addLine(to: point(-13.1988, 712.239))
          band1.addCurve(to: point(421.527, 716.336), control1: point(105.716, 593.324), control2: point(300.349, 595.159))
          band1.addLine(to: point(444.224, 739.034))
          band1.addLine(to: point(377.403, 805.856))
          band1.addLine(to: point(354.705, 783.158))
          band1.addCurve(to: point(54.8944, 780.332), control1: point(271.134, 699.587), control2: point(136.905, 698.322))
          band1.addLine(to: point(32.6206, 802.606))
          band1.addLine(to: point(-35.4727, 734.513))
          band1.closeSubpath()
          context.fill(band1, with: radial(0xFFF700, 0xFF9901, centerX: 204.4, centerY: 699.6, radius: 250))

          var band2 = Path()
          band2.move(to: point(362.129, 775.733))
          band2.addLine(to: point(421.526, 716.336))
          band2.addLine(to: point(444.224, 739.034))
          band2.addLine(to: point(384.827, 798.431))
          band2.addLine(to: point(362.129, 775.733))
          band2.closeSubpath()
          context.fill(
            band2,
            with: .linearGradient(
              Gradient(colors: [Color(hex: 0xFFF700), Color(hex: 0xFF9901)]),
              startPoint: point(373.478, 787.082),
              endPoint: point(432.875, 727.685)
            )
          )

          var band3 = Path()
          band3.move(to: point(25.0547, 795.04))
          band3.addLine(to: point(-35.4727, 734.513))
          band3.addLine(to: point(-13.1988, 712.239))
          band3.addLine(to: point(47.3285, 772.766))
          band3.addLine(to: point(25.0547, 795.04))
          band3.closeSubpath()
          context.fill(
            band3,
            with: .linearGradient(
              Gradient(colors: [Color(hex: 0xFFF700), Color(hex: 0xFF9901)]),
              startPoint: point(36.1916, 783.903),
              endPoint: point(-24.3357, 723.376)
            )
          )

          var band4 = Path()
          band4.move(to: point(62.8838, 832.87))
          band4.addCurve(to: point(107.855, 833.294), control1: point(75.4194, 845.405), control2: point(95.5539, 845.595))
          band4.addCurve(to: point(302.732, 835.13), control1: point(161.162, 779.987), control2: point(248.411, 780.809))
          band4.addCurve(to: point(347.704, 835.554), control1: point(315.268, 847.666), control2: point(335.402, 847.856))
          band4.addLine(to: point(384.827, 798.431))
          band4.addLine(to: point(362.129, 775.733))
          band4.addCurve(to: point(47.3281, 772.766), control1: point(274.38, 687.984), control2: point(133.439, 686.656))
          band4.addLine(to: point(25.0542, 795.04))
          band4.addLine(to: point(62.8838, 832.87))
          band4.closeSubpath()
          context.fill(band4, with: radial(0x00AAFF, 0x01DA40, centerX: 204.9, centerY: 767.3, radius: 200))

          var band5 = Path()
          band5.move(to: point(302.732, 835.131))
          band5.addLine(to: point(362.129, 775.734))
          band5.addLine(to: point(384.827, 798.432))
          band5.addLine(to: point(347.704, 835.555))
          band5.addCurve(to: point(302.732, 835.131), control1: point(335.402, 847.856), control2: point(315.268, 847.666))
          band5.closeSubpath()
          context.fill(band5, with: radial(0x00AAFF, 0x01DA40, centerX: 343.8, centerY: 811.8, radius: 60))

          var band6 = Path()
          band6.move(to: point(107.855, 833.294))
          band6.addCurve(to: point(62.8838, 832.87), control1: point(95.5539, 845.595), control2: point(75.4194, 845.405))
          band6.addLine(to: point(25.0542, 795.04))
          band6.addLine(to: point(47.3281, 772.766))
          band6.addLine(to: point(107.855, 833.294))
          band6.closeSubpath()
          context.fill(band6, with: radial(0x00AAFF, 0x01DA40, centerX: 66.5, centerY: 809.2, radius: 60))
        }

        VStack(spacing: 17 * scaleY) {
          AtlasMark(style: .splash)
            .frame(width: 95 * scaleX, height: 98 * scaleY)
          Wordmark()
            .frame(width: 260 * scaleX)
        }
        .position(point(207.5, 295))
      }
      .opacity(isVisible ? 1 : 0)
    }
    .ignoresSafeArea()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Goeieplek")
    .onAppear {
      withAnimation(.easeOut(duration: 0.3)) {
        isVisible = true
      }
    }
  }
}
