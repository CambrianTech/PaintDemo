//
//  ProjectImageViewcontroller.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 10/24/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher
import RealmSwift

internal protocol ImageCellDelegate : NSObjectProtocol {
    func imageSelected(_ image:VisualizerImage)
}

class ProjectImageViewController: UIViewController, UICollectionViewDataSource, ImageCellDelegate {
    
    @IBOutlet weak var imageCollection: UICollectionView!
    var project: VisualizerProject = VisualizerProject.currentProject
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return project.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectImageCell", for: indexPath) as? ProjectImageCell else {
            fatalError("Could not laod ProjectImageCell")
        }
        cell.image = self.project.images[(indexPath as NSIndexPath).row]
        cell.delegate = self
        return cell
    }
    func imageSelected(_ image:VisualizerImage) {
        // Move to next view Controller here
    }
    
    
}

class ProjectImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    weak fileprivate var delegate : ImageCellDelegate?
    var image: VisualizerImage? {
        didSet {
            if let image = image {
                let resource = ImageResource(downloadURL: image.previewImagePath!,
                                             cacheKey: String(describing: image.modified))
                imageView.kf.setImage(with: resource)
            } else {
                imageView.image = UIImage(named: "ic_image_gallery")
                imageView.contentMode = .scaleAspectFit
            }
            
            if !imageView.isUserInteractionEnabled {
                let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.clickedImage))
                singleTap.numberOfTapsRequired = 1
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(singleTap)
            }
        }
    }
    
    @objc func clickedImage() {
        self.delegate?.imageSelected(self.image!)
    }
}




