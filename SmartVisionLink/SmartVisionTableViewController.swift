//
//  SmarVisionTableViewController.swift
//  SmartVisionLink
//
//  Created by Nick Schrock on 12/20/18.
//  Copyright © 2018 Phase 1 Engineering. All rights reserved.
//

import UIKit

class SmartVisionTableViewController: BLETableViewController, SmartVisionProtocol {
    
    let svl = SmartVisionLinkModel.sharedSmartVisionLinkModelInstance
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var alert: UIAlertController?
    var action: UIAlertAction?
    
    var twoButtonAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        svl.delegate = self
        // Do any additional setup after loading the view.
        svl.delegate = self
        alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        action = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(action) -> Void in self.alert!.dismiss(animated: false, completion: nil)})
        alert?.addAction(action!)
        
        twoButtonAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
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
        self.present(alert!, animated: false, completion: nil)
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
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.style = UIActivityIndicatorView.Style.whiteLarge
        actInd.color = UIColor(named: "colorPrimary")
        actInd.center = CGPoint(x:self.view.center.x, y:self.view.center.y + 100.0)
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    func hideIndicator()
    {
        actInd.isHidden = true
    }
    
    func onDiagnosticsReceived() {
        
    }
    
    func onRamModuleFound(_ ramModule: BLEDevice) {
        
    }
    
    func onLightFound(_ light: SmartVisionLight) {
        
    }
    
    override func onBleDataAvailable(from device: BLEDevice, _ data: Data) {
        svl.handleData(data)
    }
    
    func onLightNotResponding()
    {
        showAlert("Error", "Light not responding")
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
    override func prepare(for segue: UIer: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
