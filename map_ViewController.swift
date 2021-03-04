//
//  map_ViewController.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit
import MapKit

class map_ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet var locationOutlet: UIButton!
    
    let locationManager = CLLocationManager()
    var CLCoOrdinate = [CLLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map_view.showsUserLocation = true
        map_view.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let annotationView = MKPinAnnotationView()
          annotationView.pinTintColor = .blue
          return annotationView
      }
    
    @IBAction func saveLocation(_ sender:
        UIButton) {
        locationOutlet.setTitle("Location Saved", for: .normal)
        //performSegue(withIdentifier: "showMap", sender: self)
    }
    
}
