import SwiftUI

/// The Atlas mark: a six-band rainbow arc grounded by a white line, with a white
/// map pin sitting on top. Drawn natively from the design's SVG (viewBox
/// 0 0 200 200) rather than a rasterized image — the previous `AtlasMark.png`
/// was a mis-cropped export that only showed a corner of the arc, and a native
/// drawing stays crisp at any size besides.
struct AtlasMark: View {
  private static let bands: [(radius: CGFloat, color: Color)] = [
    (80, Color(red: 1.00, green: 0.353, blue: 0.353)),  // #ff5a5a
    (68, Color(red: 1.00, green: 0.651, blue: 0.239)),  // #ffa63d
    (56, Color(red: 1.00, green: 0.784, blue: 0.239)),  // #ffc83d
    (44, Color(red: 0.239, green: 0.863, blue: 0.592)), // #3ddc97
    (32, Color(red: 0.239, green: 0.608, blue: 1.00)),  // #3d9bff
    (20, Color(red: 0.608, green: 0.427, blue: 1.00)),  // #9b6dff
  ]

  var body: some View {
    Canvas { context, size in
      let scale = size.width / 200
      func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }

      for band in Self.bands {
        var arc = Path()
        arc.addArc(
          center: point(100, 172),
          radius: band.radius * scale,
          startAngle: .degrees(180),
          endAngle: .degrees(360),
          clockwise: false
        )
        context.stroke(arc, with: .color(band.color), style: StrokeStyle(lineWidth: 11 * scale, lineCap: .round))
      }

      var ground = Path()
      ground.move(to: point(10, 178))
      ground.addLine(to: point(190, 178))
      context.stroke(ground, with: .color(.white.opacity(0.9)), style: StrokeStyle(lineWidth: 4 * scale, lineCap: .round))

      var pin = Path()
      pin.addArc(center: point(100, 148), radius: 20 * scale, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
      pin.addCurve(to: point(100, 198), control1: point(120, 170), control2: point(100, 198))
      pin.addCurve(to: point(80, 148), control1: point(100, 198), control2: point(80, 170))
      pin.closeSubpath()
      context.fill(pin, with: .color(.white))

      let holeRadius = 10 * scale
      let hole = Path(ellipseIn: CGRect(x: point(100, 148).x - holeRadius, y: point(100, 148).y - holeRadius, width: holeRadius * 2, height: holeRadius * 2))
      context.fill(hole, with: .color(AtlasColor.iconBlue))
    }
    .accessibilityHidden(true)
  }
}
