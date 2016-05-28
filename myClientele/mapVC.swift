//
//  mapVC.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/16/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit
import MapKit

class mapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var region = MKCoordinateRegion()
        
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        mapView.addAnnotation(annotation)
        annotation.coordinate = location.coordinate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }



}
