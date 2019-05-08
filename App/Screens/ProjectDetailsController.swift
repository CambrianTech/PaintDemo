//
//  ProjectDetailsController.swift
//  Prestige
//
//  Created by Joel Teply on 7/21/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher
import Social


protocol MultiProjectImageCollectionDelegate : ProjectImageCollectionDelegate {
    func addProjectClicked(_ sender: AnyObject, project:VisualizerProject)
}


//class ProjectThumbnailCell : UICollectionViewCell {
//    @IBOutlet weak var projectImageView: UIImageView!
//}

class MultiProjectImageTableViewCell : UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, ScrollDelegate {
    @IBOutlet weak var imageCollection: ProjectImageCollection! {
        didSet {
            imageCollection.scrollDelegate = self
        }
    }
//    @IBOutlet weak var thumbnailCollection: UICollectionView!
    @IBOutlet weak var assetCollection: UICollectionView!

    weak var delegate: MultiProjectImageCollectionDelegate? {
        didSet {
            imageCollection.imageDelegate = delegate
        }
    }
    
    weak var imageSelectDelegate: ProjectDetailsDelegate?
    
    var project: VisualizerProject? {
        didSet {
            imageCollection.delegate = imageCollection
            imageCollection.dataSource = imageCollection
            imageCollection.project = project
            
//            thumbnailCollection.dataSource = self
//            thumbnailCollection.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let project = self.project {
//            print(project.images.count)
//            return project.images.count
//        }
        // #warning Incomplete implementation, return the number of item
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectThumbnailCell", for: indexPath) as? ProjectThumbnailCell, let project = self.project else {
//            fatalError()
//        }
//
//        let index = (indexPath as NSIndexPath).row
//        let images = project.sortedImages
//        let image = images[index]
//
//
//        var resource: ImageResource!
//        if image.previewImageExists {
//            resource = ImageResource(downloadURL: image.previewImagePath!,
//                                     cacheKey: String(describing: image.modified))
//        } else {
//            resource = ImageResource(downloadURL: image.originalImagePath!)
//        }
//
//        cell.projectImageView.kf.setImage(with: resource)
//        cell.tag = index
//        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clicked(_:))))
        
        return UICollectionViewCell()
    }
    
    func clicked(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            imageCollection.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    func projectImageScrolled(indexPath: IndexPath) {
//        self.thumbnailCollection.scrollToItem(at: indexPath, at: .left, animated: true)
    }

}

class AssetTableViewCell : UITableViewCell, UICollectionViewDataSource {
    @IBOutlet weak var itemView: BorderedImage!
//    @IBOutlet weak var itemNameLabel: UILabel!
//    @IBOutlet weak var itemBrandLabel: UILabel!
//    @IBOutlet weak var itemIDLabel: UILabel!
    @IBOutlet weak var assetsCollection: UICollectionView!
    weak var delegate: ProjectDetailsDelegate?
    var project: VisualizerProject? {
        didSet {
            assetsCollection.dataSource = self
        }
    }
    
//    var item: BrandItem? {
//        didSet {
//            if let item = item {
//                self.itemView.backgroundColor = item.color
//                if (item.itemType != .Paint) {
//                    itemView?.kf.setImage(with: item.getThumbnailPath())
//                }
//            }
//        }
//    }
    
//    @IBAction func itemSelected() {
//        if let item = item {
//            self.delegate?.itemSelected(item)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let project = project {
            var numItems = (self.project?.currentImage?.assets.count ?? 0)
            print(numItems)
            return numItems
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as? AssetCell else {
            fatalError()
        }
        let index = indexPath.item
        cell.item = self.project?.currentImage?.assets[index].getItem()
        
        return cell
    }
}



class AssetCell : UICollectionViewCell {
    
    @IBOutlet var itemView: BorderedImage!
    
    weak var delegate: ProjectDetailsDelegate?
    
    var item: BrandItem? {
        didSet {
            self.itemView.backgroundColor = item?.color
        }
    }
}

//class ProjectDetailsTableViewController: UITableViewController, MultiProjectImageCollectionDelegate {
//
//
//    
//}



