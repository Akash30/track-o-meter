//
//  SettingsTableViewController.swift
//  PocketMeter
//
//  Created by Akash Subramanian on 7/23/15.
//  Copyright (c) 2015 Akash Subramanian. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController
{
    var mvc = MeterViewController()
    var isStandardMapType = false
    var isSatelliteMapType = false
    var isHybridMapType = false
    
    @IBOutlet weak var standardMapView: UITableViewCell!
    @IBOutlet weak var satelliteMapView: UITableViewCell!
    @IBOutlet weak var hybridMapView: UITableViewCell!
    
    @IBAction func satelliteTapGestureRecognizer(sender: UITapGestureRecognizer) {
        satelliteMapView.selected = true
        standardMapView.selected = false
        hybridMapView.selected = false
        isStandardMapType = false
        isSatelliteMapType = true
        isHybridMapType = false
        
        NSUserDefaults.standardUserDefaults().setValue(isStandardMapType, forKey: "standard")
        NSUserDefaults.standardUserDefaults().setValue(isSatelliteMapType, forKey: "satellite")
        NSUserDefaults.standardUserDefaults().setValue(isHybridMapType, forKey: "hybrid")

    }
    
    @IBAction func hybridTapGestureRecognizer(sender: UITapGestureRecognizer) {
        satelliteMapView.selected = false
        standardMapView.selected = false
        hybridMapView.selected = true
        isStandardMapType = false
        isSatelliteMapType = false
        isHybridMapType = true
        
        NSUserDefaults.standardUserDefaults().setValue(isStandardMapType, forKey: "standard")
        NSUserDefaults.standardUserDefaults().setValue(isSatelliteMapType, forKey: "satellite")
        NSUserDefaults.standardUserDefaults().setValue(isHybridMapType, forKey: "hybrid")

    }
    
    
    @IBAction func standardTapGestureRecognizer(sender: UITapGestureRecognizer) {
        satelliteMapView.selected = false
        standardMapView.selected = true
        hybridMapView.selected = false
        isStandardMapType = true
        isSatelliteMapType = false
        isHybridMapType = false
        
        NSUserDefaults.standardUserDefaults().setValue(isStandardMapType, forKey: "standard")
        NSUserDefaults.standardUserDefaults().setValue(isSatelliteMapType, forKey: "satellite")
        NSUserDefaults.standardUserDefaults().setValue(isHybridMapType, forKey: "hybrid")
        
    }
    
    
    
    /*
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if standardMapView.selected{
            println("row 1")
            isStandardMapType = true
            isSatelliteMapType = false
            isHybridMapType = false
        } else
        if satelliteMapView.selected {
            println("row 2")
            isStandardMapType = false
            isSatelliteMapType = true
            isHybridMapType = false
            
        } else
        if hybridMapView.selected {
                        println("row 3")
            isStandardMapType = false
            isSatelliteMapType = false
            isHybridMapType = true
            
        }
        
        
        NSUserDefaults.standardUserDefaults().setValue(isStandardMapType, forKey: "standard")
        NSUserDefaults.standardUserDefaults().setValue(isSatelliteMapType, forKey: "satellite")
        NSUserDefaults.standardUserDefaults().setValue(isHybridMapType, forKey: "hybrid")
        println("selecting")
    }
    
    */

    
    
}
