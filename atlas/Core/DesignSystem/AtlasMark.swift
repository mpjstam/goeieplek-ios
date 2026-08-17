import SwiftUI

/// The Atlas mark: a heart — places that matter to you — sitting on a closed
/// rainbow ring swept with a conic gradient. Drawn natively (viewBox 0 0 200 200)
/// rather than a rasterized image so it stays crisp at any size and matches the
/// blue used elsewhere in the design system exactly.
struct AtlasMark: View {
  var body: some View {
    Canvas { context, size in
      let scale = size.width / 200
      func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }

      let ring = Path(
        ellipseIn: CGRect(
          x: point(18, 148).x, y: point(18, 148).y,
          width: 164 * scale, height: 56 * scale
        )
      )
      context.stroke(
        ring,
        with: .conicGradient(
          Gradient(colors: [
            Color(red: 0.239, green: 0.608, blue: 1.00),  // blue
            Color(red: 0.239, green: 0.784, blue: 0.784), // teal
            Color(red: 0.239, green: 0.863, blue: 0.592), // green
            Color(red: 1.00, green: 0.784, blue: 0.239),  // yellow
            Color(red: 1.00, green: 0.651, blue: 0.239),  // orange
            Color(red: 1.00, green: 0.353, blue: 0.353),  // red
            Color(red: 0.608, green: 0.427, blue: 1.00),  // purple
            Color(red: 0.239, green: 0.608, blue: 1.00),  // blue (seam)
          ]),
          center: point(100, 176),
          angle: .degrees(-90)
        ),
        style: StrokeStyle(lineWidth: 13 * scale, lineCap: .round)
      )

      let r: CGFloat = 33
      let lobeY: CGFloat = 68
      let tipY: CGFloat = 152
      var heart = Path()
      heart.move(to: point(100, tipY))
      heart.addCurve(to: point(100 - r * 2, lobeY), control1: point(84, 128), control2: point(100 - r * 2, 98))
      heart.addArc(center: point(100 - r, lobeY), radius: r * scale, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
      heart.addArc(center: point(100 + r, lobeY), radius: r * scale, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
      heart.addCurve(to: point(100, tipY), control1: point(100 + r * 2, 98), control2: point(116, 128))
      heart.closeSubpath()

      context.fill(
        heart,
        with: .linearGradient(
          Gradient(colors: [
            Color(red: 0.549, green: 0.808, blue: 1.00),
            Color(red: 0.055, green: 0.616, blue: 1.00),
          ]),
          startPoint: point(100, 35),
          endPoint: point(100, tipY)
        )
      )
      context.stroke(heart, with: .color(Color(red: 0.055, green: 0.522, blue: 0.949)), style: StrokeStyle(lineWidth: 2.5 * scale))
    }
    .accessibilityHidden(true)
  }
}
