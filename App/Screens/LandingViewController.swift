//
//  LandingViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/16/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit
import Photos

class LandingViewController: UIViewController {
    
    @IBOutlet var vizProjectButton:UIButton!
    
    fileprivate var isSample = false
    fileprivate var newProject = false
    fileprivate var storedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //vizProjectButton.isHidden = VisualizerProject.currentProject.isEmpty && VisualizerProject.latestProjects().count <= 1
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.useTransparentNavigationBar()
    }
    
    @IBAction func vizGalleryButtonClicked(_ sender: AnyObject) {
        self.newProject = true
        ImageManager.sharedInstance.pickerCallback = { (image) -> Void in
            if let img = image {
                self.storedImage = img
                self.performSegue(withIdentifier: "showVisualizer", sender: self)
            }
        }
        ImageManager.sharedInstance.showPhotoLibrary(self, type:.photoLibrary)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ARViewController {
            vc.rawImage = self.storedImage
        }
        self.storedImage = nil
        self.isSample = false
    }
}
