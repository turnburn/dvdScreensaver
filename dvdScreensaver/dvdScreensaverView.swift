
import ScreenSaver

// Found here : http://homecoffeecode.com/nsimage-tinted-as-easily-as-a-uiimage/
extension NSImage {
    func tinting(with tintColor: NSColor) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
        
        return NSImage(size: size, flipped: false) { bounds in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            tintColor.set()
            context.clip(to: bounds, mask: cgImage)
            context.fill(bounds)
            return true
        }
    }
}

class dvdScreensaverView: ScreenSaverView {
    
    private var dvdPosition: CGPoint = .zero
    private var dvdVelocity: CGVector = .zero
    private let dvdHeight: CGFloat = 138
    private let dvdWidth: CGFloat = 225
    var tintColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var image: NSImage?
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        dvdPosition = CGPoint(x: frame.width / 2, y: frame.height / 2)
        dvdVelocity = initialVelocity()
        loadImage();
    }
    
    private func initialVelocity() -> CGVector {
        let desiredVelocityMagnitude: CGFloat = 10
        let xVelocity = CGFloat.random(in: 2.5...7.5)
        let xSign: CGFloat = Bool.random() ? 1 : -1
        let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
        let ySign: CGFloat = Bool.random() ? 1 : -1
        return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    }
    

    private func dvdIsOOB() -> (xAxis: Bool, yAxis: Bool) {
        let xAxisOOB = dvdPosition.x <= 0 ||
            dvdPosition.x + (dvdWidth / 2) >= bounds.width
        let yAxisOOB = dvdPosition.y <= 0 ||
            dvdPosition.y + (dvdHeight / 2) >= bounds.height
        return (xAxisOOB, yAxisOOB)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        drawBackground(.black)
        drawDVD()
    }
    
    func loadImage() {
        DispatchQueue.global().async() {
            let url = NSURL(string: "https://raw.githubusercontent.com/turnburn/dvdScreensaver/master/dvdScreensaver/dvd.png")
            let data = NSData(contentsOf: url! as URL)
            if let data = data {
                self.image = NSImage(data: data as Data)
                self.needsDisplay = true
            }
        }
    }
    
    private func drawDVD() {
        let point = CGPoint(x: dvdPosition.x, y: dvdPosition.y)
        image = image?.tinting(with: tintColor)
        image?.draw(at: point, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1)
    }
    
    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        let oobAxes = dvdIsOOB()
        if oobAxes.xAxis {
            dvdVelocity.dx *= -1
            tintColor = NSColor(red: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), green: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), alpha: 1.0)
        }
        if oobAxes.yAxis {
            dvdVelocity.dy *= -1
            tintColor = NSColor(red: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), green: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), alpha: 1.0)
        }
        
        dvdPosition.x += dvdVelocity.dx
        dvdPosition.y += dvdVelocity.dy
        
        setNeedsDisplay(bounds)
    }

}
