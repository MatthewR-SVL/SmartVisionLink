//
//  VerticalSlider.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/28/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class VerticalSlider: UIControl {
    
    var lockedHigh = false
    var lockedLow = false
    
    /// These values can be set in our storyboard
    @IBInspectable public var minValue: CGFloat = 10.0
    @IBInspectable public var minColor: UIColor = UIColor(named: "colorPrimary") ?? .blue
    
    @IBInspectable public var maxValue: CGFloat = 100.0
    @IBInspectable public var maxColor: UIColor = .lightGray
    
    @IBInspectable public var thumbCorner: CGFloat = 30.0
    @IBInspectable public var thumbColor: UIColor =  UIColor(named: "colorAccent") ?? .orange
    
    @IBInspectable public var trackWidth: CGFloat = 5.0
    
    
    
    /// Standard thumb size for UISlider
    let thumbSize = CGSize(width: 30, height: 30)
    
    lazy var trackLength: CGFloat = {
        return self.bounds.height - (self.thumbOffset * 2)
    }()
    
    lazy var thumbOffset: CGFloat = {
        return self.thumbSize.height / 2
    }()
    
    var thumbRect: CGRect!
    var isMoving = false
    
    @IBInspectable public var value: CGFloat = 0.2 {
        didSet {
            
            if value > maxValue {
                value = maxValue
            }
            if value < minValue {
                value = minValue
            }
            updateThumbRect()
        }
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        updateThumbRect()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isUserInteractionEnabled = true
        contentMode = .redraw
        //updateThumbRect()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateThumbRect()
    }

    
    class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateThumbRect()
    }
    
    func setLockedHigh(_ val: Bool)
    {
        lockedHigh = val
    }
    
    func setLockedLow(_ val: Bool)
    {
        lockedLow = val
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        trackLength = self.bounds.height - (self.thumbOffset * 2)
        
        /// draw the max track
        let x = bounds.width / 2 - trackWidth / 2
        let maxTrackRect = CGRect(x: x, y: 0, width: trackWidth, height: yFromValue(value))
        let maxTrack = UIBezierPath(roundedRect: maxTrackRect, cornerRadius: 6)
        maxColor.setFill()
        maxTrack.fill()
        
        /// draw the min track
        let h = bounds.height
        let minTrackRect = CGRect(x: x, y: yFromValue(value), width: trackWidth, height: h - yFromValue(value))
        let minTrack = UIBezierPath(roundedRect: minTrackRect, cornerRadius: 6)
        minColor.setFill()
        minTrack.fill()
        
        /// draw the thumb
        updateThumbRect()
        let thumbFrame = CGRect(origin: thumbRect.origin, size: thumbRect.size)
        let thumb = UIBezierPath(roundedRect: thumbFrame, cornerRadius: thumbCorner)
        thumbColor.setFill()
        thumb.fill()
        
        context?.saveGState()
        context?.restoreGState()
    }
    
    // MARK: - Standard Control Overrides
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        //if thumbRect.contains(touch.location(in: self)) {
            isMoving = true
        //}
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let location = touch.location(in: self)
        if isMoving {
            setValue(valueFromY(location.y))
        }
        self.sendActions(for: UIControl.Event.valueChanged)
        
        return true
    }
    
    func setValue(_ value: CGFloat){
        if self.value <= value{
            if !lockedHigh{
                self.value = value
            }
        }
        else{
            if !lockedLow{
                self.value = value
            }
        }
        setNeedsDisplay()
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        isMoving = false
    }
    
    // MARK: - Utility
    func valueFromY(_ y: CGFloat) -> CGFloat {
        
        let range1 = (bounds.height - thumbOffset) - thumbOffset
        let range2 = maxValue - minValue
        let range3 = y - thumbOffset
        
        let val = ((range3*range2)/range1) + minValue
        
        return maxValue - val
        
        //return (yOffset * maxValue) / trackLength
    }
    
    func yFromValue(_ value: CGFloat) -> CGFloat {
        //let y = (value * trackLength) / maxValue
        
        let range1 = maxValue - minValue
        let range2 = (bounds.height - thumbOffset) - thumbOffset
        let range3 = value - minValue
        
        let val = ((range3*range2)/range1) + thumbOffset
        return bounds.height - val
    }
    
    func updateThumbRect() {
        thumbRect = CGRect(origin: CGPoint(x: center.x-thumbOffset, y: yFromValue(value) - (thumbSize.height / 2)), size: thumbSize)
    }
    
}
