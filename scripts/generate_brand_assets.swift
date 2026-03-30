import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Palette {
    let backgroundTop: NSColor
    let backgroundBottom: NSColor
    let outline: NSColor
    let highlight: NSColor
    let stem: NSColor
    let dot: NSColor
    let outerC: NSColor
    let innerC: NSColor
    let badgeTop: NSColor
    let badgeBottom: NSColor
}

enum Theme {
    case light
    case dark

    var palette: Palette {
        switch self {
        case .light:
            return Palette(
                backgroundTop: NSColor(calibratedRed: 0.98, green: 0.97, blue: 0.94, alpha: 1),
                backgroundBottom: NSColor(calibratedRed: 0.93, green: 0.91, blue: 0.87, alpha: 1),
                outline: NSColor(calibratedRed: 0.79, green: 0.75, blue: 0.69, alpha: 0.85),
                highlight: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.85),
                stem: NSColor(calibratedRed: 0.07, green: 0.43, blue: 0.43, alpha: 1),
                dot: NSColor(calibratedRed: 0.92, green: 0.64, blue: 0.20, alpha: 1),
                outerC: NSColor(calibratedRed: 0.10, green: 0.57, blue: 0.56, alpha: 1),
                innerC: NSColor(calibratedRed: 0.78, green: 0.36, blue: 0.23, alpha: 1),
                badgeTop: NSColor(calibratedRed: 0.93, green: 0.51, blue: 0.18, alpha: 1),
                badgeBottom: NSColor(calibratedRed: 0.76, green: 0.27, blue: 0.13, alpha: 1)
            )
        case .dark:
            return Palette(
                backgroundTop: NSColor(calibratedRed: 0.13, green: 0.15, blue: 0.19, alpha: 1),
                backgroundBottom: NSColor(calibratedRed: 0.07, green: 0.08, blue: 0.11, alpha: 1),
                outline: NSColor(calibratedRed: 0.35, green: 0.38, blue: 0.43, alpha: 0.95),
                highlight: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.16),
                stem: NSColor(calibratedRed: 0.43, green: 0.87, blue: 0.82, alpha: 1),
                dot: NSColor(calibratedRed: 0.98, green: 0.73, blue: 0.30, alpha: 1),
                outerC: NSColor(calibratedRed: 0.39, green: 0.82, blue: 0.78, alpha: 1),
                innerC: NSColor(calibratedRed: 0.97, green: 0.54, blue: 0.35, alpha: 1),
                badgeTop: NSColor(calibratedRed: 0.98, green: 0.57, blue: 0.25, alpha: 1),
                badgeBottom: NSColor(calibratedRed: 0.84, green: 0.31, blue: 0.17, alpha: 1)
            )
        }
    }
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func makeRoundedRect(in rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func strokePath(center: CGPoint, radius: CGFloat, lineWidth: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    path.lineWidth = lineWidth
    path.lineCapStyle = .round
    path.appendArc(withCenter: center, radius: radius, startAngle: 46, endAngle: 314, clockwise: false)
    return path
}

func drawSymbol(in bounds: CGRect, palette: Palette, transparent: Bool) {
    let symbolRect = bounds.insetBy(dx: bounds.width * 0.15, dy: bounds.height * 0.15)
    let height = symbolRect.height
    let stemRect = CGRect(
        x: symbolRect.minX + height * 0.03,
        y: symbolRect.minY + height * 0.16,
        width: height * 0.13,
        height: height * 0.44
    )
    let dotRect = CGRect(
        x: stemRect.minX - height * 0.015,
        y: stemRect.maxY + height * 0.08,
        width: height * 0.16,
        height: height * 0.16
    )

    if !transparent {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.10)
        shadow.shadowBlurRadius = height * 0.028
        shadow.shadowOffset = NSSize(width: 0, height: -height * 0.012)
        shadow.set()
    }

    palette.stem.setFill()
    makeRoundedRect(in: stemRect, radius: stemRect.width / 2).fill()

    palette.dot.setFill()
    NSBezierPath(ovalIn: dotRect).fill()

    let outerArc = strokePath(
        center: CGPoint(x: symbolRect.midX + height * 0.04, y: symbolRect.midY - height * 0.01),
        radius: height * 0.245,
        lineWidth: height * 0.105
    )
    palette.outerC.setStroke()
    outerArc.stroke()

    let innerArc = strokePath(
        center: CGPoint(x: symbolRect.midX + height * 0.215, y: symbolRect.midY - height * 0.01),
        radius: height * 0.205,
        lineWidth: height * 0.095
    )
    palette.innerC.setStroke()
    innerArc.stroke()
}

func drawBackground(in bounds: CGRect, palette: Palette) {
    let baseRect = bounds.insetBy(dx: bounds.width * 0.055, dy: bounds.height * 0.055)
    let basePath = makeRoundedRect(in: baseRect, radius: bounds.width * 0.17)
    let gradient = NSGradient(colors: [palette.backgroundTop, palette.backgroundBottom])!
    gradient.draw(in: basePath, angle: -90)

    let sheenRect = CGRect(
        x: baseRect.minX + baseRect.width * 0.06,
        y: baseRect.midY,
        width: baseRect.width * 0.88,
        height: baseRect.height * 0.34
    )
    let sheenPath = makeRoundedRect(in: sheenRect, radius: bounds.width * 0.14)
    NSGraphicsContext.saveGraphicsState()
    basePath.addClip()
    let sheen = NSGradient(colors: [
        palette.highlight.withAlphaComponent(0.18),
        palette.highlight.withAlphaComponent(0.02),
    ])!
    sheen.draw(in: sheenPath, angle: 90)
    NSGraphicsContext.restoreGraphicsState()

    palette.outline.setStroke()
    basePath.lineWidth = bounds.width * 0.010
    basePath.stroke()
}

func drawNightlyBadge(in bounds: CGRect, palette: Palette) {
    let badgeRect = CGRect(
        x: bounds.minX + bounds.width * 0.07,
        y: bounds.minY + bounds.height * 0.07,
        width: bounds.width * 0.86,
        height: bounds.height * 0.22
    )
    let path = makeRoundedRect(in: badgeRect, radius: bounds.width * 0.08)
    let gradient = NSGradient(colors: [palette.badgeTop, palette.badgeBottom])!
    gradient.draw(in: path, angle: -90)

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: bounds.width * 0.105, weight: .bold),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
        .kern: bounds.width * 0.006,
    ]
    let title = NSAttributedString(string: "NIGHTLY", attributes: attributes)
    let titleRect = CGRect(
        x: badgeRect.minX,
        y: badgeRect.minY + badgeRect.height * 0.18,
        width: badgeRect.width,
        height: badgeRect.height * 0.64
    )
    title.draw(in: titleRect)
}

func image(size: CGSize, opaque: Bool, draw: () -> Void) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    if let context = NSGraphicsContext.current {
        context.imageInterpolation = .high
    }
    if opaque {
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
    }
    draw()
    image.unlockFocus()
    return image
}

func pngData(for image: NSImage) -> Data? {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
    return bitmap.representation(using: .png, properties: [:])
}

func writeImage(_ image: NSImage, to path: String) throws {
    let url = root.appendingPathComponent(path)
    guard let data = pngData(for: image) else {
        throw NSError(domain: "generate_brand_assets", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode \(path)"])
    }
    try data.write(to: url)
    print("wrote \(path)")
}

func buildIcon(theme: Theme, size: CGFloat) -> NSImage {
    image(size: CGSize(width: size, height: size), opaque: false) {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        drawBackground(in: bounds, palette: theme.palette)
        drawSymbol(in: bounds, palette: theme.palette, transparent: false)
    }
}

func buildTransparentMark(size: CGFloat) -> NSImage {
    image(size: CGSize(width: size, height: size), opaque: false) {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        let palette = Theme.light.palette
        drawSymbol(in: bounds, palette: palette, transparent: true)
    }
}

func buildNightlyLogo(size: CGFloat) -> NSImage {
    image(size: CGSize(width: size, height: size), opaque: false) {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        let palette = Theme.dark.palette
        drawBackground(in: bounds, palette: palette)
        let iconBounds = CGRect(
            x: bounds.minX,
            y: bounds.minY + size * 0.08,
            width: bounds.width,
            height: bounds.height * 0.82
        )
        drawSymbol(in: iconBounds, palette: palette, transparent: false)
        drawNightlyBadge(in: bounds, palette: palette)
    }
}

let light = buildIcon(theme: .light, size: 1024)
let dark = buildIcon(theme: .dark, size: 1024)
let mark = buildTransparentMark(size: 1024)
let webLogo = buildIcon(theme: .light, size: 256)
let webNightly = buildNightlyLogo(size: 256)
let webApple = buildIcon(theme: .light, size: 256)
let webSmall = buildIcon(theme: .light, size: 32)

try writeImage(light, to: "Assets.xcassets/AppIconLight.imageset/AppIconLight.png")
try writeImage(dark, to: "Assets.xcassets/AppIconDark.imageset/AppIconDark.png")
try writeImage(mark, to: "AppIcon.icon/Assets/cmux-icon-chevron 2.png")
try writeImage(mark, to: "design/cmux.icon/Assets/cmux-icon-chevron 2.png")
try writeImage(webLogo, to: "web/public/logo.png")
try writeImage(webNightly, to: "web/public/logo-nightly.png")
try writeImage(webApple, to: "web/app/apple-icon.png")
try writeImage(webSmall, to: "web/app/icon.png")
