//
//  DeviceListTableViewController.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit
import CoreBluetooth

class BleDeviceCellTableViewCell: UITableViewCell
{
    @IBOutlet weak var signalStrengthImageView: UIImageView!
    
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var uniqueId: UILabel!
}

class DeviceListTableViewController: SmartVisionTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(self.refreshHandler), for: UIControl.Event.valueChanged)
    }
    
    @objc func refreshHandler(){
        print("DLVC Refresh Event!")
        ble.scan(for: BLE_SCAN_SECONDS)
        self.tableView.reloadData()
    }
    
    override func onBleScanComplete(_ deviceList: [BLEDevice]) {
        self.refreshControl?.endRefreshing()
    }
    
    override func onBleScanCanceled(_ deviceList: [BLEDevice]) {
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return svl.ramModules.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "bleDeviceTableHeaderCell", for: indexPath)
            return cell
        }
            
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "bleDeviceCell", for: indexPath) as! BleDeviceCellTableViewCell
            
            //cell.uniqueId.text = vega.vegaLights[indexPath.row-1].cbPeripheral.identifier.description
            cell.uniqueId.text = svl.ramModules[indexPath.row-1].macAddress
            
            svl.ramModules[indexPath.row-1].cbPeripheral.readRSSI()
            let rssi = svl.ramModules[indexPath.row-1].rssi
            cell.rssiLabel.text = "RSSI: "+String(rssi.intValue)+" dbm"
            
            if rssi.intValue > -55{
                cell.signalStrengthImageView.image =  UIImage(named: "ssExcellent")
            }
            else if( rssi.intValue <= -55 && rssi.intValue > -64){
                cell.signalStrengthImageView.image =  UIImage(named: "ssVeryGood")
            }
            else if(rssi.intValue <= -64 && rssi.intValue > -73){
                cell.signalStrengthImageView.image =  UIImage(named: "ssGood")
            }
            else if(rssi.intValue <= -73 && rssi.intValue > -81){
                cell.signalStrengthImageView.image =  UIImage(named: "ssLow")
            }
            else if(rssi.intValue <= -81 && rssi.intValue > -90){
                cell.signalStrengthImageView.image =  UIImage(named: "ssVeryLow")
            }
            else{
                cell.signalStrengthImageView.image =  UIImage(named: "ssNoSignal")
            }
            
            
            return cell
        }
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DLVC: Table Row = \(String(indexPath.row)) #Devices = \(String(svl.ramModules.count))")
        if(indexPath.row > 0 && indexPath.row <= svl.ramModules.count){
            svl.ram = svl.ramModules[indexPath.row-1]
            ble.connect(to: svl.ram!)
        }
    }
    
    
    
    override func onBleConnecting(to device: BLEDevice)
    {
        print("DLVC: Connecting")
        //Show Dialog saying we are connecting
        showAlert("Connecting to Light", device.cbPeripheral.identifier.description)
        
        showIndicator()
    }
    
    override func onBleConnectionFailed(_ device: BLEDevice, _ error: Error?) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "deviceListToMainSegue", sender: nil)
    }
    
    override func onBleConnectionLost(_ device: BLEDevice, _ error: Error?) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "deviceListToMainSegue", sender: nil)
    }
    
    override func onBleDisconnected(from device: BLEDevice) {
        svl.stopHeartbeat()
        hideAlert()
        performSegue(withIdentifier: "deviceListToMainSegue", sender: nil)
    }
    
    override func onBleCharacteristicsDiscovered(of device: BLEDevice, _ characterstics: [CBCharacteristic])
    {
        hideIndicator()
        hideAlert()
        svl.ram?.txCharacteristic = device.txCharacteristic
        svl.ram?.rxCharacteristic = device.rxCharacteristic
        svl.sendStartComMessage()
        svl.startHeartbeat()
        performSegue(withIdentifier: "deviceListToLightListSegue", sender: nil)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
