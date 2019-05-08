//
//  ProjectImageCollectionViewController.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 10/28/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher

internal protocol ProjectImageCollectionCellDelegate : NSObjectProtocol {
    func imageSelected(_ image:VisualizerImage)
}

class ProjectImageViewController: UIViewController, UICollectionViewDataSource, ProjectImageCollectionCellDelegate {
    
    var project: VisualizerProject?
    var scrollIndex: Int?
    @IBOutlet weak var projectImageCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.projectImageCollection.dataSource = self
        self.project = VisualizerProject.currentProject
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.project!.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectImageCell", for: indexPath) as? ProjectImageCell else {
            fatalError("Couldn't find ProjectImageCell")
        }
        
        let index = indexPath.item
        cell.image = self.project?.images[index]
        cell.delegate = self
        return cell
    }
    
    func imageSelected(_ image:VisualizerImage) {
        let index = self.project!.getImageIndex(image: image)
        self.scrollIndex = index
        self.performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectDetailsViewController {
            if let scrollIndex = self.scrollIndex {
                vc.scrollIndex = self.scrollIndex!
            }
        }
    }
}

class ProjectImageCell : UICollectionViewCell {
    static let reuseIdentifier = "ProjectCell"
    
    @IBOutlet weak var imageView: UIImageView!

    weak fileprivate var delegate: ProjectImageCollectionCellDelegate?
    
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
            
            self.layer.cornerRadius = 3
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 1
            self.layer.shadowOpacity = 0.3
            self.layer.shadowOffset = CGSize(width: 0.5, height: 1.2)
            
            self.clipsToBounds = false
            
            self.setNeedsDisplay()
        }
    }
    
    @objc func clickedImage() {
        if let image = self.image {
            self.delegate?.imageSelected(image)
        }
    }
}
