//
//  LXE300ViewController.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit

class LightViewController: SmartVisionViewController {
    
    var light: SmartVisionLight?
    var zoneControlElements:[ZoneControlElement] = []
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    

    
    @IBOutlet weak var continuousButton: UIButton!
    @IBOutlet weak var overdriveButton: UIButton!
    
    @IBOutlet weak var linkZonesSwitch: UISwitch!
    
    @IBOutlet weak var zoneControlView: UIView!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
     var sliderIndex = 0 as UInt8
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        light = svl.selectedLight
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        appVersionLabel.text = "App Version: "+appVersionString
        firmwareVersionLabel.text = "Firmware: "+(light?.fwMajor.description)!+"."+(light?.fwMinor.description)!
        modelLabel.text = "Model: "+light!.name
        
        continuousButton.addTarget(self, action: #selector(LightViewController.onContinuousButtonClick), for: .touchUpInside)
        overdriveButton.addTarget(self, action: #selector(LightViewController.onOverdriveButtonClick), for: .touchUpInside)
    
        print("Frame: "+zoneControlView.frame.debugDescription)

        for zoneId in 0..<light!.numZones {
            
            print("Zone Id = "+String(zoneId)+" Zones = "+String(light!.zones.count)+" Num Zones = "+String(light!.numZones)+" Name:"+String(light!.name))
            let width = CGFloat(zoneControlView.frame.width / CGFloat(light!.numZones))
            zoneControlElements.append(ZoneControlElement(
                (light?.zones[Int(zoneId)])!,
                                                          zoneControlView.frame.minX + CGFloat(width*CGFloat(zoneId)),
                                                          0,
                                                          width,
                                                          zoneControlView.frame.height))
            
            switch zoneId{
            case 0:
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider0Change), for: .valueChanged)
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider0Done), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableSwitch.addTarget(self, action: #selector(LightViewController.onZone0SwitchChange), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableLabel.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer(target: self, action: #selector(LightViewController.onZone0LabelTouch))
                zoneControlElements[Int(zoneId)].enableLabel.addGestureRecognizer(gesture)
                break
            case 1:
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider1Change), for: .valueChanged)
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider1Done), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableSwitch.addTarget(self, action: #selector(LightViewController.onZone1SwitchChange), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableLabel.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer(target: self, action: #selector(LightViewController.onZone1LabelTouch))
                zoneControlElements[Int(zoneId)].enableLabel.addGestureRecognizer(gesture)
                break
            case 2:
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider2Change), for: .valueChanged)
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider2Done), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableSwitch.addTarget(self, action: #selector(LightViewController.onZone2SwitchChange), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableLabel.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer(target: self, action: #selector(LightViewController.onZone2LabelTouch))
                zoneControlElements[Int(zoneId)].enableLabel.addGestureRecognizer(gesture)
                break
            case 3:
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider3Change), for: .valueChanged)
                zoneControlElements[Int(zoneId)].slider.addTarget(self, action: #selector(LightViewController.onSlider3Done), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableSwitch.addTarget(self, action: #selector(LightViewController.onZone3SwitchChange), for: .touchUpInside)
                zoneControlElements[Int(zoneId)].enableLabel.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer(target: self, action: #selector(LightViewController.onZone3LabelTouch))
                zoneControlElements[Int(zoneId)].enableLabel.addGestureRecognizer(gesture)
                break
            default:
                print("Invalid Zone")
                break
            }
            
            
            zoneControlView.addSubview(zoneControlElements[Int(zoneId)] )
            zoneControlElements[Int(zoneId)].updateUI()
        }
        
        linkZonesSwitch.addTarget(self, action: #selector(LightViewController.onLinkZonesSwitchChange), for: .touchUpInside)
        linkZonesSwitch.thumbTintColor = UIColor(named: "colorAccent")
        linkZonesSwitch.onTintColor = UIColor(named: "colorPrimary")
    
        
        backButton.addTarget(self, action: #selector(LightViewController.onBackButtonClick), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(LightViewController.onFlashButtonClick), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(LightViewController.onSaveButtonClick), for: .touchUpInside)
        
        linkZonesSwitch.setOn(false, animated: false)
        
    
        initWidgets()
    }

    func initSlider(_ slider: VerticalSlider, _ value:UInt16?)
    {
        slider.minValue = CGFloat(MIN_PERCENTAGE)
        slider.maxValue = CGFloat(MAX_PERCENTAGE)
        slider.value = CGFloat(value!)
        slider.minColor = slider.isEnabled == true ? UIColor(named: "colorPrimary")! : UIColor.lightGray
        slider.thumbColor = slider.isEnabled == true ? UIColor(named: "colorPrimary")! : UIColor.lightGray
        
    }
    
    func initWidgets()
    {

        if light?.getMode() == SmartVisionZone.SvlMode_t.CONTINUOUS{
            continuousButton.backgroundColor = UIColor(named: "colorAccent")
        }
        
        if(light?.getMode() == SmartVisionZone.SvlMode_t.OVERDRIVE){
            overdriveButton.backgroundColor = UIColor(named: "colorAccent")
        }
        
        if light?.lightState == SmartVisionLight.SvlLightState_t.SVL_LIGHT_ON{
            flashButton.backgroundColor = UIColor(named: "colorAccent")
        }
        else{
            flashButton.backgroundColor = .lightGray
        }
        
        if (light?.name.starts(with: "A1000"))!{
            continuousButton.isEnabled = false
            continuousButton.backgroundColor = .gray
        }
    
    }
    
    @objc func onContinuousButtonClick()
    {
        light!.setMode(to: .CONTINUOUS)
        continuousButton.backgroundColor = UIColor(named:"colorAccent")
        overdriveButton.backgroundColor = .lightGray
        initWidgets()
        svl.sendMessage((light?.batchConfigurationMessage(true))!)
        saveButton.backgroundColor = .lightGray
        
        for zoneControlElement in zoneControlElements{
            zoneControlElement.updateUI()
        }
    }
    
    @objc func onOverdriveButtonClick()
    {
        light!.setMode(to: .OVERDRIVE)
        overdriveButton.backgroundColor = UIColor(named:"colorAccent")
        continuousButton.backgroundColor = .lightGray
        initWidgets()
        svl.sendMessage((light?.batchConfigurationMessage(true))!)
        saveButton.backgroundColor = .lightGray
        
        for zoneControlElement in zoneControlElements{
            zoneControlElement.updateUI()
        }
    }
    
    @objc func onLinkZonesSwitchChange()
    {
        if linkZonesSwitch.isOn{
            print("Linking Zones")
        }
        else{
            for zoneControlElement in zoneControlElements{
                zoneControlElement.slider.setLockedHigh(false)
                zoneControlElement.slider.setLockedLow(false)
            }
        }
        
    }
    
    func onZoneSwitchChange(_ zoneId: Int)
    {
        if zoneControlElements[zoneId].enableSwitch.isOn{
            light?.setState(ofZone: zoneId, to: .ENABLED)
        }
        else{
            light?.setState(ofZone: zoneId, to: .DISABLED)
        }
        zoneControlElements[zoneId].updateUI()
        svl.sendMessage((light?.batchConfigurationMessage(true))!)
        saveButton.backgroundColor = .lightGray
    }
    
    @objc func onZone0SwitchChange()
    {
        onZoneSwitchChange(0)
    }
    
    @objc func onZone1SwitchChange()
    {
        onZoneSwitchChange(1)
    }
    
    @objc func onZone2SwitchChange()
    {
        onZoneSwitchChange(2)
    }
    
    @objc func onZone3SwitchChange()
    {
        onZoneSwitchChange(3)
    }
    
    @objc func onZone0LabelTouch()
    {
        zoneControlElements[0].enableSwitch.setOn(!zoneControlElements[0].enableSwitch.isOn, animated: true)
        onZone0SwitchChange()
    }
    
    @objc func onZone1LabelTouch()
    {
        zoneControlElements[1].enableSwitch.setOn(!zoneControlElements[1].enableSwitch.isOn, animated: true)
        onZone1SwitchChange()
    }
    
    @objc func onZone2LabelTouch()
    {
        zoneControlElements[2].enableSwitch.setOn(!zoneControlElements[2].enableSwitch.isOn, animated: true)
        onZone2SwitchChange()
    }
    
    @objc func onZone3LabelTouch()
    {
        zoneControlElements[3].enableSwitch.setOn(!zoneControlElements[3].enableSwitch.isOn, animated: true)
        onZone3SwitchChange()
    }
    
    @objc func onSliderChange(_ zoneId: Int)
    {
        //print("Slider "+String(zoneId)+" Changed: "+String(Int(zoneControlElements[zoneId].slider.value)))
        if linkZonesSwitch.isOn{
            let progress1 = UInt16((zoneControlElements[zoneId].sliderLabel.text?.replacingOccurrences(of: "%", with: ""))!)
            var sliders:[VerticalSlider] = []
            for i in 0..<zoneControlElements.count{
                if i != zoneId{
                    sliders.append(zoneControlElements[i].slider)
                }
            }
            setLinkedSliderList(progress1!, zoneControlElements[zoneId].slider, sliders)
        }
        else{
            light?.setPercentage(ofZone: zoneId, to: UInt16(zoneControlElements[zoneId].slider.value))
        }
        
        for zoneControlElement in zoneControlElements{
            if(zoneControlElement.getZone().getState() == .ENABLED){
                zoneControlElement.getZone().setPercentage(zoneControlElement.getZone().getMode(), UInt16(zoneControlElement.slider.value) )
            }
            zoneControlElement.updateUI()
        }
        
        svl.sendMessage((light?.batchConfigurationMessage(false))!)
        saveButton.backgroundColor = .lightGray
    }
    
    @objc func onSliderDone(_ zoneId: Int)
    {
        print("Slider Done")
        if linkZonesSwitch.isOn{
            var sliders:[VerticalSlider] = []
            for i in 0..<zoneControlElements.count{
                if i != zoneId{
                    sliders.append(zoneControlElements[i].slider)
                }
            }
            setLinkedSliderList((light?.getPercentage(ofZone: zoneId))!, zoneControlElements[zoneId].slider, sliders)
        }
        else{
            light?.setPercentage(ofZone: zoneId, to: UInt16(zoneControlElements[zoneId].slider.value))
        }
        
        for zoneControlElement in zoneControlElements{
            if(zoneControlElement.getZone().getState() == .ENABLED){
                zoneControlElement.getZone().setPercentage(zoneControlElement.getZone().getMode(), UInt16(zoneControlElement.slider.value) )
            }
            zoneControlElement.updateUI()
        }
        
        svl.sendMessage((light?.batchConfigurationMessage(true))!)
    }
    
    @objc func onSlider0Change()
    {
        onSliderChange(0)
    }
    
    @objc func onSlider0Done()
    {
        onSliderDone(0)
    }
    
    @objc func onSlider1Change()
    {
        onSliderChange(1)
    }
    
    @objc func onSlider1Done()
    {
        onSliderDone(1)
    }
    
    @objc func onSlider2Change()
    {
        onSliderChange(2)
    }
    
    @objc func onSlider2Done()
    {
        onSliderDone(2)
    }
    
    @objc func onSlider3Change()
    {
        onSliderChange(3)
    }
    
    @objc func onSlider3Done()
    {
        onSliderDone(3)
    }
    
    @objc func onBackButtonClick()
    {
        hideAlert()
        
        if(saveButton.backgroundColor == .lightGray){
            showTwoButtonAlert("Continue without saving?", "", "Yes", "No")
        }
        else{
            performSegue(withIdentifier: "lxe300ToLightListSegue", sender: nil)
        }
        
    }
    
    override func onTwoButtonAlertB1() {
        svl.sendMessage(light!.saveMessage(true))
        super.onTwoButtonAlertB1()
        performSegue(withIdentifier: "lxe300ToLightListSegue", sender: nil)
    }
    
    override func onTwoButtonAlertB2() {
        hideAlert()
        super.onTwoButtonAlertB2()
    }
    
    @objc func onFlashButtonClick()
    {
        if light!.getMode() == .OVERDRIVE{
            svl.sendMessage((light?.flashMessage(25, 250, light!.maxOverdrivePulseWidthUs))!)
            print("MaxPulseWidth: ", light!.maxOverdrivePulseWidthUs)
        }
        else{
            svl.sendMessage((light?.flashMessage(0, 0, light!.maxOverdrivePulseWidthUs))!)
            
            if flashButton.backgroundColor == .lightGray{
                flashButton.backgroundColor = UIColor(named: "colorAccent")
            }
            else{
                flashButton.backgroundColor = .lightGray
            }
        }
        
    }
    
    @objc func onSaveButtonClick()
    {
        svl.sendMessage((light?.saveMessage(false))!)
        saveButton.backgroundColor = UIColor(named:"colorAccent")
        showAlert("Settings Saved", "")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute:
        {
            self.hideAlert()
        })
        
    }
    
    func setLinkedSliderList( _ progress1: UInt16, _ sl1: VerticalSlider, _ sliders: [VerticalSlider])
    {
        var progressChanged =  Int(sl1.value) - Int(progress1)
        
        if progressChanged > 0{
            //SB increased so release the low lock on all sliders
            sl1.setLockedLow(false)
            for slider in sliders{
                slider.setLockedLow(false)
            }
            
            //Find the highest enabled slider of the bunch
            var highestSlider = sl1
            for slider in sliders{
                if slider.isEnabled{
                    if slider.value > highestSlider.value {
                        highestSlider = slider
                    }
                }
            }
            
            let cmpVal = Int(highestSlider.value) + progressChanged

            
            //Check to see if the highest slider would be over max percentage
            if (cmpVal >= MAX_PERCENTAGE) && (highestSlider != sl1) {
                progressChanged = MAX_PERCENTAGE - Int(highestSlider.value)
                for slider in sliders{
                    slider.setValue(CGFloat(Int(slider.value) + progressChanged))
                    slider.setLockedHigh(true)
                }
                sl1.setValue(CGFloat(Int(progress1) + progressChanged))
                sl1.setLockedHigh(true)
            }
            else{
                for slider in sliders{
                    slider.setValue(CGFloat(Int(slider.value)+progressChanged))
                }
            }
        }
        else if progressChanged < 0{
            //Decreasing so release the high lock on all sliders
            sl1.setLockedHigh(false)
            for slider in sliders{
                slider.setLockedHigh(false)
            }
            //Find the lowest enabled seekbar
            var lowestSlider = sl1
            for slider in sliders{
                if slider.isEnabled{
                    if slider.value < lowestSlider.value{
                        lowestSlider = slider
                    }
                }
            }
            
            let cmpVal = Int(lowestSlider.value) + progressChanged
            if ( cmpVal <= MIN_PERCENTAGE) && lowestSlider != sl1{
                //lowest slider has hit min
                progressChanged = Int(lowestSlider.value) - MIN_PERCENTAGE
                for slider in sliders{
                    slider.setValue(CGFloat(Int(slider.value) - progressChanged))
                    slider.setLockedLow(true)
                }
                sl1.setValue(CGFloat(Int(progress1) - progressChanged))
                sl1.setLockedLow(true)
            }
            else{
                //Decrease sliders by progress changed
                for slider in sliders{
                    slider.setValue(CGFloat(Int(slider.value) + progressChanged))
                }
            }
        }
    }
    
   
    
    override func onBleConnectionLost(_ device: BLEDevice, _ error: Error?) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "lxe300ToMainSegue", sender: nil)
    }
    
    override func onBleDisconnected(from device: BLEDevice) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "lxe300ToMainSegue", sender: nil)
    }
    
    override func onDiagnosticsReceived() {
        
        initWidgets()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
