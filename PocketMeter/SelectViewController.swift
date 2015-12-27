//
//  SelectViewController.swift
//  PocketMeter
//
//  Created by Akash Subramanian on 7/19/15.
//  Copyright (c) 2015 Akash Subramanian. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class SelectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    
   
    @IBOutlet weak var mapResultsTableView: UITableView!
    
   
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    var pickerView = UIPickerView()

    var pickerOptions = ["Mumbai Auto Rikshaw", "Dubai Taxi"]
    var mvc = MeterViewController()
    
    @IBOutlet weak var searchText: UITextField!
    var mapView: MKMapView!
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var searchItem: MKMapItem!
    var selectedRow: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerTextField.inputView = pickerView
        pickerTextField.placeholder = "Tap to select a meter type"
        mapResultsTableView.delegate = self
        mapResultsTableView.dataSource = self
        mapResultsTableView.allowsSelection = true
       
    }
    
    
    @IBAction func textFieldReturn(sender: UITextField) {
        sender.resignFirstResponder()
        self.performSearch()
        //mapResultsTableView.reloadData()
    }
    
    
    func performSearch() {
        
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText.text
        //request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response:
            MKLocalSearchResponse!,
            error: NSError!) in
            
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("No matches found")
            } else {
                println("Matches found")
                
                for item in response.mapItems as! [MKMapItem] {
                    println("Name = \(item.name)")
                    println("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    println("Matching items = \(self.matchingItems.count)")
                    
                                    }
            }
        })
    }
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return matchingItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "resultCell", forIndexPath: indexPath) as! ResultsTableViewCell
        
        // Configure the cell...
        let row = indexPath.row
        let item = matchingItems[row]
        cell.nameLabel.text = item.name
        //cell.phoneLabel.text = item.phoneNumber
        
//        if let selected = selectedRow {
//            if row == selected {
//                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            } else {
//                cell.accessoryType = UITableViewCellAccessoryType.None
//            }
//            
//        }

        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("selecting row")
        
        let row = indexPath.row
        selectedRow = row
        let item = matchingItems[row]
        searchItem = item
//        mapResultsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
//    func tableView(tableView: UITableView, reloadRowsAtIndexPaths indexPaths: [AnyObject],
//        withRowAnimation animation: UITableViewRowAnimation) {
//            
//    }
    
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerOptions[row]
    }
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        pickerTextField.resignFirstResponder()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? MeterViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "start":
                    
                    mvc.runMeter = true
                    mvc.meterType = pickerTextField.text ?? ""
                    pickerTextField.resignFirstResponder()
                    mvc.destination = searchItem
                    mvc.mapItems = matchingItems
                    
                    
                    case "stop":
                        mvc.runMeter = false
                    
                    case "meter":
                        mvc.continueMeter = true
                    
                default: break
                    
                }
            }
        }
        
        if let identifier = segue.identifier {
            switch identifier {
            case "settings" :
                if let svc = segue.destinationViewController as? SettingsTableViewController {
                    if let ppc = svc.popoverPresentationController {
                        ppc.delegate = self
                        
                    }
                    
                }
                
            default : break
            }
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    
    
    
    
    
    
    
   
}


