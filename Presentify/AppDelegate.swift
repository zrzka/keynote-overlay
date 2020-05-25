//
// Copyright © 2020 Robert Vojta. All rights reserved.
//

import Cocoa
import HotKey

final class OverlayView: NSView {
    private var path: NSBezierPath?

    override func keyDown(with event: NSEvent) {
        print("keyDown - \(event.keyCode)")
    }

    override func keyUp(with event: NSEvent) {
        print("keyUp - \(event.keyCode)")
    }

    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)

        path = NSBezierPath()
        path?.move(to: point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        path = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        path?.line(to: point)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }

        defer {
            ctx.restoreGState()
        }
        ctx.saveGState()

        NSColor.green.set()
        ctx.stroke(bounds, width: 8.0)

        guard let path = path else {
            return
        }

        path.lineWidth = 5.0
        NSColor.green.set()
        path.stroke()
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override var needsPanelToBecomeKey: Bool {
        true
    }
}

final class OverlayWindow: NSPanel {
    convenience init() {
        self.init(
            contentRect: NSScreen.main!.frame,
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        canHide = false
        hidesOnDeactivate = false
        contentView = OverlayView()
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = true
        acceptsMouseMovedEvents = true
        isOpaque = false
        hasShadow = false
        titleVisibility = .hidden
        level = .popUpMenu
        backgroundColor = NSColor.black.withAlphaComponent(0.001)
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    override var canBecomeKey: Bool {
        true
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKey: HotKey!
    private var overlayWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        hotKey = HotKey(key: .o, modifiers: [.command, .option])
        hotKey.keyDownHandler = toggleOverlay
    }

    private func toggleOverlay() {
        if overlayWindowController != nil {
            overlayWindowController?.close()
            overlayWindowController = nil
        } else {
            overlayWindowController = NSWindowController(window: OverlayWindow())
            overlayWindowController?.showWindow(self)
            overlayWindowController?.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
