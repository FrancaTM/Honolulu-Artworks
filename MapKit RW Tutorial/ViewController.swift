//
//  ViewController.swift
//  MapKit RW Tutorial
//
//  Created by Tulio Marcos Franca on 03/09/17.
//  Copyright © 2017 0neTech. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rwLogoButton: UIButton!
//    @IBOutlet weak var rwLogoImageView: UIImageView!
    
    let regionRadius: CLLocationDistance = 1000
    
    var artworks: [Artwork] = []
    
    // MARK: - View life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RW logo image view
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:         #selector(ViewController.rwLogoImageViewTapped))
//        rwLogoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // RW logo button
        rwLogoButton.layer.cornerRadius = rwLogoButton.frame.size.width/2
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        
        // show artwork on map
        //        let artwork = Artwork(title: "King David Kalakaua", locationName: "Waikiki Gateway Park", discipline: "Sculpture", coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        //        mapView.addAnnotation(artwork)
        
        //        mapView.register(ArtworkMarkerView.self,
        //                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ArtworkView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        loadInitialData()
        mapView.addAnnotations(artworks)
    }
    
    // MARK: - Actions
    @IBAction func rwLogoButtonTapped(_ sender: UIButton) {
        if let urlRWTutorial = URL(string: "https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started") {
            UIApplication.shared.open(urlRWTutorial, options: [:], completionHandler: nil)
        }
    }
    
//    @IBAction func rwLogoImageViewTapped() {
//        if let urlRWTutorial = URL(string: "https://www.raywenderlich.com/160517/mapkit-tutorial-getting-started") {
//            UIApplication.shared.open(urlRWTutorial, options: [:], completionHandler: nil)
//        }
//    }
    
    // MARK: - Helper methods
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadInitialData() {
        guard let fileName = Bundle.main.path(forResource: "PublicArt", ofType: "json") else {
            return
        }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard let data = optionalData,
            let json = try? JSONSerialization.jsonObject(with: data),
            let dictionary = json as? [String: Any],
            let works = dictionary["data"] as? [[Any]] else { return }
        let validWorks = works.flatMap {
            Artwork(json: $0)
        }
        artworks.append(contentsOf: validWorks)
    }
    
    // MARK: - CLLocationManager
    let locationManager = CLLocationManager()

    func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        
        /* if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        } */
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? Artwork else {
//            return nil
//        }
//
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

