//
//  PainterViewController.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

protocol sharedFavoritesDelegate: NSObjectProtocol {
    func updateFavorites(_ item: BrandItem);
}

class ARViewController: UIViewController, WheelDelegate, ToolDelegate, AssetDelegate, CBRemodelingViewDelegate, sharedFavoritesDelegate {

    @IBOutlet weak var augmentedView: CBRemodelingView!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var toolButton: UIButton!
    
    @IBOutlet weak var assetsButton: RoundButton!
    @IBOutlet weak var layersContainer: AlphaTouchableView!
    
    @IBOutlet weak var cameraControls: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var reshootButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    var doneButton = UIBarButtonItem()
    //@IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var wheelContainer: UIView!
    @IBOutlet weak var floatingItemButton: FloatingItemButton!
    @IBOutlet weak var wheelShowHideButton:UIButton!
    @IBOutlet weak var wheelToBottom: NSLayoutConstraint!
    @IBOutlet weak var cameraControlsHeight: NSLayoutConstraint!
    @IBOutlet weak var favoritesButton: FavoritesButton!
    
    var wheel:SelectorWheel!
    weak var bottomSheet: BottomColorSheet!
    weak var assetsVC: AssetsViewController?
    weak var tools: ToolsViewController?
    
    var isLiveView = false {
        didSet {
            self.navigationItem.rightBarButtonItem?.isEnabled = !isLiveView
        }
    }
    
    var selectedItem:BrandItem? {
        didSet {
            if let item = selectedItem {
                self.floatingItemButton.item = item
                self.favoritesButton.item = item
                self.bottomSheet.item = item
                self.wheel.selectedItem = item
            }
        }
    }
    
    var callLayout = true
    
    var hasVideoCamera = ImageManager.sharedInstance.hasCameraDevice()
    var image = VisualizerImage()
    var rawImage: UIImage? = nil
    var imagePath: String? = nil
    
    
    /************************
     *
     *  INITIALIZING
     *
     *///////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWheel()
        
        floatingItemButton.item = self.selectedItem
        
        self.favoritesButton.isHidden = true
        
        self.augmentedView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = CustomBackButton.createWithText(text: "Back",
                                                                            color: UIColor.black,
                                                                            target: self,
                                                                            action: #selector(self.backPressed))

        
        self.doneButton = UIBarButtonItem(title: "Done",
                                          style: UIBarButtonItem.Style.done,
                                          target: self,
                                          action: #selector(self.donePressed))
        self.doneButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.doneButton
        
        applyPlainShadow(self.wheelShowHideButton, offset:CGSize(width:0, height:3), radius: 3, opacity: 0.7)
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.useTransparentNavigationBar()
        
        Favorites.sharedInstance.delegate = self
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupWheel() {
        self.wheel = SelectorWheel()
        let height:CGFloat = 125
        let frame = CGRect(x: 0, y: self.wheelContainer.frame.height - height, width: self.view.frame.width, height: height)
        self.wheel.frame = frame
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.showWheel(true)
        }
        
        self.wheel.delegate = self
        self.wheel.setupInitialRing()
        self.wheelContainer.addSubview(wheel)
    }
    
    
    func setupBottomSheet() {
        let sheetStoryboard = UIStoryboard(name: "BottomColorSheet", bundle: nil)
        bottomSheet = sheetStoryboard.instantiateViewController(withIdentifier: "BottomColorSheet") as! BottomColorSheet
        addChild(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.view.isHidden = true
    }
    
    func swipeWheel(gesture: UIGestureRecognizer) {
        showWheel(false)
    }
    
    func setupTools() {
        let visualizerStoryboard = UIStoryboard(name: "Visualizer", bundle: nil)
        self.tools = visualizerStoryboard.instantiateViewController(withIdentifier: "Tools") as? ToolsViewController
        if let tools = tools {
            addChild(tools)
            self.view.addSubview(tools.view)
            tools.pos = CGPoint(x: toolButton.frame.minX, y: toolButton.frame.maxY + 10)
            tools.isLiveMode = isLiveView
        }
        self.tools?.delegate = self
    }
    
    func setupAssetVC() {
        let visualizerStoryboard = UIStoryboard(name: "Visualizer", bundle: nil)
        self.assetsVC = visualizerStoryboard.instantiateViewController(withIdentifier: "Layers") as? AssetsViewController
        if let assetsVC = assetsVC {
            addChild(assetsVC)
            assetsVC.view.frame = CGRect(x: assetsButton.frame.minX, y: assetsButton.frame.maxY + 10, width: assetsButton.frame.width, height: assetsButton.frame.width * 4)
            
            self.view.addSubview(assetsVC.view)
            assetsVC.delegate = self
            assetsVC.isSample = (self.augmentedView.scene as CBRemodelingScene).isMasked
            assetsVC.setup(image: image)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
  
        if let rawImage = self.rawImage {
            print("loading image")
            if let scene = CBRemodelingScene(uiImage: rawImage) {
                self.augmentedView.scene = scene
                enableLiveView(false)
            }
        } else if let imagePath = self.imagePath {
            print("loading image from path")
            if let scene = CBRemodelingScene(path: imagePath) {
                self.augmentedView.scene = scene
                enableLiveView(false)
            }
        } else if hasVideoCamera {
            enableLiveView(true)
        }
        let scene = self.augmentedView.scene
        image = VisualizerImage.getImage(scene.sceneID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if callLayout {
            setupBottomSheet()
            setupAssetVC()
            setupTools()
            self.callLayout = false
        }
        
    }
    
    @objc func backPressed() {
        if tools?.isActive == true {
            tools?.finish()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func historyChanged(_ change: CBUndoChange, assetID: String, userData: [String : String], forward: Bool) {
        switch change {
            case .mask:
                print("something was (drawn/undrawn)")
                break;
            case .paintColor:
                if(!forward) {
                    self.undoResult(assetID, userData: userData)
                }
                print("paint color was changed")
                break
            case .paintSheen:
                break
        }
    }
    
    func enableLiveView(_ isEnabled:Bool) {
        isLiveView = isEnabled
        
        if (!hasVideoCamera) { isLiveView = false }
        self.tools?.isLiveMode = isLiveView
        
        if (isLiveView) {
            print("starting live mode")
            setToolMode(.fill);
            ImageManager.sharedInstance.proceedWithCameraAccess(self, handler: {
                //Gained camera access
                self.augmentedView.startRunning()
            })
            self.captureButton.isHidden = false
        } else {
            print("starting still mode")
            setToolMode(.paintbrush);
            self.cameraControls.isHidden = true
            wheelContainer.isHidden = false
            self.tools?.setToolColors(self.tools?.brushButton.imageView)
        }
    }
    
    
    /************************
     *
     *    ASSETS
     *
     *///////////////////////
    
    
    func appendFloor(_ floor: CBRemodelingFloor) {
        self.augmentedView.scene.appendAsset(floor)
    }
    
    func appendPaint(_ paint: CBRemodelingPaint) {
        self.augmentedView.scene.appendAsset(paint)
    }
    
    func removeAsset(_ asset: Asset) {
        if let asset = self.augmentedView.scene.assets[asset.assetID] {
            if self.augmentedView.scene.removeAsset(asset.assetID) {
                print("deleted asset with ID \(asset.assetID)")
            } else {
                print("failed to delete")
            }
        }
    }
    
    func assetSelected(_ asset: Asset) {
        self.selectedItem = asset.item
        if let selected = self.augmentedView.scene.assets[asset.assetID] {
            self.augmentedView.scene.selectedAsset = selected
        }
    }
    
    func assetUpdated(_ asset: Asset) {
        self.selectedItem = asset.item
        if let item = asset.item {
            if item.isFlooring {
                if let floor = self.augmentedView.scene.selectedFloor {
                    floor.path = item.getAssetPath().path
                    floor.scale = item.scale
                    floor.setUserData("ID", value: item.itemID)
                }
            } else {
                if let paint = self.augmentedView.scene.selectedPaint {
                    paint.color = item.color
                    paint.setUserData("ID", value: item.itemID)
                }
            }
        }
    }
    
    func undoResult(_ assetID: String, userData: [String: String]) {
        self.assetsVC?.undo(assetID, userData: userData)
    }
    
    func wheelItemSelected(_ item:BrandItem) {
        assetsVC?.selectedItem(item)
    }
    
    
    /************************
     *
     *       LISTENERS
     *
     *///////////////////////
    
    

    @objc func donePressed() {
        let project = VisualizerProject.currentProject
        displayProgress("saving...", progress: 0.0)
        project.appendImage(image: image)
        let path = image.directoryPath!.path
        image.markModified()
        self.augmentedView.scene.save(toDirectory: path, compressed: false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.performSegue(withIdentifier: "showDetails", sender: self)
            self.augmentedView.stopRunning()
            hideProgress()
        }
    }
    
    
    @IBAction func floatingItemButtonPressed(_ sender: Any) {
        self.view.bringSubviewToFront(bottomSheet.view)
        //self.assetsVC?.view.isHidden = true
        self.bottomSheet.show(true)
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        self.augmentedView.undo();
    }
    
    @IBAction func assetsButtonPressed() {
        self.assetsVC?.view.isHidden = !self.assetsVC!.view.isHidden
        self.assetsVC?.refresh()
    }
    
    @IBAction func toolPressed(_ sender: AnyObject) {
        let show = self.tools?.toolsContainer.isHidden == true
        self.tools?.showTools(show)
    }
    
    @IBAction func capturePressed(_ sender: AnyObject) {
        self.wheelContainer.isHidden = true
        
        self.reshootButton.isHidden = false
        self.confirmButton.isHidden = false
        self.captureButton.isHidden = true
        self.tools?.showTools(false)
        
        setToolMode(.none);
        
        self.augmentedView.captureCurrentState()
    }
    
    @IBAction func reshootPressed(_ sender: AnyObject) {
        self.wheelContainer.isHidden = false
        self.reshootButton.isHidden = true
        self.confirmButton.isHidden = true
        self.captureButton.isHidden = false
        
        self.enableLiveView(true)
    }
    
    @IBAction func confirmPressed(_ sender: AnyObject) {
        self.wheelContainer.isHidden = false
        self.reshootButton.isHidden = true
        self.confirmButton.isHidden = true
        self.doneButton.isEnabled = true
        self.captureButton.isHidden = false
        showWheel(true)
        enableLiveView(false)
    }
    
    @IBAction func wheelShowHideButtonPressed(_ sender: AnyObject) {
        let show = (wheelToBottom.constant < 0)
        showWheel(show)
    }
    
    
    @IBAction func favoritesPressed(_ sender: Any) {
        Favorites.sharedInstance.toggle(self.selectedItem!)
        favoritesButton.item = self.selectedItem
    }
    
    func lightingStart() -> CBLightingType{
        self.captureButton.isHidden = true
        self.assetsVC!.view.isHidden = true
        self.assetsButton.isHidden = true
        self.toolButton.isHidden = true
        self.undoButton.isHidden = true
        showWheel(false)
        self.floatingItemButton.isHidden = true
        
        return self.augmentedView.scene.lightingAdjustment
    }
    
    func toolsFinish() {
        if(isLiveView) {
            self.captureButton.isHidden = false
        }
        
        self.toolButton.isHidden = false
        self.assetsButton.isHidden = false
        self.undoButton.isHidden = false
        self.floatingItemButton.isHidden = false
    }
    
    func setToolMode(_ mode: CBToolMode) {
        print("setting tool mode")
        self.augmentedView.toolMode = mode
        
        var image: UIImage?
        switch mode {
            case .paintbrush:
                image = UIImage(named: "ic_paintbrush")
            case .eraser:
                image = UIImage(named: "ic_eraser")
            default:
                image = UIImage(named: "ic_adjustment")
        }
        self.toolButton.setImage(image, for: .normal)
        self.toolButton.imageView?.tintColor = UIColor.white
    }
    
    func setLightingMode(_ light: CBLightingType) {
        self.augmentedView.scene.lightingAdjustment = light
    }
    
    func updateFavorites(_ item: BrandItem) {
        self.selectedItem = item
        self.wheel.updateFavorites()
    }
    
    
    /************************
     *
     * VIEW STATE & ANIMATION
     *
     *///////////////////////
    
    
    func showWheel(_ show:Bool, duration: TimeInterval = 0.2) {
        print("show wheel: \(show)")
        var constant:CGFloat = 0
        var size:CGFloat = 1
        
        if(!show) {
            constant = -125
            size = -1
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.wheelToBottom.constant = constant
            self.wheelShowHideButton.transform = CGAffineTransform(scaleX: 1, y: size)
            self.view.layoutIfNeeded()
        })
    }
}
