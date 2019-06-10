//
//  ProjectDetailsViewController.swift
//  Prestige
//
//  Created by Joel Teply on 7/21/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher

protocol MultiProjectImageCollectionDelegate : ProjectImageCollectionDelegate {
    func addProjectClicked(_ sender: AnyObject, project:VisualizerProject)
}

protocol ProjectDetailsDelegate : NSObjectProtocol {
    func itemSelected(_ item:BrandItem)
}

class ProjectThumbnailCell : UICollectionViewCell {
    @IBOutlet weak var projectImageView: UIImageView!
}

class MultiProjectImageTableViewCell : UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var imageCollection: ProjectImageCollection!
    @IBOutlet weak var thumbnailCollection: UICollectionView!
    
    
    weak var delegate: MultiProjectImageCollectionDelegate? {
        didSet {
            imageCollection.imageDelegate = delegate
        }
    }
    
    var project: VisualizerProject? {
        didSet {
            imageCollection.delegate = imageCollection
            imageCollection.dataSource = imageCollection
            imageCollection.project = project
            
            thumbnailCollection.dataSource = self
            thumbnailCollection.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of item
        if let project = self.project {
            print(project.images.count)
            return project.images.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectThumbnailCell", for: indexPath) as? ProjectThumbnailCell, let project = self.project else {
            fatalError()
        }
        
        let index = (indexPath as NSIndexPath).row
        let images = project.sortedImages
        let image = images[index]
        
        
        var resource: ImageResource!
        if image.previewImageExists {
            resource = ImageResource(downloadURL: image.previewImagePath!,
                                     cacheKey: String(describing: image.modified))
        } else {
            resource = ImageResource(downloadURL: image.originalImagePath!)
        }
        
        cell.projectImageView.kf.setImage(with: resource)
        cell.tag = index
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clicked(_:))))
        
        return cell
    }
    
    @objc func clicked(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            imageCollection.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
}

class AssetTableViewCell : UITableViewCell {
    
    @IBOutlet weak var itemView: BorderedImage!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemBrandLabel: UILabel!
    @IBOutlet weak var itemIDLabel: UILabel!
    
    weak var delegate: ProjectDetailsDelegate?
    
    
    var item: BrandItem? {
        didSet {
            self.itemView.backgroundColor = item?.color
            self.itemNameLabel.text = "Name: \(String(describing: item!.name))"
            self.itemBrandLabel.text = "Brand: \(String(describing: item!.getRootCategory().name))"
            self.itemIDLabel.text = "ID: \(String(describing: item!.itemCode))"
            
            if(item?.itemType == .Texture) {
                itemView?.kf.setImage(with: item?.getThumbnailPath())
            }
        }
    }
    
    @IBAction func itemSelected() {
        if let item = item {
            self.delegate?.itemSelected(item)
        }
    }
}

class ProjectDetailsTableViewController: UITableViewController, MultiProjectImageCollectionDelegate {
    
    var numImages = 0
    var numItems = 0
    var appendNewImage = false
    
    weak var projectDelegate: ProjectDetailsDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    var project:VisualizerProject? {
        get {
            return VisualizerProject.currentProject
        }
        set {
            if let project = newValue {
                VisualizerProject.currentProject = project
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numImages = (self.project?.images.count ?? 0)
        numItems = (self.project?.currentImage?.assets.count ?? 0)
        
        if (section == 0) {
            return 1
        } else {
            return numItems
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 && numItems > 0 {
            return tableView.dequeueReusableCell(withIdentifier: "AssetHeader")?.contentView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultiProjectImageTableViewCell", for: indexPath) as? MultiProjectImageTableViewCell else {
                fatalError("Couldn't find MultiProjectImageTableViewCell")
            }
            
            cell.delegate = self
            cell.project = self.project
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell", for: indexPath) as? AssetTableViewCell else {
                fatalError("Couldn't find AssetTableViewCell")
            }
            let index = (indexPath as NSIndexPath).row
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self.projectDelegate
            cell.item = self.project?.currentImage?.assets[index].getItem()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 340
        } else {
            return 100
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? AssetTableViewCell {
            let item = currentCell.item
            projectDelegate?.itemSelected(item!)
        }
    }
    
    func addProjectClicked(_ sender: AnyObject, project:VisualizerProject) {
        VisualizerProject.currentProject = project
        VisualizerProject.currentProject.currentImage = nil
        self.appendNewImage = true
        performSegue(withIdentifier: "showPainter", sender: self)
    }
    
    func projectImageSelected(_ sender: AnyObject, image:VisualizerImage) {
        VisualizerProject.currentProject = image.project!
        VisualizerProject.currentProject.currentImage = image
        self.appendNewImage = false
        performSegue(withIdentifier: "showPainter", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ARViewController {
            if let imagePath = VisualizerProject.currentProject.currentImage?.directoryPath?.path {
                vc.imagePath = imagePath
            }
        }
    }
    
    func projectImageDeleted(_ sender: AnyObject, image:VisualizerImage) {
        self.deleteCurrentImage()
    }
    
    func projectImageScrolled(_ sender: AnyObject, image:VisualizerImage) {
        VisualizerProject.currentProject.currentImage = image
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    func deleteCurrentImage() {
        guard let project = self.project else {
            return;
        }
        
        confirmAction(self, text: "Are you sure you want to delete this image?") {
            if let image = project.currentImage {
                image.deleteImage()
                
                self.tableView.reloadData()
            }
        }
    }
}

class ProjectDetailsViewController: UIViewController, ProjectDetailsDelegate {
    
    var projectDetailsTable: ProjectDetailsTableViewController?
    weak var bottomSheet:BottomColorSheet!
    internal func categorySelected(_ sender: AnyObject, category: BrandCategory) {
    }
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var project: VisualizerProject = VisualizerProject.currentProject
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.project.name
        self.projectDetailsTable?.tableView.reloadData()
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.stopUsingTransparentNavigationBar()
        self.navigationController?.navigationBar.barTintColor = appColor
        self.navigationController?.navigationBar.backgroundColor = appColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = CustomBackButton.createWithText(text: "Back",
                                                                            color: UIColor.black,
                                                                            target: self,
                                                                            action: #selector(self.backPressed))
    }

    
    @objc func backPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBottomSheet()
    }

    
    func setupBottomSheet() {
        let sheetStoryboard = UIStoryboard(name: "BottomColorSheet", bundle: nil)
        bottomSheet = sheetStoryboard.instantiateViewController(withIdentifier: "BottomColorSheet") as! BottomColorSheet
        addChild(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.view.isHidden = true
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectDetailsTableViewController {
            vc.projectDelegate = self
        }
    }
    
    func itemSelected(_ item: BrandItem) {
        self.bottomSheet.item = item
        self.bottomSheet.show(true)
    }

    
    @IBAction func editProjectAction() {
        
        let optionMenu = UIAlertController(title: nil, message: "Project Changes", preferredStyle: .actionSheet)

        let shareAction = UIAlertAction(title: "Share Image", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.project.shareAction(self, button: self.editBarButton)
        })
        
        let renameAction = UIAlertAction(title: "Rename Project", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.project.renameAlert(self, handler: { (success) in
                if (success) {
                    self.title = self.project.name
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: "Delete Project", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            confirmAction(self, text: "Are you sure you want to delete this project?", completion: {
                self.project.deleteProject({
                    self.performSegue(withIdentifier: "showProjects", sender: self)
                })
            })
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(renameAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        presentActionSheet(optionMenu, viewController: self, button: editBarButton)
    }
}
