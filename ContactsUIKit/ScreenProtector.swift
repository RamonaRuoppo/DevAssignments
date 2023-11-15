//
//  ScreenshotObserver.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//

import Foundation
import UIKit

public class ScreenProtector {
    
    private var window: UIWindow? = nil
    private var screenImage: UIImageView? = nil
    private var screenBlur: UIView? = nil
    private var screenColor: UIView? = nil
    private var screenPrevent = UITextField()
    private var screenshotObserve: NSObjectProtocol? = nil
    private var screenRecordObserve: NSObjectProtocol? = nil

    public init(window: UIWindow?) {
        self.window = window
    }
    
    public func configurePreventionScreenshot() {
        // Check if the window is available and if the screenPrevent is not already added
        guard let window = window, !window.subviews.contains(screenPrevent) else { return }

        window.addSubview(screenPrevent)

        screenPrevent.center = window.center
        screenPrevent.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            screenPrevent.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            screenPrevent.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        ])

        if let windowLayer = window.layer.superlayer {
            windowLayer.addSublayer(screenPrevent.layer)

            if #available(iOS 17.0, *) {
                screenPrevent.layer.sublayers?.last?.addSublayer(window.layer)
            } else {
                screenPrevent.layer.sublayers?.first?.addSublayer(window.layer)
            }
        }
    }
    
    public func enabledPreventScreenshot() {
        screenPrevent.isSecureTextEntry = true
    }
    
    public func disablePreventScreenshot() {
        screenPrevent.isSecureTextEntry = false
    }
    
    public func enabledBlurScreen(style: UIBlurEffect.Style = UIBlurEffect.Style.light) {
        // Capture a snapshot of the current screen
        screenBlur = UIScreen.main.snapshotView(afterScreenUpdates: false)
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        screenBlur?.addSubview(blurBackground)
        blurBackground.frame = (screenBlur?.frame)!
        window?.addSubview(screenBlur!)
    }
    
    public func disableBlurScreen() {
        screenBlur?.removeFromSuperview()
        screenBlur = nil
    }
    
    public func enableColorScreen(hexColor: String) {
        // Check if the window is available and if the color screen is not already enabled
        guard let window = window, screenColor == nil else { return }

        let colorView = UIView(frame: window.bounds)
        colorView.backgroundColor = UIColor(named: hexColor)

        window.addSubview(colorView)
        screenColor = colorView
    }
    
    public func disableColorScreen() {
        screenColor?.removeFromSuperview()
        screenColor = nil
    }
    
    public func enabledImageScreen(named: String) {
        screenImage = UIImageView(frame: UIScreen.main.bounds)
        screenImage?.image = UIImage(named: named)
        screenImage?.isUserInteractionEnabled = false
        screenImage?.contentMode = .scaleAspectFill;
        screenImage?.clipsToBounds = true;
        window?.addSubview(screenImage!)
    }
    
    public func disableImageScreen() {
        screenImage?.removeFromSuperview()
        screenImage = nil
    }
    
    public func removeObserver(observer: NSObjectProtocol?) {
        guard let obs = observer else {return}
        NotificationCenter.default.removeObserver(obs)
    }
    
    public func removeScreenshotObserver() {
        if screenshotObserve != nil {
            self.removeObserver(observer: screenshotObserve)
            self.screenshotObserve = nil
        }
    }

    public func removeScreenRecordObserver() {
        if screenRecordObserve != nil {
            self.removeObserver(observer: screenRecordObserve)
            self.screenRecordObserve = nil
        }
    }
    
    public func removeAllObserver() {
        self.removeScreenshotObserver()
        self.removeScreenRecordObserver()
    }
    
    public func screenshotObserver(using onScreenshot: @escaping () -> Void) {
        screenshotObserve = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            onScreenshot()
        }
    }
    
    @available(iOS 11.0, *)
    public func screenRecordObserver(using onScreenRecord: @escaping (Bool) -> Void) {
        screenRecordObserve =
        NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            let isCaptured = UIScreen.main.isCaptured
            onScreenRecord(isCaptured)
        }
    }
    
    @available(iOS 11.0, *)
    public func screenIsRecording() -> Bool {
        return UIScreen.main.isCaptured
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
