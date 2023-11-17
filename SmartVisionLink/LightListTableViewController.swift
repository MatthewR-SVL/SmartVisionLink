//
//  LightList.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit

class LightTableViewCell: UITableViewCell
{

    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
}

class LightButtonTableViewCell: UITableViewCell
{
    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var discoverButton: UIButton!
}

class LightFooterTableViewCell: UITableViewCell
{
    @IBOutlet weak var disconnectButton: UIButton!
}

class LightListTableViewController: SmartVisionTableViewController
{
    weak var discoverButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME*5), execute:
        {
            self.discoverLights()
        })
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(self.refreshHandler), for: UIControl.Event.valueChanged)
    }
    
    @objc func refreshHandler(){
        print("DLVC Refresh Event!")
        discoverLights()
        self.tableView.reloadData()
    }
    
    func discoverLights()
    {
        self.discoverButton?.isEnabled = false
        self.discoverButton?.backgroundColor = .gray
        svl.sendStartComMessage()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME * 2), execute:
            {
                let numRetries = 5
                self.svl.sendDiscoveryMessage(UInt16(DISCOVERY_PERIOD*1000/numRetries))
                for i in 1..<numRetries
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds( (DISCOVERY_PERIOD * 1000 / i)), execute:
                        {
                            self.svl.sendDiscoveryMessage(UInt16(DISCOVERY_PERIOD*1000/numRetries))
                    })
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(DISCOVERY_PERIOD * 1000), execute:
                    {
                        self.discoverButton?.isEnabled = true
                        self.discoverButton?.backgroundColor = .lightGray
                        self.refreshControl?.endRefreshing()
                })
            
        })
    }
    
    override func onLightFound(_ light: SmartVisionLight) {
        self.tableView.reloadData()
    }
    
    @objc func onConfigureButtonClick()
    {
        //svl.getDiagnostics()
        onDiagnosticsReceived()
    }

    override func onDiagnosticsReceived() {
        print("LLTVC: Diagnostics Received")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(BLE_WRITE_TIME), execute:
        {
            self.hideAlert()
            self.performSegue(withIdentifier: "lightListToLxe300Segue", sender: nil)
        })
    }
    
    @objc func onDiscoverButtonClick()
    {
        
        discoverLights()
    }
    
    @objc func onDisconnectButtonClick()
    {
        svl.stopHeartbeat()
        usleep(100000)
        svl.sendEndComMessage()
        usleep(100000)
        ble.disconnect(from: svl.ram!)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return svl.lights.count + 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "lightHeaderCell", for: indexPath)
            return cell
        }
            
        else if(indexPath.row < svl.lights.count + 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "lightCell", for: indexPath) as! LightTableViewCell
            let light = svl.lights[indexPath.row - 1]
            cell.firmwareLabel.text = light.fwMajor.description + "." + light.fwMinor.description
            cell.modelLabel.text = light.name
            cell.serialNumberLabel.text = light.serialNumber.intVal.description
            if(svl.selectedLight != nil){
                if(svl.selectedLight?.serialNumber.intVal == light.serialNumber.intVal){
                    print("\nLight is selected!")
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
            
            return cell
        }
        else if (indexPath.row == svl.lights.count + 1 ){
            let cell = tableView.dequeueReusableCell(withIdentifier: "lightButtonsCell", for: indexPath) as! LightButtonTableViewCell
            if(svl.selectedLight == nil){
                cell.configureButton.isEnabled = false
                cell.configureButton.backgroundColor = .gray
            }
            cell.configureButton.addTarget(self, action: #selector(LightListTableViewController.onConfigureButtonClick), for: .touchUpInside)
            cell.discoverButton.addTarget(self, action: #selector(LightListTableViewController.onDiscoverButtonClick), for: .touchUpInside)
            self.discoverButton = cell.discoverButton
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "lightFooterCell", for: indexPath) as! LightFooterTableViewCell
            cell.disconnectButton.addTarget(self, action: #selector(LightListTableViewController.onDisconnectButtonClick), for: .touchUpInside)
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row > 0 && indexPath.row <= svl.lights.count){
            let light = svl.lights[indexPath.row - 1]
            let cell = tableView.cellForRow(at: IndexPath(row: svl.lights.count+1, section: 0)) as! LightButtonTableViewCell
            cell.configureButton.isEnabled = true
            cell.configureButton.backgroundColor = .lightGray
            
            svl.selectLight(light)
        }
    }
    
    override func onBleDisconnected(from device: BLEDevice) {
        hideAlert()
        performSegue(withIdentifier: "lightListToMainSegue", sender: nil)
    }
    
    override func onBleConnectionLost(_ device: BLEDevice, _ error: Error?) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "lightListToMainSegue", sender: nil)
    }

}
