//
//  MainViewController.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit

class MainViewController: SmartVisionViewController {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var versionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectButton.addTarget(self, action: #selector(MainViewController.onConnectButtonClick), for: .touchUpInside)
        svl.selectedLight = nil
        svl.lights = []
        svl.ramModules = []
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        versionTextField.text = appVersionString
    }
    
    
    @objc func onConnectButtonClick()
    {
        //Start scanning for devices
        ble.scan(for: BLE_SCAN_SECONDS)
        
        //Show progress indicator
        showIndicator()
        
        //Show Dialog saying we are connecting
        showAlert("Searching for Devices", "")
    }
    
    override func onBleScanComplete(_ deviceList: [BLEDevice]) {
        hideAlert()
        hideIndicator()
        if svl.ramModules.count > 0{
            performSegue(withIdentifier: "mainToDeviceListSegue", sender: nil)
        }
        else{
            showAlert("No Devices Found", "")
        }
    }
    
    override func onBleNotEnabled() {
        showAlert("Bluetooth Not Enabled", "Bluetooth must be enabled to communicate with a SmartVisionLink device.")
    }
    
    override func onBleNotSupported() {
        showAlert("Bluetooth Not Supported", "Bluetooth must be enabled to communicate with a SmartVisionLink device.  This device does not support Bluetooth.")
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
