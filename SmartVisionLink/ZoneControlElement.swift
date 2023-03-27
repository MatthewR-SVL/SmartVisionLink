//
//  ZoneControlElement.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 9/11/19.
//  Copyright © 2019 Phase 1 Engineering. All rights reserved.
//

import Foundation
import UIKit

class ZoneControlElement: UIView
{
    @IBOutlet private weak var view: ZoneControlElement!
    
    lazy var x: CGFloat = {
        let x = CGFloat(0.0)
        return x
    }()
    lazy var y: CGFloat = {
        let y = CGFloat(0.0)
        return y
    }()
    lazy var width: CGFloat = {
        let width = CGFloat(0.0)
        return width
    }()
    lazy var height: CGFloat = {
        let height = CGFloat(0.0)
        return height
    }()
    
    lazy var zone: SmartVisionZone = {
        let zone = SmartVisionZone(0)
        return zone
    }()
    
    lazy var slider: VerticalSlider = {
        let slider = VerticalSlider()
        slider.minValue = CGFloat(MIN_PERCENTAGE)
        slider.setValue(CGFloat((self.zone.getPercentage())))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.backgroundColor = UIColor(named: "SystemColor")
        return slider
    }()
    
    lazy var sliderLabel: UILabel = {
        let sliderLabel = UILabel()
        sliderLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderLabel.textAlignment = .center
        sliderLabel.font = UIFont.systemFont(ofSize: 10)
        return sliderLabel
    }()
    
    lazy var enableLabel: UILabel = {
        let enableLabel = UILabel()
        enableLabel.translatesAutoresizingMaskIntoConstraints = false
        enableLabel.font = UIFont.systemFont(ofSize: 10)
        enableLabel.textAlignment = .center
        return enableLabel
    }()
    
    lazy var enableSwitch: UISwitch = {
       let enableSwitch = UISwitch()
        enableSwitch.thumbTintColor = UIColor(named:"colorAccent")
        enableSwitch.onTintColor = UIColor(named: "colorPrimary")
        enableSwitch.translatesAutoresizingMaskIntoConstraints = false
        return enableSwitch
    }()
    
    lazy var sliderView: UIView = {
       let sliderView = UIView()
        sliderView.addSubview(sliderLabel)
        sliderView.addSubview(slider)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        //sliderView.backgroundColor = .black
        return sliderView
    }()
    
    lazy var enableView: UIView = {
        let enableView = UIView()
        enableView.addSubview(enableSwitch)
        enableView.addSubview(enableLabel)
        enableView.translatesAutoresizingMaskIntoConstraints = false
        //enableView.backgroundColor = .gray
        return enableView
    }()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(_ zone:SmartVisionZone, _ x: CGFloat, _ y: CGFloat,_ width:CGFloat, _ height: CGFloat)
    {
        
        self.init(frame: CGRect(x:x, y:y, width: width, height: height))
        self.zone = zone
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    private func commonInit()
    {
        addSubview(sliderView)
        addSubview(enableView)
        setupLayout()
    }
    
    private func setupLayout()
    {
        NSLayoutConstraint.activate([
            
            //Setup constraints within views
            sliderLabel.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor),
            sliderLabel.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor),
            sliderLabel.topAnchor.constraint(equalTo: sliderView.topAnchor),
            sliderLabel.heightAnchor.constraint(equalTo: sliderView.heightAnchor, multiplier: 0.2),

            slider.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor),
            slider.heightAnchor.constraint(equalTo: sliderView.heightAnchor, multiplier: 0.8),

            enableLabel.leadingAnchor.constraint(equalTo: enableView.leadingAnchor),
            enableLabel.heightAnchor.constraint(equalTo: enableView.heightAnchor, multiplier: 0.25),
            enableLabel.bottomAnchor.constraint(equalTo: enableView.bottomAnchor),
            enableLabel.trailingAnchor.constraint(equalTo: enableView.trailingAnchor),

            enableSwitch.heightAnchor.constraint(equalTo: enableView.heightAnchor, multiplier: 0.75),
            enableSwitch.centerXAnchor.constraint(equalTo: enableView.centerXAnchor),
            enableSwitch.centerYAnchor.constraint(equalTo: enableView.centerYAnchor),
            
            //Setup View Constraints
            sliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sliderView.topAnchor.constraint(equalTo: topAnchor),
            sliderView.heightAnchor.constraint(equalTo: super.heightAnchor, multiplier: 0.8),
            
            enableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            enableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            enableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            enableView.heightAnchor.constraint(equalTo: super.heightAnchor, multiplier: 0.2)
            //enableView.heightAnchor.constraint(equalToConstant: 20)
            
            ])
        
        

    }
    
    override func updateConstraints()
    {
        //set subview constraints here
        super.updateConstraints()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        //set subview frames here
        
    }
    
    func updateUI()
    {
        //print("\nUpdate UI: "+String(self.zone.zoneId)+" "+String(self.zone.getPercentage(self.zone.getMode()))+"%"+" En:"+String(zone.getState().rawValue))
        
        enableLabel.text = "Zone: "+String(self.zone.zoneId+1)
        sliderLabel.text = String(self.zone.getPercentage(self.zone.getMode()))+"%"
        slider.setValue(CGFloat(self.zone.getPercentage(self.zone.getMode())))
    
        switch zone.getState()
        {
            case SmartVisionZone.SvlZoneState_t.ENABLED:
                enableSwitch.setOn( true, animated: true)
                slider.isEnabled = true
                slider.thumbColor = UIColor(named: "colorAccent")!
                slider.minColor = UIColor(named: "colorPrimary")!
                slider.maxColor = .lightGray
            break
            case SmartVisionZone.SvlZoneState_t.DISABLED:
                enableSwitch.setOn( false, animated: true)
                slider.isEnabled = false
                slider.thumbColor = .lightGray
                slider.minColor = .lightGray
                slider.maxColor = .lightGray
                break
        }
    }
    
    func getZone() -> SmartVisionZone{
        return self.zone
    }
}
