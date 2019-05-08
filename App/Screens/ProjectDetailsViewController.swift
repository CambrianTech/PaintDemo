//
//  ProjectDetailsViewController.swift
//  HarmonyApp
//
//  Created by Jaremy Longley on 10/20/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher

protocol ProjectDetailsDelegate : NSObjectProtocol {
    func itemSelected(_ item:BrandItem)
}

class ProjectDetailsViewController: UIViewController, ProjectDetailsDelegate, ScrollDelegate {
    var scrollIndex = 0
    var itemsViewController: ProjectItemsCollectionViewController?
    weak var bottomSheet:BottomColorSheet!
    internal func categorySelected(_ sender: AnyObject, category: BrandCategory) {
    }
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var project: VisualizerProject = VisualizerProject.currentProject
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.project.name
        
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
        self.navigationController?.popViewController(animated: true)
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBottomSheet()
    }
    
    
    func setupBottomSheet() {
        let sheetStoryboard = UIStoryboard(name: "BottomColorSheet", bundle: nil)
        bottomSheet = sheetStoryboard.instantiateViewController(withIdentifier: "BottomColorSheet") as! BottomColorSheet
        addChildViewController(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.view.isHidden = true
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProjectContainerCollectionViewController {
            vc.projectCollectionScrollDelegate = self
            print(self.scrollIndex)
            vc.scrollIndex = self.scrollIndex
        }
        if let itemsVC = segue.destination as? ProjectItemsCollectionViewController {
            self.itemsViewController = itemsVC
            itemsVC.projectDelegate = self
        }
    }
    
    func itemSelected(_ item: BrandItem) {
        self.bottomSheet.item = item
        self.bottomSheet.show(true)
    }
    
    func projectImageScrolled(indexPath: IndexPath) {
        print("IndexPath Scrolled: \(indexPath.item)")
        self.itemsViewController?.projectImageScrolled()
    }
    
    @IBAction func editProjectAction() {
        
        let optionMenu = UIAlertController(title: nil, message: "Project Changes", preferredStyle: .actionSheet)
        
        let shareImageAction = UIAlertAction(title: "Share Image", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.project.shareImageAction(self, button: self.editBarButton)
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
        
        optionMenu.addAction(shareImageAction)
        optionMenu.addAction(renameAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        presentActionSheet(optionMenu, viewController: self, button: editBarButton)
    }
}














