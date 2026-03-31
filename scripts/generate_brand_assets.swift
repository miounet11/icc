import AppKit
import CoreGraphics
import Foundation

struct Palette {
    let shellTop: NSColor
    let shellBottom: NSColor
    let shellBorder: NSColor
    let shellGlow: NSColor
    let cardTop: NSColor
    let cardBottom: NSColor
    let cardBorder: NSColor
    let chevronFrontStart: NSColor
    let chevronFrontEnd: NSColor
    let chevronRear: NSColor
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
                shellTop: NSColor(calibratedRed: 0.96, green: 0.97, blue: 0.98, alpha: 1),
                shellBottom: NSColor(calibratedRed: 0.84, green: 0.87, blue: 0.91, alpha: 1),
                shellBorder: NSColor(calibratedRed: 0.75, green: 0.80, blue: 0.87, alpha: 0.95),
                shellGlow: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.74),
                cardTop: NSColor(calibratedRed: 0.99, green: 0.99, blue: 0.99, alpha: 1),
                cardBottom: NSColor(calibratedRed: 0.90, green: 0.91, blue: 0.93, alpha: 1),
                cardBorder: NSColor(calibratedRed: 0.77, green: 0.79, blue: 0.84, alpha: 0.90),
                chevronFrontStart: NSColor(calibratedRed: 0.47, green: 0.87, blue: 1.0, alpha: 1),
                chevronFrontEnd: NSColor(calibratedRed: 0.21, green: 0.50, blue: 0.99, alpha: 1),
                chevronRear: NSColor(calibratedRed: 0.77, green: 0.92, blue: 1.0, alpha: 0.95),
                badgeTop: NSColor(calibratedRed: 0.12, green: 0.48, blue: 0.97, alpha: 1),
                badgeBottom: NSColor(calibratedRed: 0.05, green: 0.33, blue: 0.79, alpha: 1)
            )
        case .dark:
            return Palette(
                shellTop: NSColor(calibratedRed: 0.16, green: 0.18, blue: 0.22, alpha: 1),
                shellBottom: NSColor(calibratedRed: 0.08, green: 0.09, blue: 0.12, alpha: 1),
                shellBorder: NSColor(calibratedRed: 0.30, green: 0.34, blue: 0.42, alpha: 0.96),
                shellGlow: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.10),
                cardTop: NSColor(calibratedRed: 0.95, green: 0.96, blue: 0.98, alpha: 1),
                cardBottom: NSColor(calibratedRed: 0.84, green: 0.87, blue: 0.91, alpha: 1),
                cardBorder: NSColor(calibratedRed: 0.72, green: 0.76, blue: 0.84, alpha: 0.92),
                chevronFrontStart: NSColor(calibratedRed: 0.55, green: 0.90, blue: 1.0, alpha: 1),
                chevronFrontEnd: NSColor(calibratedRed: 0.25, green: 0.59, blue: 1.0, alpha: 1),
                chevronRear: NSColor(calibratedRed: 0.79, green: 0.94, blue: 1.0, alpha: 0.90),
                badgeTop: NSColor(calibratedRed: 0.23, green: 0.67, blue: 1.0, alpha: 1),
                badgeBottom: NSColor(calibratedRed: 0.09, green: 0.43, blue: 0.95, alpha: 1)
            )
        }
    }
}

struct IconAsset {
    let filename: String
    let pixels: CGFloat
}

let iconAssets: [IconAsset] = [
    .init(filename: "16.png", pixels: 16),
    .init(filename: "16@2x.png", pixels: 32),
    .init(filename: "32.png", pixels: 32),
    .init(filename: "32@2x.png", pixels: 64),
    .init(filename: "128.png", pixels: 128),
    .init(filename: "128@2x.png", pixels: 256),
    .init(filename: "256.png", pixels: 256),
    .init(filename: "256@2x.png", pixels: 512),
    .init(filename: "512.png", pixels: 512),
    .init(filename: "512@2x.png", pixels: 1024),
]

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func image(size: CGSize, draw: () -> Void) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    if let context = NSGraphicsContext.current {
        context.imageInterpolation = .high
    }
    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()
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

func chevronPath(in rect: CGRect, thickness: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    let p1 = CGPoint(x: rect.minX, y: rect.minY + thickness)
    let p2 = CGPoint(x: rect.minX + thickness, y: rect.minY)
    let p3 = CGPoint(x: rect.maxX, y: rect.midY)
    let p4 = CGPoint(x: rect.minX + thickness, y: rect.maxY)
    let p5 = CGPoint(x: rect.minX, y: rect.maxY - thickness)
    let p6 = CGPoint(x: rect.maxX - thickness * 1.55, y: rect.midY)
    path.move(to: p1)
    path.line(to: p2)
    path.line(to: p3)
    path.line(to: p4)
    path.line(to: p5)
    path.line(to: p6)
    path.close()
    return path
}

func drawBackground(in bounds: CGRect, palette: Palette) {
    let outerRect = bounds.insetBy(dx: bounds.width * 0.055, dy: bounds.height * 0.055)
    let outerPath = roundedRect(outerRect, radius: bounds.width * 0.18)

    let shellShadow = NSShadow()
    shellShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shellShadow.shadowBlurRadius = bounds.width * 0.06
    shellShadow.shadowOffset = NSSize(width: 0, height: -bounds.height * 0.018)
    shellShadow.set()

    let shellGradient = NSGradient(colors: [palette.shellTop, palette.shellBottom])!
    shellGradient.draw(in: outerPath, angle: -90)

    NSGraphicsContext.saveGraphicsState()
    outerPath.addClip()
    let glowRect = CGRect(
        x: outerRect.minX + outerRect.width * 0.06,
        y: outerRect.midY,
        width: outerRect.width * 0.88,
        height: outerRect.height * 0.34
    )
    let glowPath = roundedRect(glowRect, radius: bounds.width * 0.13)
    let glowGradient = NSGradient(colors: [
        palette.shellGlow.withAlphaComponent(0.22),
        palette.shellGlow.withAlphaComponent(0.03),
    ])!
    glowGradient.draw(in: glowPath, angle: 90)
    NSGraphicsContext.restoreGraphicsState()

    palette.shellBorder.setStroke()
    outerPath.lineWidth = bounds.width * 0.010
    outerPath.stroke()

    let cardRect = outerRect.insetBy(dx: outerRect.width * 0.135, dy: outerRect.height * 0.135)
    let cardPath = roundedRect(cardRect, radius: bounds.width * 0.12)
    let cardGradient = NSGradient(colors: [palette.cardTop, palette.cardBottom])!
    cardGradient.draw(in: cardPath, angle: -90)
    palette.cardBorder.setStroke()
    cardPath.lineWidth = bounds.width * 0.008
    cardPath.stroke()
}

func drawChevronMark(in bounds: CGRect, palette: Palette, transparent: Bool) {
    let rect = bounds.insetBy(dx: bounds.width * 0.20, dy: bounds.height * 0.20)
    let frontRect = CGRect(
        x: rect.minX + rect.width * 0.14,
        y: rect.minY + rect.height * 0.08,
        width: rect.width * 0.60,
        height: rect.height * 0.84
    )
    let rearRect = CGRect(
        x: rect.minX - rect.width * 0.01,
        y: rect.minY + rect.height * 0.16,
        width: rect.width * 0.46,
        height: rect.height * 0.68
    )

    if !transparent {
        let markShadow = NSShadow()
        markShadow.shadowColor = NSColor.black.withAlphaComponent(0.12)
        markShadow.shadowBlurRadius = bounds.width * 0.04
        markShadow.shadowOffset = NSSize(width: 0, height: -bounds.height * 0.01)
        markShadow.set()
    }

    let rearPath = chevronPath(in: rearRect, thickness: rearRect.width * 0.30)
    palette.chevronRear.setFill()
    rearPath.fill()

    let frontPath = chevronPath(in: frontRect, thickness: frontRect.width * 0.27)
    NSGraphicsContext.saveGraphicsState()
    frontPath.addClip()
    let frontGradient = NSGradient(colors: [palette.chevronFrontStart, palette.chevronFrontEnd])!
    frontGradient.draw(in: frontRect, angle: -90)
    NSGraphicsContext.restoreGraphicsState()
}

func drawBadge(text: String, in bounds: CGRect, palette: Palette) {
    let badgeRect = CGRect(
        x: bounds.minX + bounds.width * 0.10,
        y: bounds.minY + bounds.height * 0.08,
        width: bounds.width * 0.80,
        height: bounds.height * 0.18
    )
    let badgePath = roundedRect(badgeRect, radius: bounds.width * 0.08)
    let badgeGradient = NSGradient(colors: [palette.badgeTop, palette.badgeBottom])!
    badgeGradient.draw(in: badgePath, angle: -90)

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: bounds.width * 0.095, weight: .bold),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
        .kern: bounds.width * 0.008,
    ]
    let label = NSAttributedString(string: text, attributes: attributes)
    let labelRect = CGRect(
        x: badgeRect.minX,
        y: badgeRect.minY + badgeRect.height * 0.14,
        width: badgeRect.width,
        height: badgeRect.height * 0.72
    )
    label.draw(in: labelRect)
}

func renderIcon(theme: Theme, size: CGFloat, badgeText: String? = nil) -> NSImage {
    image(size: CGSize(width: size, height: size)) {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        drawBackground(in: bounds, palette: theme.palette)
        let markBounds: CGRect
        if badgeText == nil {
            markBounds = bounds
        } else {
            markBounds = CGRect(
                x: bounds.minX,
                y: bounds.minY + bounds.height * 0.08,
                width: bounds.width,
                height: bounds.height * 0.82
            )
        }
        drawChevronMark(in: markBounds, palette: theme.palette, transparent: false)
        if let badgeText {
            drawBadge(text: badgeText, in: bounds, palette: theme.palette)
        }
    }
}

func renderTransparentMark(size: CGFloat) -> NSImage {
    image(size: CGSize(width: size, height: size)) {
        let bounds = CGRect(x: 0, y: 0, width: size, height: size)
        drawChevronMark(in: bounds, palette: Theme.light.palette, transparent: true)
    }
}

func writeIconSet(at directory: String, theme: Theme, darkTheme: Theme? = nil, badgeText: String? = nil) throws {
    for asset in iconAssets {
        let image = renderIcon(theme: theme, size: asset.pixels, badgeText: badgeText)
        try writeImage(image, to: "\(directory)/\(asset.filename)")
        if let darkTheme {
            let darkName = asset.filename.replacingOccurrences(of: ".png", with: "_dark.png")
            let darkImage = renderIcon(theme: darkTheme, size: asset.pixels, badgeText: badgeText)
            try writeImage(darkImage, to: "\(directory)/\(darkName)")
        }
    }
}

let lightIcon1024 = renderIcon(theme: .light, size: 1024)
let darkIcon1024 = renderIcon(theme: .dark, size: 1024)
let transparentMark = renderTransparentMark(size: 1024)
let webLogo = renderIcon(theme: .light, size: 256)
let webNightly = renderIcon(theme: .dark, size: 256, badgeText: "NIGHTLY")
let webApple = renderIcon(theme: .light, size: 256)
let webSmall = renderIcon(theme: .light, size: 32)

try writeImage(lightIcon1024, to: "Assets.xcassets/AppIconLight.imageset/AppIconLight.png")
try writeImage(darkIcon1024, to: "Assets.xcassets/AppIconDark.imageset/AppIconDark.png")
try writeIconSet(at: "Assets.xcassets/AppIcon.appiconset", theme: .light, darkTheme: .dark)
try writeIconSet(at: "Assets.xcassets/AppIcon-Debug.appiconset", theme: .light, badgeText: "DEV")
try writeIconSet(at: "Assets.xcassets/AppIcon-Nightly.appiconset", theme: .dark, badgeText: "NIGHTLY")
try writeImage(transparentMark, to: "AppIcon.icon/Assets/cmux-icon-chevron 2.png")
try writeImage(transparentMark, to: "design/cmux.icon/Assets/cmux-icon-chevron 2.png")
try writeImage(webLogo, to: "web/public/logo.png")
try writeImage(webNightly, to: "web/public/logo-nightly.png")
try writeImage(webApple, to: "web/app/apple-icon.png")
try writeImage(webSmall, to: "web/app/icon.png")
try writeImage(webSmall, to: "web/app/favicon.ico")
