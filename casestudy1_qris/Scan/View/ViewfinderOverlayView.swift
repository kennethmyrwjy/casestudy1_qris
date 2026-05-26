import UIKit
import OSLog

private let viewfinderLog = Logger(subsystem: "com.example.casestudy1-qris", category: "Viewfinder")

final class ViewfinderOverlayView: UIView {

    private let scanLine = CAGradientLayer()
    private let scanLineKey = "scanline-sweep"
    private var shouldSweep = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
        configureScanLine()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var reticleRect: CGRect {
        let side = min(bounds.width, bounds.height) * 0.7
        return CGRect(
            x: (bounds.width - side) / 2,
            y: (bounds.height - side) / 2 - 24,
            width: side,
            height: side
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutScanLine()
        if shouldSweep { attachSweepAnimation() }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        viewfinderLog.info("didMoveToWindow window=\(self.window != nil)")
        if window != nil {
            // Re-attach on every (re-)entry into a window. Covers both initial
            // appearance and returning from a pushed view controller — UIKit can
            // strip running CAAnimations during the transition.
            shouldSweep = true
            attachSweepAnimation()
        } else {
            shouldSweep = false
            scanLine.removeAnimation(forKey: scanLineKey)
        }
    }

    private func configureScanLine() {
        // Vertical gradient: teal opaque in the middle, fading to clear at the
        // top/bottom so the bar reads as a soft beam rather than a hard line.
        scanLine.colors = [
            UIColor.clear.cgColor,
            DesignSystem.Color.primary.withAlphaComponent(0.9).cgColor,
            UIColor.clear.cgColor
        ]
        scanLine.locations = [0.0, 0.5, 1.0]
        scanLine.startPoint = CGPoint(x: 0.5, y: 0)
        scanLine.endPoint = CGPoint(x: 0.5, y: 1)
        scanLine.isHidden = true
        layer.addSublayer(scanLine)
    }

    private func layoutScanLine() {
        let reticle = reticleRect
        let height: CGFloat = 28
        scanLine.frame = CGRect(
            x: reticle.minX + 8,
            y: reticle.minY,
            width: reticle.width - 16,
            height: height
        )
    }

    @objc private func applicationDidBecomeActive() {
        if shouldSweep { attachSweepAnimation() }
    }

    @objc private func applicationWillResignActive() {
        scanLine.removeAnimation(forKey: scanLineKey)
    }

    private func attachSweepAnimation() {
        guard window != nil, bounds.width > 0 else {
            viewfinderLog.info("attachSweepAnimation skipped — no window or zero bounds")
            return
        }
        guard !UIAccessibility.isReduceMotionEnabled else {
            scanLine.isHidden = true
            return
        }

        scanLine.isHidden = false
        scanLine.removeAnimation(forKey: scanLineKey)

        let reticle = reticleRect
        let startY = reticle.minY + scanLine.bounds.height / 2
        let endY = reticle.maxY - scanLine.bounds.height / 2

        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = startY
        animation.toValue = endY
        animation.duration = 1.8
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        scanLine.add(animation, forKey: scanLineKey)
        viewfinderLog.info("attachSweepAnimation: attached, reticle=\(NSCoder.string(for: reticle), privacy: .public)")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let reticle = reticleRect

        ctx.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        ctx.fill(bounds)

        let cutout = UIBezierPath(roundedRect: reticle, cornerRadius: 16)
        ctx.setBlendMode(.clear)
        cutout.fill()
        ctx.setBlendMode(.normal)

        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(4)
        ctx.setLineCap(.round)
        let cornerLength: CGFloat = 22
        let r = reticle.insetBy(dx: 2, dy: 2)
        let corners: [(CGPoint, CGPoint, CGPoint)] = [
            (CGPoint(x: r.minX, y: r.minY + cornerLength), CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.minX + cornerLength, y: r.minY)),
            (CGPoint(x: r.maxX - cornerLength, y: r.minY), CGPoint(x: r.maxX, y: r.minY), CGPoint(x: r.maxX, y: r.minY + cornerLength)),
            (CGPoint(x: r.maxX, y: r.maxY - cornerLength), CGPoint(x: r.maxX, y: r.maxY), CGPoint(x: r.maxX - cornerLength, y: r.maxY)),
            (CGPoint(x: r.minX + cornerLength, y: r.maxY), CGPoint(x: r.minX, y: r.maxY), CGPoint(x: r.minX, y: r.maxY - cornerLength))
        ]
        for (a, b, c) in corners {
            ctx.beginPath()
            ctx.move(to: a)
            ctx.addLine(to: b)
            ctx.addLine(to: c)
            ctx.strokePath()
        }
    }
}

final class QRISBadgeView: UIView {

    private let logoView = UIImageView()
    private let supportedLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
//        backgroundColor = .black
        layer.cornerRadius = 14
        clipsToBounds = true
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    private func setup() {
        logoView.image = UIImage(named: "qris-logo-white")
        logoView.contentMode = .scaleAspectFit
        
        supportedLabel.attributedText = NSAttributedString(
            string: "SUPPORTED",
            attributes: [
                .kern: 0.7,
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
        )
        // need to explain this further
        
        let stack = UIStackView(arrangedSubviews: [logoView, supportedLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 1
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        isAccessibilityElement = true
        accessibilityLabel = "QRIS didukung"
    }
}
