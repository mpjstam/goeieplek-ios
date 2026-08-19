import SwiftUI

/// The Goeieplek mark: a heart fused into a single pin-point shape, wrapped by a
/// small rainbow ring. Path geometry is transcribed directly from the design's
/// exported SVGs (not hand-drawn) so the curves match exactly — `.splash` from
/// `Splash.svg`, `.icon` from `home.svg` (a distinct, independently-drawn shape
/// for small sizes, not a scaled copy of the splash mark).
struct AtlasMark: View {
  enum Style {
    case splash
    case icon
  }

  var style: Style = .splash

  var body: some View {
    Canvas { context, size in
      switch style {
      case .splash: drawSplash(context: context, size: size)
      case .icon: drawIcon(context: context, size: size)
      }
    }
    .accessibilityHidden(true)
  }

  // MARK: - Splash (from Splash.svg, source coordinates ~x:147-258 y:209-319)

  private func drawSplash(context: GraphicsContext, size: CGSize) {
    let scale = size.width / 110
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
      CGPoint(x: (x - 147.5) * scale, y: (y - 209) * scale)
    }

    var ring = Path()
    ring.move(to: point(202.525, 313))
    ring.addCurve(to: point(182.364, 311.907), control1: point(194.988, 313), control2: point(188.268, 312.636))
    ring.addCurve(to: point(167.457, 308.991), control1: point(176.495, 311.198), control2: point(171.525, 310.226))
    ring.addCurve(to: point(158.152, 304.829), control1: point(163.388, 307.776), control2: point(160.286, 306.389))
    ring.addCurve(to: point(155, 300), control1: point(156.051, 303.29), control2: point(155, 301.681))
    ring.addCurve(to: point(157.251, 295.596), control1: point(155, 298.4), control2: point(155.75, 296.932))
    ring.addCurve(to: point(163.254, 291.981), control1: point(158.752, 294.239), control2: point(160.753, 293.034))
    ring.addCurve(to: point(171.559, 289.308), control1: point(165.756, 290.928), control2: point(168.524, 290.037))
    ring.addCurve(to: point(180.864, 287.607), control1: point(174.627, 288.559), control2: point(177.729, 287.992))
    ring.addCurve(to: point(187.492, 287.043), control1: point(183.19, 287.31), control2: point(185.4, 287.122))
    ring.addCurve(to: point(189.718, 289.227), control1: point(188.721, 286.996), control2: point(189.718, 287.997))
    ring.addCurve(to: point(187.512, 291.504), control1: point(189.718, 290.449), control2: point(188.732, 291.439))
    ring.addCurve(to: point(181.864, 292.072), control1: point(185.736, 291.599), control2: point(183.853, 291.788))
    ring.addCurve(to: point(173.81, 293.682), control1: point(179.029, 292.457), control2: point(176.345, 292.994))
    ring.addCurve(to: point(167.557, 296.143), control1: point(171.275, 294.371), control2: point(169.191, 295.191))
    ring.addCurve(to: point(165.155, 299.271), control1: point(165.956, 297.094), control2: point(165.155, 298.137))
    ring.addCurve(to: point(167.907, 302.886), control1: point(165.155, 300.587), control2: point(166.072, 301.792))
    ring.addCurve(to: point(175.711, 305.71), control1: point(169.774, 303.979), control2: point(172.376, 304.921))
    ring.addCurve(to: point(187.567, 307.533), control1: point(179.079, 306.5), control2: point(183.031, 307.107))
    ring.addCurve(to: point(202.525, 308.201), control1: point(192.136, 307.978), control2: point(197.122, 308.201))
    ring.addCurve(to: point(217.383, 307.533), control1: point(207.895, 308.201), control2: point(212.847, 307.978))
    ring.addCurve(to: point(229.239, 305.68), control1: point(221.952, 307.107), control2: point(225.904, 306.49))
    ring.addCurve(to: point(237.093, 302.855), control1: point(232.608, 304.89), control2: point(235.226, 303.949))
    ring.addCurve(to: point(239.895, 299.271), control1: point(238.961, 301.782), control2: point(239.895, 300.587))
    ring.addCurve(to: point(237.443, 296.143), control1: point(239.895, 298.137), control2: point(239.078, 297.094))
    ring.addCurve(to: point(231.19, 293.682), control1: point(235.809, 295.191), control2: point(233.725, 294.371))
    ring.addCurve(to: point(223.136, 292.072), control1: point(228.655, 292.994), control2: point(225.971, 292.457))
    ring.addCurve(to: point(217.488, 291.503), control1: point(221.162, 291.787), control2: point(219.28, 291.597))
    ring.addCurve(to: point(215.282, 289.227), control1: point(216.268, 291.439), control2: point(215.282, 290.449))
    ring.addCurve(to: point(217.508, 287.042), control1: point(215.282, 287.997), control2: point(216.279, 286.996))
    ring.addCurve(to: point(224.136, 287.607), control1: point(219.618, 287.121), control2: point(221.827, 287.309))
    ring.addCurve(to: point(233.441, 289.308), control1: point(227.305, 287.992), control2: point(230.406, 288.559))
    ring.addCurve(to: point(241.796, 291.981), control1: point(236.51, 290.037), control2: point(239.294, 290.928))
    ring.addCurve(to: point(247.749, 295.596), control1: point(244.297, 293.034), control2: point(246.281, 294.239))
    ring.addCurve(to: point(250, 300), control1: point(249.25, 296.932), control2: point(250, 298.4))
    ring.addCurve(to: point(246.848, 304.829), control1: point(250, 301.681), control2: point(248.949, 303.29))
    ring.addCurve(to: point(237.593, 308.991), control1: point(244.747, 306.389), control2: point(241.662, 307.776))
    ring.addCurve(to: point(222.636, 311.907), control1: point(233.525, 310.226), control2: point(228.539, 311.198))
    ring.addCurve(to: point(202.525, 313), control1: point(216.766, 312.636), control2: point(210.062, 313))
    ring.closeSubpath()

    context.fill(ring, with: .conicGradient(Self.ringGradient, center: point(202.5, 300.1), angle: .degrees(0)))

    var heart = Path()
    heart.move(to: point(221.336, 215))
    heart.addCurve(to: point(230.276, 216.943), control1: point(224.547, 215), control2: point(227.528, 215.648))
    heart.addCurve(to: point(237.502, 222.463), control1: point(233.052, 218.239), control2: point(235.461, 220.079))
    heart.addCurve(to: point(242.318, 230.941), control1: point(239.57, 224.847), control2: point(241.175, 227.674))
    heart.addCurve(to: point(244.074, 241.672), control1: point(243.489, 234.18), control2: point(244.074, 237.757))
    heart.addCurve(to: point(239.461, 260.306), control1: point(244.074, 247.942), control2: point(242.536, 254.153))
    heart.addCurve(to: point(226.438, 278.234), control1: point(236.413, 266.429), control2: point(232.072, 272.406))
    heart.addCurve(to: point(206.517, 294.882), control1: point(220.832, 284.034), control2: point(214.191, 289.583))
    heart.addCurve(to: point(205.007, 295.677), control1: point(206.081, 295.176), control2: point(205.578, 295.441))
    heart.addCurve(to: point(203.537, 296.074), control1: point(204.463, 295.942), control2: point(203.973, 296.074))
    heart.addCurve(to: point(202.067, 295.677), control1: point(203.129, 296.074), control2: point(202.639, 295.942))
    heart.addCurve(to: point(200.598, 294.882), control1: point(201.523, 295.441), control2: point(201.033, 295.176))
    heart.addCurve(to: point(180.636, 278.234), control1: point(192.923, 289.583), control2: point(186.269, 284.034))
    heart.addCurve(to: point(167.572, 260.306), control1: point(175.002, 272.406), control2: point(170.648, 266.429))
    heart.addCurve(to: point(163, 241.672), control1: point(164.524, 254.153), control2: point(163, 247.942))
    heart.addCurve(to: point(164.715, 230.941), control1: point(163, 237.757), control2: point(163.572, 234.18))
    heart.addCurve(to: point(169.572, 222.463), control1: point(165.885, 227.674), control2: point(167.504, 224.847))
    heart.addCurve(to: point(176.798, 216.943), control1: point(171.641, 220.078), control2: point(174.049, 218.239))
    heart.addCurve(to: point(185.738, 215), control1: point(179.547, 215.648), control2: point(182.527, 215))
    heart.addCurve(to: point(196.271, 218.312), control1: point(189.739, 215), control2: point(193.25, 216.104))
    heart.addCurve(to: point(203.537, 227.055), control1: point(199.291, 220.519), control2: point(201.714, 223.434))
    heart.addCurve(to: point(210.845, 218.312), control1: point(205.388, 223.404), control2: point(207.824, 220.49))
    heart.addCurve(to: point(221.336, 215), control1: point(213.866, 216.104), control2: point(217.363, 215))
    heart.closeSubpath()

    context.fill(
      heart,
      with: .linearGradient(
        Gradient(colors: [Color(hex: 0x7CCDFF), Color(hex: 0x009DFF)]),
        startPoint: point(188, 227),
        endPoint: point(219, 284)
      )
    )
    context.stroke(heart, with: .color(.white), style: StrokeStyle(lineWidth: 3 * scale))
  }

  // MARK: - Icon (from home.svg, source coordinates ~x:40-76 y:112-149)

  private func drawIcon(context: GraphicsContext, size: CGSize) {
    let scale = size.width / 36
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
      CGPoint(x: (x - 40.2) * scale, y: (y - 112.5) * scale)
    }

    var ring = Path()
    ring.move(to: point(58.2038, 146))
    ring.addCurve(to: point(52.1784, 145.459), control1: point(55.9511, 146), control2: point(53.9426, 145.819))
    ring.addCurve(to: point(47.7229, 144.016), control1: point(50.4241, 145.108), control2: point(48.9389, 144.627))
    ring.addCurve(to: point(44.9419, 141.956), control1: point(46.5068, 143.414), control2: point(45.5799, 142.728))
    ring.addCurve(to: point(44, 139.567), control1: point(44.314, 141.195), control2: point(44, 140.398))
    ring.addCurve(to: point(44.6728, 137.387), control1: point(44, 138.775), control2: point(44.2243, 138.048))
    ring.addCurve(to: point(46.467, 135.598), control1: point(45.1214, 136.716), control2: point(45.7194, 136.119))
    ring.addCurve(to: point(48.9489, 134.276), control1: point(47.2145, 135.077), control2: point(48.0418, 134.636))
    ring.addCurve(to: point(51.7298, 133.434), control1: point(49.8659, 133.905), control2: point(50.7929, 133.624))
    ring.addCurve(to: point(54.3762, 133.133), control1: point(52.6768, 133.234), control2: point(53.5589, 133.133))
    ring.addLine(to: point(54.3762, 135.328))
    ring.addCurve(to: point(52.0289, 135.643), control1: point(53.6586, 135.338), control2: point(52.8761, 135.443))
    ring.addCurve(to: point(49.6217, 136.44), control1: point(51.1816, 135.834), control2: point(50.3792, 136.099))
    ring.addCurve(to: point(47.7528, 137.658), control1: point(48.8642, 136.781), control2: point(48.2412, 137.187))
    ring.addCurve(to: point(47.0351, 139.206), control1: point(47.2743, 138.129), control2: point(47.0351, 138.645))
    ring.addCurve(to: point(47.8574, 140.994), control1: point(47.0351, 139.857), control2: point(47.3092, 140.453))
    ring.addCurve(to: point(50.1899, 142.392), control1: point(48.4156, 141.536), control2: point(49.1931, 142.002))
    ring.addCurve(to: point(53.7333, 143.294), control1: point(51.1966, 142.783), control2: point(52.3777, 143.084))
    ring.addCurve(to: point(58.2038, 143.625), control1: point(55.0989, 143.515), control2: point(56.589, 143.625))
    ring.addCurve(to: point(62.6443, 143.294), control1: point(59.8086, 143.625), control2: point(61.2887, 143.515))
    ring.addCurve(to: point(66.1878, 142.377), control1: point(64.0099, 143.084), control2: point(65.191, 142.778))
    ring.addCurve(to: point(68.5352, 140.979), control1: point(67.1945, 141.987), control2: point(67.977, 141.521))
    ring.addCurve(to: point(69.3724, 139.206), control1: point(69.0933, 140.448), control2: point(69.3724, 139.857))
    ring.addCurve(to: point(68.6398, 137.658), control1: point(69.3724, 138.645), control2: point(69.1282, 138.129))
    ring.addCurve(to: point(66.7709, 136.44), control1: point(68.1514, 137.187), control2: point(67.5284, 136.781))
    ring.addCurve(to: point(64.3637, 135.643), control1: point(66.0134, 136.099), control2: point(65.211, 135.834))
    ring.addCurve(to: point(62.0164, 135.328), control1: point(63.5265, 135.443), control2: point(62.744, 135.338))
    ring.addLine(to: point(62.0164, 133.133))
    ring.addCurve(to: point(64.6628, 133.434), control1: point(62.8437, 133.133), control2: point(63.7258, 133.234))
    ring.addCurve(to: point(67.4437, 134.276), control1: point(65.6097, 133.624), control2: point(66.5367, 133.905))
    ring.addCurve(to: point(69.9406, 135.598), control1: point(68.3607, 134.636), control2: point(69.193, 135.077))
    ring.addCurve(to: point(71.7198, 137.387), control1: point(70.6881, 136.119), control2: point(71.2812, 136.716))
    ring.addCurve(to: point(72.3926, 139.567), control1: point(72.1683, 138.048), control2: point(72.3926, 138.775))
    ring.addCurve(to: point(71.4507, 141.956), control1: point(72.3926, 140.398), control2: point(72.0786, 141.195))
    ring.addCurve(to: point(68.6847, 144.016), control1: point(70.8227, 142.728), control2: point(69.9007, 143.414))
    ring.addCurve(to: point(64.2142, 145.459), control1: point(67.4686, 144.627), control2: point(65.9785, 145.108))
    ring.addCurve(to: point(58.2038, 146), control1: point(62.4599, 145.819), control2: point(60.4564, 146))
    ring.closeSubpath()

    context.fill(ring, with: .conicGradient(Self.ringGradient, center: point(58.2, 139.6), angle: .degrees(0)))

    var heartFill = Path()
    heartFill.move(to: point(63.5363, 115.341))
    heartFill.addCurve(to: point(66.2083, 115.921), control1: point(64.4961, 115.341), control2: point(65.3868, 115.534))
    heartFill.addCurve(to: point(68.3678, 117.571), control1: point(67.0379, 116.309), control2: point(67.7578, 116.859))
    heartFill.addCurve(to: point(69.8075, 120.105), control1: point(68.986, 118.284), control2: point(69.4659, 119.128))
    heartFill.addCurve(to: point(70.3321, 123.312), control1: point(70.1572, 121.073), control2: point(70.3321, 122.142))
    heartFill.addCurve(to: point(68.9534, 128.881), control1: point(70.3321, 125.186), control2: point(69.8725, 127.043))
    heartFill.addCurve(to: point(65.0614, 134.24), control1: point(68.0424, 130.711), control2: point(66.7451, 132.498))
    heartFill.addCurve(to: point(59.1075, 139.215), control1: point(63.3859, 135.973), control2: point(61.4012, 137.631))
    heartFill.addCurve(to: point(58.6561, 139.453), control1: point(58.9774, 139.303), control2: point(58.8269, 139.382))
    heartFill.addCurve(to: point(58.2168, 139.571), control1: point(58.4934, 139.532), control2: point(58.347, 139.571))
    heartFill.addCurve(to: point(57.7776, 139.453), control1: point(58.0948, 139.571), control2: point(57.9484, 139.532))
    heartFill.addCurve(to: point(57.3384, 139.215), control1: point(57.6149, 139.382), control2: point(57.4685, 139.303))
    heartFill.addCurve(to: point(51.3723, 134.24), control1: point(55.0447, 137.631), control2: point(53.0559, 135.973))
    heartFill.addCurve(to: point(47.468, 128.881), control1: point(49.6886, 132.498), control2: point(48.3872, 130.711))
    heartFill.addCurve(to: point(46.1016, 123.312), control1: point(46.5571, 127.043), control2: point(46.1016, 125.186))
    heartFill.addCurve(to: point(46.614, 120.105), control1: point(46.1016, 122.142), control2: point(46.2724, 121.073))
    heartFill.addCurve(to: point(48.0659, 117.571), control1: point(46.9637, 119.128), control2: point(47.4477, 118.284))
    heartFill.addCurve(to: point(50.2254, 115.921), control1: point(48.684, 116.859), control2: point(49.4039, 116.309))
    heartFill.addCurve(to: point(52.8973, 115.341), control1: point(51.0469, 115.534), control2: point(51.9376, 115.341))
    heartFill.addCurve(to: point(56.0451, 116.331), control1: point(54.093, 115.341), control2: point(55.1423, 115.671))
    heartFill.addCurve(to: point(58.2168, 118.944), control1: point(56.948, 116.991), control2: point(57.6719, 117.862))
    heartFill.addCurve(to: point(60.4008, 116.331), control1: point(58.7699, 117.853), control2: point(59.4979, 116.982))
    heartFill.addCurve(to: point(63.5363, 115.341), control1: point(61.3036, 115.671), control2: point(62.3488, 115.341))
    heartFill.closeSubpath()

    context.fill(
      heartFill,
      with: .linearGradient(
        Gradient(colors: [Color(hex: 0x7CCDFF), Color(hex: 0x009DFF)]),
        startPoint: point(54.7878, 122.447),
        endPoint: point(61.8603, 137.07)
      )
    )

    var heartOutline = Path()
    heartOutline.move(to: point(70.3322, 123.312))
    heartOutline.addCurve(to: point(69.8075, 120.105), control1: point(70.3322, 122.142), control2: point(70.1573, 121.073))
    heartOutline.addCurve(to: point(68.3678, 117.571), control1: point(69.4659, 119.129), control2: point(68.986, 118.284))
    heartOutline.addCurve(to: point(66.2083, 115.922), control1: point(67.7578, 116.859), control2: point(67.0379, 116.309))
    heartOutline.addCurve(to: point(63.5364, 115.341), control1: point(65.3868, 115.534), control2: point(64.4962, 115.341))
    heartOutline.addCurve(to: point(60.4008, 116.331), control1: point(62.3488, 115.341), control2: point(61.3036, 115.671))
    heartOutline.addCurve(to: point(58.2169, 118.944), control1: point(59.4979, 116.982), control2: point(58.77, 117.853))
    heartOutline.addCurve(to: point(56.0452, 116.331), control1: point(57.6719, 117.862), control2: point(56.948, 116.991))
    heartOutline.addCurve(to: point(52.8974, 115.341), control1: point(55.1423, 115.671), control2: point(54.093, 115.341))
    heartOutline.addCurve(to: point(50.2254, 115.922), control1: point(51.9376, 115.341), control2: point(51.0469, 115.534))
    heartOutline.addCurve(to: point(48.0659, 117.571), control1: point(49.4039, 116.309), control2: point(48.6841, 116.859))
    heartOutline.addCurve(to: point(46.614, 120.105), control1: point(47.4477, 118.284), control2: point(46.9638, 119.129))
    heartOutline.addCurve(to: point(46.1016, 123.312), control1: point(46.2724, 121.073), control2: point(46.1016, 122.142))
    heartOutline.addCurve(to: point(47.4681, 128.881), control1: point(46.1016, 125.186), control2: point(46.5571, 127.043))
    heartOutline.addCurve(to: point(51.3723, 134.24), control1: point(48.3872, 130.711), control2: point(49.6886, 132.498))
    heartOutline.addCurve(to: point(57.3384, 139.215), control1: point(53.056, 135.973), control2: point(55.0447, 137.631))
    heartOutline.addCurve(to: point(57.7776, 139.453), control1: point(57.4685, 139.303), control2: point(57.615, 139.382))
    heartOutline.addCurve(to: point(58.2169, 139.571), control1: point(57.9485, 139.532), control2: point(58.0949, 139.571))
    heartOutline.addCurve(to: point(58.6561, 139.453), control1: point(58.347, 139.571), control2: point(58.4934, 139.532))
    heartOutline.addCurve(to: point(59.1075, 139.215), control1: point(58.8269, 139.382), control2: point(58.9774, 139.303))
    heartOutline.addCurve(to: point(65.0614, 134.24), control1: point(61.4012, 137.631), control2: point(63.3859, 135.973))
    heartOutline.addCurve(to: point(68.9535, 128.881), control1: point(66.7451, 132.498), control2: point(68.0425, 130.711))
    heartOutline.addCurve(to: point(70.3322, 123.312), control1: point(69.8726, 127.043), control2: point(70.3322, 125.186))
    heartOutline.closeSubpath()
    heartOutline.move(to: point(70.673, 123.312))
    heartOutline.addCurve(to: point(69.2584, 129.034), control1: point(70.673, 125.244), control2: point(70.1988, 127.152))
    heartOutline.addLine(to: point(69.2583, 129.034))
    heartOutline.addCurve(to: point(65.3065, 134.476), control1: point(68.3292, 130.9), control2: point(67.01, 132.714))
    heartOutline.addLine(to: point(65.3065, 134.477))
    heartOutline.addCurve(to: point(59.3012, 139.496), control1: point(63.6131, 136.228), control2: point(61.6106, 137.901))
    heartOutline.addLine(to: point(59.2998, 139.496))
    heartOutline.addLine(to: point(59.2984, 139.497))
    heartOutline.addCurve(to: point(58.7947, 139.764), control1: point(59.1485, 139.599), control2: point(58.9798, 139.687))
    heartOutline.addCurve(to: point(58.2169, 139.912), control1: point(58.6059, 139.855), control2: point(58.4112, 139.912))
    heartOutline.addCurve(to: point(57.6392, 139.764), control1: point(58.0274, 139.912), control2: point(57.8314, 139.853))
    heartOutline.addCurve(to: point(57.1758, 139.516), control1: point(57.472, 139.692), control2: point(57.3171, 139.609))
    heartOutline.addLine(to: point(57.1461, 139.496))
    heartOutline.addLine(to: point(57.1448, 139.496))
    heartOutline.addCurve(to: point(51.1278, 134.477), control1: point(54.8354, 137.901), control2: point(52.8291, 136.229))
    heartOutline.addLine(to: point(51.1275, 134.477))
    heartOutline.addLine(to: point(51.1272, 134.476))
    heartOutline.addCurve(to: point(47.1635, 129.034), control1: point(49.4238, 132.714), control2: point(48.1006, 130.9))
    heartOutline.addLine(to: point(47.1631, 129.034))
    heartOutline.addLine(to: point(47.1626, 129.033))
    heartOutline.addCurve(to: point(45.7607, 123.312), control1: point(46.2306, 127.151), control2: point(45.7607, 125.243))
    heartOutline.addCurve(to: point(46.2926, 119.992), control1: point(45.7607, 122.109), control2: point(45.9365, 121.001))
    heartOutline.addLine(to: point(46.2929, 119.991))
    heartOutline.addLine(to: point(46.2932, 119.99))
    heartOutline.addCurve(to: point(47.8084, 117.348), control1: point(46.6557, 118.978), control2: point(47.16, 118.095))
    heartOutline.addCurve(to: point(50.0801, 115.613), control1: point(48.4564, 116.601), control2: point(49.214, 116.021))
    heartOutline.addCurve(to: point(52.8974, 115), control1: point(50.9496, 115.203), control2: point(51.8903, 115))
    heartOutline.addCurve(to: point(56.2463, 116.055), control1: point(54.16, 115), control2: point(55.2809, 115.35))
    heartOutline.addCurve(to: point(58.2176, 118.238), control1: point(57.0359, 116.633), control2: point(57.6927, 117.362))
    heartOutline.addCurve(to: point(60.157, 116.087), control1: point(58.7387, 117.372), control2: point(59.3847, 116.653))
    heartOutline.addLine(to: point(60.2014, 116.054))
    heartOutline.addCurve(to: point(63.5364, 115), control1: point(61.166, 115.35), control2: point(62.2821, 115))
    heartOutline.addCurve(to: point(66.3536, 115.613), control1: point(64.5435, 115), control2: point(65.4841, 115.203))
    heartOutline.addLine(to: point(66.3536, 115.613))
    heartOutline.addCurve(to: point(68.6253, 117.348), control1: point(67.2272, 116.021), control2: point(67.985, 116.6))
    heartOutline.addCurve(to: point(70.1292, 119.993), control1: point(69.2743, 118.096), control2: point(69.7748, 118.979))
    heartOutline.addLine(to: point(70.1292, 119.993))
    heartOutline.addCurve(to: point(70.673, 123.312), control1: point(70.4933, 121.001), control2: point(70.673, 122.109))
    heartOutline.closeSubpath()

    context.fill(heartOutline, with: .color(Color(hex: 0x11A4FF)), style: FillStyle(eoFill: true))
  }

  /// The ring's conic-gradient stops, transcribed from the design's exact CSS
  /// `conic-gradient` (blue → purple → red-orange → yellow → green → cyan → blue).
  /// Identical in both `Splash.svg` and `home.svg`.
  private static let ringGradient = Gradient(stops: [
    .init(color: Color(hex: 0x009DFF), location: 0.0),
    .init(color: Color(hex: 0x9D51A6), location: 0.174),
    .init(color: Color(hex: 0xF34213), location: 0.389),
    .init(color: Color(hex: 0xFFF001), location: 0.586),
    .init(color: Color(hex: 0xB1D075), location: 0.765),
    .init(color: Color(hex: 0x00B0E9), location: 0.883),
    .init(color: Color(hex: 0x009DFF), location: 1.0),
  ])
}
