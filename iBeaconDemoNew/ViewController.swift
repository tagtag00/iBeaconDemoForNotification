//
//  ViewController.swift
//  iBeaconDemoNew
//
//  Created by 田栗信昭 on 2015/11/03.
//  Copyright © 2015年 田栗信昭. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var rssi: UILabel!
    
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.trackLocationManager = CLLocationManager()
        
        self.trackLocationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if(status == CLAuthorizationStatus.NotDetermined){
            self.trackLocationManager.requestAlwaysAuthorization()
        }
        
        let uuid:NSUUID? = NSUUID(UUIDString: "12345678-AAAA-AAAA-AAAA-123456789012")
        
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "net.noumenon-th")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var statusStr = ""
        print("CLAuthrizationStatus: \(statusStr)")
        
        switch status {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
            self.status.text = "位置情報を許可していません"
        case .Authorized, .AuthorizedWhenInUse:
            statusStr = "Authorized"
            self.status.text = "位置情報認証OK"
        default:
            break
        }
        
        print("CLAuthorizationStatus: \(statusStr)")
        
        trackLocationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion){
        print("didStartMonirotingForRegion")
        trackLocationManager.requestStateForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion){
        switch state{
        case .Inside:
            trackLocationManager.startRangingBeaconsInRegion(beaconRegion)
            break
        case .Outside:
            break
        case .Unknown:
            break
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion){
        self.trackLocationManager.startRangingBeaconsInRegion(self.beaconRegion)
        self.status.text = "didEnterRegion"
        
        sendLocalNotificationWithMessage("領域に入りました。")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion){
        self.trackLocationManager.stopRangingBeaconsInRegion(self.beaconRegion)
        
        reset()
        
        sendLocalNotificationWithMessage("領域から出ました。")
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError){
        print("monitoringDidFailForRegion \(error)")
    }
    
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        
        if(beacons.count == 0) { return }
        
        let beacon = beacons[0] 
        
        if(beacon.proximity == CLProximity.Unknown){
            self.distance.text = "Unknown Proximity"
            reset()
            return
        }else if(beacon.proximity == CLProximity.Immediate){
            self.distance.text = "Immediate"
        }else if(beacon.proximity == CLProximity.Near){
            self.distance.text = "Near"
        }else if(beacon.proximity == CLProximity.Far){
            self.distance.text = "Far"
        }
        
        self.status.text = "領域内です"
        self.uuid.text = beacon.proximityUUID.UUIDString
        self.major.text = "\(beacon.major)"
        self.minor.text = "\(beacon.minor)"
        self.accuracy.text = "\(beacon.accuracy)"
        self.rssi.text = "\(beacon.rssi)"
    }
    
    func reset(){
        self.status.text = "none"
        self.uuid.text = "none"
        self.major.text = "none"
        self.minor.text = "none"
        self.accuracy.text = "none"
        self.rssi.text = "none"
        self.distance.text = "none"
    }
    
    func sendLocalNotificationWithMessage(message: String!){
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

