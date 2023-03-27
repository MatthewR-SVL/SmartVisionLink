//
//  SmartVisionViewController.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit

let BLE_DEVICE_NAME = "RAM"

class SmartVisionViewController: BLEViewController, SmartVisionProtocol {
   
    
    let svl = SmartVisionLinkModel.sharedSmartVisionLinkModelInstance
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var alert: UIAlertController?
    var action: UIAlertAction?
    
    var twoButtonAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        svl.delegate = self
        alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        action = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(action) -> Void in self.alert!.dismiss(animated: false, completion: nil)})
        alert?.addAction(action!)
        
        twoButtonAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)

        
        twoButtonAlert!.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.onTwoButtonAlertB1()
        }))
        twoButtonAlert!.addAction(UIAlertAction(title: "No", style: .default, handler: {(action: UIAlertAction!) in
            self.onTwoButtonAlertB2()
        }))
    }
    
    func showAlert(_ title: String,_ message: String){
        if((alert?.isViewLoaded)!){
            print("Dismissing Alert \(alert!.title!+": "+alert!.message!)")
            alert?.dismiss(animated: false, completion: nil)
        }
        
        if((twoButtonAlert?.isViewLoaded)!){
            twoButtonAlert?.dismiss(animated: false, completion: nil)
        }
        
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        action = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(action) -> Void in self.alert!.dismiss(animated: false, completion: nil)})
        alert?.addAction(action!)
        
        print("Showing Alert \(title+": "+message)")
        self.present(alert!, animated: true, completion: nil)
    }
    
    func showTwoButtonAlert(_ title: String, _ message: String, _ b1:String, _ b2:String )
    {
        if((alert?.isViewLoaded)!){
            alert?.dismiss(animated: false, completion: nil)
        }
        if((twoButtonAlert?.isViewLoaded)!){
            twoButtonAlert?.dismiss(animated: false, completion: nil)
        }
        
        twoButtonAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        
        twoButtonAlert!.addAction(UIAlertAction(title: b1, style: .default, handler: {(action: UIAlertAction!) in
            self.onTwoButtonAlertB1()
        }))
        
        twoButtonAlert!.addAction(UIAlertAction(title: b2, style: .default, handler: {(action: UIAlertAction!) in
            self.onTwoButtonAlertB2()
        }))
        
        print("Showing Two Button Alert \(title+": "+message)")
        self.present(twoButtonAlert!, animated: true, completion: nil)
    }
    
    func onTwoButtonAlertB1()
    {
        print("B1 pressed")
        hideAlert()
    }
    
    func onTwoButtonAlertB2()
    {
        print("B2 pressed")
        hideAlert()
    }
    
    func hideAlert()
    {
        if(alert!.isViewLoaded){
            print("Dismissing Alert \(alert!.title!+": "+alert!.message!)")
            alert?.dismiss(animated: false, completion: nil)
        }
        
        if (twoButtonAlert!.isViewLoaded){
            twoButtonAlert?.dismiss(animated: false, completion: nil)
        }
    }
    func showIndicator()
    {
        actInd.isHidden = false
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.style = UIActivityIndicatorView.Style.whiteLarge
        actInd.color = UIColor(named: "Accent 1")
        actInd.center = CGPoint(x:self.view.center.x, y:self.view.center.y + 100.0)
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    func hideIndicator()
    {
        actInd.isHidden = true
    }
    
    override func onBleDataAvailable(from device: BLEDevice, _ data: Data) {
        svl.handleData(data)
    }
    
    
    override func onBleDeviceFound(_ device: BLEDevice) {
        if(device.cbPeripheral.name == nil){return}
        if(device.cbPeripheral.name!.isEqual(BLE_DEVICE_NAME)){
            print("Adding RAM Module")
            svl.onRamModuleFound(device)
        }
    }
        
    func onRamModuleFound(_ ramModule: BLEDevice) {
        
    }
    
    func onLightFound(_ light: SmartVisionLight) {
        
    }
        
    
    func onDiagnosticsReceived() {
        
    }
    
    func onLightNotResponding() {
        
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
