//
//  File.swift
//  HarmonyApp
//
//  Created by joseph on 5/8/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

internal protocol ProjectCellDelegate : NSObjectProtocol {
    func projectSelected(_ project:VisualizerProject)
}

class ProjectCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ProjectCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var projectLabel: UILabel!
    
    weak fileprivate var delegate: ProjectCellDelegate?
    
    var project: VisualizerProject? {
        didSet {
            
            projectLabel.text = project?.name
            
            if let image = project?.currentImage {
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
        if let proj = self.project {
            self.delegate?.projectSelected(proj)
        }
    }
}

class ProjectCollectionViewController: UICollectionViewController, ProjectCellDelegate, DetailsCollectionViewDelegate {
    
    fileprivate let reuseIdentifier = "ProjectCell"
    
    weak internal var delegate: ProjectCellDelegate?
    var selectedProject: VisualizerProject?
    let visibleCount = 2
    var addButton: UIButton?
    
    fileprivate var projects: Results<VisualizerProject> {
        get {
            return VisualizerProject.latestProjects()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size:CGFloat = 60
        addButton = UIButton(frame: CGRect(x: self.view.frame.width - (size * 1.2),
                                           y: self.view.frame.height - (size * 2.3),
                                           width: size,
                                           height: size))
        
        let image = UIImage(named: "ic_add")
 
        addButton?.layer.cornerRadius = size/2
        addButton?.backgroundColor = appColor
        addButton?.imageView?.tintColor = UIColor.white
        addButton?.setImage(image, for: .normal)
        
        addButton?.layer.shadowOffset = CGSize(width: 1, height: 2)
        addButton?.layer.shadowOpacity = 0.3
        addButton?.layer.shadowColor = UIColor.black.cgColor
        addButton?.layer.shadowRadius = 3
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.addPressed))
        addButton?.addGestureRecognizer(tap)

        self.view.addSubview(addButton!)
        
        self.navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = CustomBackButton.createWithText(text: "Back",
                                                                            color: UIColor.black,
                                                                            target: self,
                                                                            action: #selector(self.backPressed))
    }
    
    
    @objc func backPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func addPressed() {
        addCollectionViewItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.stopUsingTransparentNavigationBar()
        self.navigationController?.navigationBar.barTintColor = appColor
        self.navigationController?.navigationBar.backgroundColor = appColor
        reloadData()
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let project = self.selectedProject {
            VisualizerProject.currentProject = project
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.projects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ProjectCell
            else {
                fatalError("ProjectCell expected")
        }
        
        cell.project = self.projects[(indexPath as NSIndexPath).row]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width) - 20
        let height = width * 0.75
        return CGSize(width: width, height: height)
    }
    
    func projectSelected(_ project:VisualizerProject) {
        self.selectedProject = project
        if (project.isEmpty) {
            self.performSegue(withIdentifier: "showPainter", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "projectDetails", sender: self)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let project = self.projects[(indexPath as NSIndexPath).row]
        self.projectSelected(project)
    }
    
    // MARK: DetailsCollectionViewDelegate
    func canAddCollectionViewItem() -> Bool {
        return true
    }
    
    func addCollectionViewItem() {
        VisualizerProject.currentProject = VisualizerProject.createProject()
        reloadData()
        
        VisualizerProject.currentProject.renameAlert(self, handler: { (success) in
            if (success) {
                self.editProject(VisualizerProject.currentProject)
            } else {
                VisualizerProject.currentProject.deleteProject()
                self.reloadData()
            }
        })
    }
    
    func longPressCollectionViewItem(_ indexPath:IndexPath) {
        let project = self.projects[(indexPath as NSIndexPath).row]
        
        let item = collectionView?.dequeueReusableCell(withReuseIdentifier: "ProjectCell", for: indexPath) as? ProjectCell
        
        let optionMenu = UIAlertController(title: nil, message: "Project Changes", preferredStyle: .actionSheet)
        
        let detailsAction = UIAlertAction(title: "Project Details", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.projectSelected(project)
        })
        
        let editAction = UIAlertAction(title: "See It", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.editProject(project)
        })
        
        let renameAction = UIAlertAction(title: "Rename Project", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            project.renameAlert(self, handler: { (success) in
                if (success) {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            })
        })
        
        let deleteAction = UIAlertAction(title: "Delete Project", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            confirmAction(self, text: "Are you sure you want to delete this project?", completion: {
                project.deleteProject({
                    self.reloadData()
                })
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(detailsAction)
        optionMenu.addAction(renameAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        
        presentActionSheet(optionMenu, viewController: self, view: item!)
    }
    
    /*
    func previewForCollectionViewItem(_ indexPath:IndexPath) -> UIView? {
        let imageView = UIImageView(frame: self.view.frame)
        
        let project = self.projects[(indexPath as NSIndexPath).row]
        imageView.image = project.currentImage?.thumbnail
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        return imageView
    }
    
    func detailsForCollectionViewItem(_ indexPath:IndexPath) {
        let project = self.projects[(indexPath as NSIndexPath).row]
        self.projectSelected(project)
    }
 */
    
    func editProject(_ project:VisualizerProject) {
        VisualizerProject.currentProject = project
        
        self.performSegue(withIdentifier: "showPainter", sender: self)
    }
}
