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
import JGProgressHUD

protocol sharedFavoritesDelegate: NSObjectProtocol {
    func updateFavorites(_ item: BrandItem);
}

class ARViewController: UIViewController, WheelDelegate, ToolDelegate, AssetDelegate, CBRemodelingViewDelegate {
    
    

    @IBOutlet weak var augmentedView: CBRemodelingView!
    
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var moreButtonContainer: UIView!
    @IBOutlet weak var moreButton: RoundButton!
    @IBOutlet weak var assetsButton: RoundButton!
    @IBOutlet weak var toolsButton: RoundButton!
    @IBOutlet weak var layersContainer: AlphaTouchableView!
    
    @IBOutlet weak var cameraControls: UIView!
    @IBOutlet weak var captureButton: UIButton!
    var rightButton = UIBarButtonItem()
    var favoritesBarButton = UIBarButtonItem()
    var cartBarButton = UIBarButtonItem()
    var backButton = UIBarButtonItem()
    //@IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var wheelContainer: UIView!
    @IBOutlet weak var floatingItemButton: FloatingItemButton!
    @IBOutlet weak var wheelShowHideButton:UIButton!
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var wheelToBottom: NSLayoutConstraint!
    @IBOutlet weak var cameraControlsHeight: NSLayoutConstraint!
    @IBOutlet weak var favoritesButton: FavoritesButton!
    
    var wheel:SelectorWheel!
    weak var bottomSheet: BottomColorSheet!
    weak var bottomSearch: SearchBottomSheet!
    weak var assetsVC: AssetsViewController?
    weak var tools: ToolsViewController?
    @IBOutlet weak var assetContainer: AlphaTouchableView!
    
    var isLandscape = false
    var hasCreatedFloor = false
    var hasPainted = false
    
    let defaults = UserDefaults.standard
    
    var isLiveView = false {
        didSet {
            self.toggleRightButton()
        }
    }
    
//    var isPainted = false {
//        didSet {
////            self.rightButton.isEnabled = isPainted
//        }
//    }
    
    var sentItem:BrandItem?
    
    var selectedItem:BrandItem? {
        didSet {
            if let item = selectedItem {
                self.floatingItemButton.item = item
                self.bottomSheet.item = item
                self.wheel.selectedItem = item
            }
        }
    }
    
    let screen = UIScreen.main.bounds
    var callLayout = true
    
    var hasVideoCamera = ImageManager.sharedInstance.hasCameraDevice()
    var image = VisualizerImage()
    var rawImage: UIImage? = nil
    var imagePath: String? = nil
    var incomingSharedProject: Bool? = false
    
    /************************
     *
     *  INITIALIZING
     *
     *///////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLandscape = UIDevice.current.userInterfaceIdiom == .pad
        
        moreButton.isHidden = true
        setupWheel()
        
        floatingItemButton.item = self.selectedItem
        
        self.augmentedView.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.rightButton = UIBarButtonItem(title: "",
                                           style: UIBarButtonItemStyle.done,
                                           target: self,
                                           action: #selector(self.rightButtonPressed))
        self.navigationItem.setRightBarButtonItems([self.rightButton],
                                                   animated: false)
        
        applyPlainShadow(self.wheelShowHideButton, offset:CGSize(width:0, height:3), radius: 3, opacity: 0.7)
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.useTransparentNavigationBar()
        
        self.undoButton.isEnabled = true
        self.rightButton.isEnabled = true
        
        navigationItem.leftBarButtonItems = nil
        self.backButton = UIBarButtonItem(title: "Back",
                                          style: UIBarButtonItemStyle.done,
                                          target: self,
                                          action: #selector(self.backPressed))
        navigationItem.setLeftBarButton(self.backButton,
                                        animated: false)
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupWheel() {
        self.wheel = SelectorWheel()
    
        wheel.isLandscape = self.isLandscape
        let height:CGFloat = 125
        var width = screen.width
        var x:CGFloat = 0
        if(isLandscape) {
            width = screen.width * 0.66
            x = screen.width * 0.166
        }
        let frame = CGRect(x: x, y: self.wheelContainer.frame.height - height, width: width, height: height)
        self.wheel.frame = frame

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.showWheel(true)
        }
        
        self.wheel.delegate = self
        self.wheel.setupInitialRing()
        self.wheelContainer.addSubview(self.wheel)
    }
    
    func setupMoreButton() {
        
        self.moreButton.frame = self.moreButtonContainer.bounds
        self.moreButtonContainer.addSubview(moreButton)
        moreButton.isHidden = false
    }
    
    func setupBottomSheet() {
        let sheetStoryboard = UIStoryboard(name: "BottomColorSheet", bundle: nil)
        bottomSheet = sheetStoryboard.instantiateViewController(withIdentifier: "BottomColorSheet") as! BottomColorSheet
        addChildViewController(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.view.isHidden = true
        if (getTargetName() == "Builder") {
            bottomSheet.favoritesButton.isHidden = true
        }
    }
    
    func setupSearchExplore() {
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        bottomSearch = searchStoryboard.instantiateViewController(withIdentifier: "bottomSearchSheet") as! SearchBottomSheet
        addChildViewController(bottomSearch)
        self.view.addSubview(bottomSearch.view)
        bottomSearch.view.isHidden = true
    }
    
    func swipeWheel(gesture: UIGestureRecognizer) {
        showWheel(false)
    }
    
    func setupTools() {
        let visualizerStoryboard = UIStoryboard(name: "Visualizer", bundle: nil)
        self.tools = visualizerStoryboard.instantiateViewController(withIdentifier: "Tools") as? ToolsViewController
        self.view.layoutIfNeeded()
        if let tools = tools {
            addChildViewController(tools)
            self.view.addSubview(tools.view)
            tools.showTools(false)
            if (getTargetName() == "Builder") {
                toolsButton.frame = CGRect(x: self.moreButtonContainer.frame.minX, y: self.moreButton.frame.maxY + (self.moreButton.frame.height + 8), width: self.moreButton.frame.width, height: self.moreButton.frame.height)
            }
            tools.pos = CGPoint(x: toolsButton.frame.minX - tools.toolsContainer.frame.width - 10, y: toolsButton.frame.minY)
            tools.isLiveMode = isLiveView
        }
        self.tools?.delegate = self
    }
    
    func setupAssetVC() {
        let visualizerStoryboard = UIStoryboard(name: "Visualizer", bundle: nil)
        self.assetsVC = visualizerStoryboard.instantiateViewController(withIdentifier: "Layers") as? AssetsViewController
        if let assetsVC = assetsVC {
            addChildViewController(assetsVC)
            assetsVC.view.frame = CGRect(x: assetContainer.frame.width, y: 0, width: assetContainer.frame.width, height: assetContainer.frame.height)
            assetsVC.view.isHidden = true
            //self.view.addSubview(assetsVC.view)
            assetContainer.addSubview(assetsVC.view)
            assetsVC.delegate = self
            assetsVC.maxAssets = 4
            assetsVC.isSample = (self.augmentedView.scene as CBRemodelingScene).isMasked
            assetsVC.setup(image: image)
        }
        
        if (getTargetName() == "Builder") {
            self.assetsButton.isHidden = true
            self.assetsButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
  
        if let rawImage = self.rawImage {
            //print("loading image")
            if let scene = CBRemodelingScene(uiImage: rawImage) {
                self.augmentedView.scene = scene
                enableLiveView(false)
            }
        } else if let imagePath = self.imagePath {
            //print("loading image from path")
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if callLayout {
            self.setupMoreButton()
            self.setupBottomSheet()
            
            self.setupAssetVC()
            
            if let sentItem = self.sentItem {
                print(sentItem.name)
                self.selectedItem = sentItem
                assetsVC?.selectedItem(sentItem)
                self.sentItem = nil
            }
            self.maybeShowTutorial("Detail")
            self.setupTools()
            
            if (getTargetName() == "Builder") {
                undoButton.frame = CGRect(x: self.toolsButton.frame.minX, y: self.toolsButton.frame.maxY + 8, width: self.toolsButton.frame.width, height: self.toolsButton.frame.height)
            }
            self.callLayout = false
        }
    }
    
    @objc func backPressed() {
            // Does a check to see if the imagePath is null, if it is an image coming
            // from a path then it can't enter back into live view
            // Or checks if the raw image is null, if not then the image
            // came from the user's gallery
            if let imagePath = self.imagePath {
                self.augmentedView.stopRunning()
                self.navigationController?.popViewController(animated: true)
            } else if let rawImage = self.rawImage {
                self.augmentedView.stopRunning()
                self.navigationController?.popViewController(animated: true)
            } else {
                if (!self.isLiveView) {
                    self.enableLiveView(true)
                } else {
                    self.augmentedView.stopRunning()
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    @objc func cancelPressed() {
        if tools?.isActive == true {
            tools?.cancelPressed()
            tools?.finish()
        }
    }
    
    //for:change:forward:
    func historyChanged(_ asset: CBAugmentedAsset, change: CBUndoChange, forward: Bool) {
        switch change {
            case .mask:
                //print("something was (drawn/undrawn)")
                if (self.selectedItem?.type == .floor) == true {
                    self.hasCreatedFloor = true
                    self.maybeShowTutorial("Rotation")
                } else if (self.selectedItem?.type == .paint) == true {
                    self.hasPainted = true
                    self.maybeShowTutorial("Detail")
                }
                break;
            case .paintColor:
                if(!forward) {
                    self.undoResult(asset)
                }
                //print("paint color was changed")
                break
            case .paintSheen:
                break
        }
        self.undoButton.isEnabled = self.augmentedView.undoSize > 0
    }
    
    func assetLongPressed(_ asset: CBAugmentedAsset) {
        self.assetsVC?.removeAsset(asset.assetID)
    }
    
    func assetTapped(_ asset: CBAugmentedAsset) {
        if let model = asset as? CBAugmentedModel {
            model.isEditingPosition = !model.isEditingPosition
        }
    }
    
    func enableLiveView(_ isEnabled:Bool) {
        isLiveView = isEnabled
        
        if (!hasVideoCamera) { isLiveView = false }
        self.tools?.isLiveMode = isLiveView
        if(incomingSharedProject!) {
            isLiveView = false
            self.incomingSharedProject = false
        }
        
        if (isLiveView) {
            //print("starting live mode")
            setToolMode(.fill);
            ImageManager.sharedInstance.proceedWithCameraAccess(self, handler: {
                //Gained camera access
                self.augmentedView.startRunning()
                
            })
            self.captureButton.isHidden = false
        } else {
            //print("starting still mode")
            setToolMode(.paintbrush);
            self.cameraControls.isHidden = true
            wheelContainer.isHidden = false
            self.tools?.setToolColors(.paintbrush)
            self.tools?.brushButton.isHidden = true
            self.tools?.eraserButton.isHidden = true
            self.maybeShowTutorial("Detail")
        }
    }
    
    func maybeShowItemTutorial(_ item:BrandItem) {
        if (item.type == .paint) {
            maybeShowTutorial("Paint")
        } else if (item.type == .floor) {
            maybeShowTutorial("Floor")
        } else {
            maybeShowTutorial("Model")
        }
    }
    
    func hasSeenTutorial(_ tutorial: String) -> Bool {
        let settingsKey = "hasSeen\(tutorial)Tutorial"
        
        return defaults.bool(forKey: settingsKey)
    }
    
    func setHasSeenTutorial(_ tutorial: String) {
        let settingsKey = "hasSeen\(tutorial)Tutorial"
        
        defaults.set(true, forKey: settingsKey)
        defaults.synchronize()
    }
    
    func maybeShowTutorial(_ tutorial: String) {
        
        if (hasSeenTutorial(tutorial)) {
            return
        }
        
        let hud = JGProgressHUD(style: .dark) 
        hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "ic_tap")!)
        
        switch tutorial {
        case "Rotation":
            if ((self.selectedItem?.type == .floor) == false || !self.hasCreatedFloor) {
                return
            }
            hud.textLabel.text = "Rotate flooring by twisting with two fingers"
            hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "ic_rotate")!)
        case "Detail":
            if (self.isLiveView || self.selectedItem?.type == .paint || !self.hasPainted) {
                return
            }
            hud.textLabel.text = "Draw or erase areas that require further detail"
            break
        case "Paint":
            hud.textLabel.text = "Tap on a wall to apply a color"
            break
        case "Floor":
            hud.textLabel.text = "Tap on the floor"
            break
        case "Model":
            hud.textLabel.text = "Tap on the floor to place model"
            break
        default:
            return
        }
        
        hud.show(in: self.view)
        hud.tapOutsideBlock = { hud in
            hud.dismiss()
        }
        hud.tapOnHUDViewBlock = { hud in
            hud.dismiss()
        }
        hud.dismiss(afterDelay: 3.0)
        
        setHasSeenTutorial(tutorial)
    }
    
    /************************
     *
     *    ASSETS
     *
     *///////////////////////
    
    func newCBAugmentedAsset(_ itemType:CBAssetType, _ assetID:String) -> CBAugmentedAsset? {
        
        if (!self.augmentedView.scene.canAppendAsset(itemType)) {
            return nil
        }
        
        switch itemType {
            case .paint:
                return CBRemodelingPaint(assetID: assetID)
            case .floor:
                return CBRemodelingFloor(assetID: assetID)
            case .model:
                return CBRemodelingFurniture(assetID: assetID)
            default:
                return nil
        }
    }
    
    func existingCBAugmentedAsset(_ asset:Asset) -> CBAugmentedAsset? {
        //print("Looking up asset with ID \(asset.assetID)")
        guard let existingCBAsset = self.augmentedView.scene.assets[asset.assetID] else {
            return nil
        }
        return existingCBAsset
    }
    
    func appendCBAugmentedAsset(_ asset:CBAugmentedAsset) {
        //print("Appending asset with ID \(asset.assetID)")
        self.augmentedView.scene.appendAsset(asset)
    }

    func replaceCBAugmentedAsset(_ cbAsset: CBAugmentedAsset, _ forAsset:Asset) {
        self.augmentedView.scene.removeAsset(forAsset.assetID)
        self.augmentedView.scene.appendAsset(cbAsset)
    }
    
    func removeAsset(_ asset: Asset) {
        if let asset = self.augmentedView.scene.assets[asset.assetID] {
            if self.augmentedView.scene.removeAsset(asset.assetID) {
                print("Deleted asset with ID \(asset.assetID)")
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
        if let item = asset.item, let selectedAsset = self.augmentedView.scene.selectedAsset {
            if let floor = selectedAsset as? CBRemodelingFloor, item.type == .floor {
                floor.setPath(item.assetPath, scale: item.scale)
            } else if let paint = selectedAsset as? CBRemodelingPaint, item.type == .paint {
                paint.color = item.color
            } else if let furniture = selectedAsset as? CBRemodelingFurniture {
                furniture.setPath(item.assetPath, scale: item.scale)
            }
            
            self.selectedItem = asset.item
            selectedAsset.setUserData("ID", value: item.id)
//            favoritesButton.tintColor = item.isInFavorites ? UIColor.red : UIColor.white
        }
    }
    
    func undoResult(_ asset:CBAugmentedAsset) {
        self.assetsVC?.undo(asset)
    }
    
    func wheelItemSelected(_ item:BrandItem) {
        let callback = {
            hideProgress()
            self.maybeShowItemTutorial(item)
            self.assetsVC?.selectedItem(item)
        }
        
        if item.hasThumbnail == false {
            callback()
        } else {
            item.downloadAssets(completed: { (success) in
                if (success) {
                    callback()
                } else {
                    //show unavailable
                    displayError(message: "Asset is unavailable")
                }
            })
        }
    }
    
    func getSelectedItem() -> BrandItem {
        return self.selectedItem!
    }
    
    /************************
     *
     *       LISTENERS
     *
     *///////////////////////

    @objc func rightButtonPressed() {
        if (!isLiveView) {
            let project = VisualizerProject.currentProject
            displayProgress("saving project...", progress: 0.0)
            project.appendImage(image: image)
            let path = image.directoryPath!.path
            print("TAKEN IMAGE PATH \(path) ")
            image.markModified()
            self.augmentedView.scene.save(toDirectory: path, compressed: false) {_ in
                self.performSegue(withIdentifier: "showDetails", sender: self)
                self.augmentedView.stopRunning()
                hideProgress()
            }
            
        } else {
//            self.rightButton.isEnabled = false
        }
    }
    
    @objc func applyPressed() {
        if tools?.isActive == true {
            tools?.applyPressed()
            tools?.showTools(true)
            tools?.finish()
        }
    }
    
    func cartPressed() {
        if let name = self.selectedItem?.name {
            displayMessage("added \(name) to cart", isSuccess: true)
        }
    }
    
    func displayEditable() {
        displayMessage("You are now able to edit the shared project")
    }
    
    
    @IBAction func floatingItemButtonPressed(_ sender: Any) {
        self.view.bringSubview(toFront: bottomSheet.view)
        //self.assetsVC?.view.isHidden = true
        self.bottomSheet.show(true)
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        self.augmentedView.undo()
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        self.showMoreMenu(self.moreButtonContainer.transform == .identity)
    }
    
    @IBAction func assetsButtonPressed() {
        self.assetsVC?.view.isHidden = !self.assetsVC!.view.isHidden
        self.assetsVC?.refresh()
    }
    
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func capturePressed(_ sender: AnyObject) {
        
        self.showMoreMenu(false)
        self.moreButton.isHidden = true
        self.wheelContainer.isHidden = true
        self.captureButton.isHidden = true
        self.cameraControls.isHidden = false
        
        setToolMode(.none);
        
        self.augmentedView.captureCurrentState()
    }
    
    @IBAction func reshootPressed(_ sender: AnyObject) {
        self.moreButton.isHidden = false
        self.showMoreMenu(false)
        self.wheelContainer.isHidden = false
        self.captureButton.isHidden = false
        self.cameraControls.isHidden = true
        
        self.enableLiveView(true)
    }
    
    
    @IBAction func toolsPressed(_ sender: Any) {
        self.tools?.toggle()
    }
    
    @IBAction func confirmPressed(_ sender: AnyObject) {
        self.moreButton.isHidden = false
        self.wheelContainer.isHidden = false
        self.cameraControls.isHidden = true
        self.rightButton.isEnabled = true
        
        showWheel(true)
        enableLiveView(false)
    }
    
    @IBAction func wheelShowHideButtonPressed(_ sender: AnyObject) {
        let show = (wheelToBottom.constant < 0)
        showWheel(show)
    }
    
    
    //pass item from color finder
    func sendItem(_ item: BrandItem) {
        self.sentItem = item
    }
    
    func toggleRightButton() {
        rightButton.title = "Save"
        rightButton.isEnabled = !isLiveView
    }
    
    
    /************************
     *
     *      TOOL HANDLING
     *
     *///////////////////////
    
    func lightingStart() -> CBLightingType {
        showMoreMenu(false)
        self.captureButton.isHidden = true
        self.assetsVC!.view.isHidden = true
        self.moreButton.isHidden = true
        showWheel(false)
        self.floatingItemButton.isHidden = true
        navigationItem.leftBarButtonItems = nil
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel",
                                                            style: UIBarButtonItemStyle.plain,
                                                            target: self,
                                                            action: #selector(self.cancelPressed)),
                                             animated: false)
        
        self.rightButton.title = "Apply"
        self.rightButton.action = #selector(self.applyPressed)
        self.rightButton.isEnabled = true

        return self.augmentedView.scene.lightingAdjustment
    }
    
    func toolsFinish() {
        if(isLiveView) {
            self.captureButton.isHidden = false
        }
        self.showMoreMenu(false)
        
        self.floatingItemButton.isHidden = false
        self.moreButton.isHidden = false
        
        navigationItem.setLeftBarButton(self.backButton, animated: false)
        self.toggleRightButton()
        self.rightButton.action = #selector(self.rightButtonPressed)
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
                image = UIImage(named: "ic_paintbrush")
        }
        self.toolsButton.setImage(image, for: .normal)
        self.toolsButton.imageView?.tintColor = UIColor.white
        
        self.showMoreMenu(false)
    }
    
    func setLightingMode(_ light: CBLightingType) {
        self.augmentedView.scene.lightingAdjustment = light
    }
    
    
    /************************
     *
     * VIEW STATE & ANIMATION
     *
     *///////////////////////
    
    
    func showWheel(_ show:Bool, duration: TimeInterval = 0.2) {
        //print("show wheel: \(show)")
        var constant:CGFloat = 0
        var size:CGFloat = 1
        
        if(!show) {
            constant = -125
            size = -1
            self.productsLabel.isHidden = false
        } else {
            self.productsLabel.isHidden = true
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.wheelToBottom.constant = constant
            self.wheelShowHideButton.transform = CGAffineTransform(scaleX: 1, y: size)
            self.view.layoutIfNeeded()
        })
    }
    
    func showMoreMenu(_ show: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            if show {
                self.moreButtonContainer.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            } else {
                self.moreButtonContainer.transform = .identity
            }
            
            self.assetsVC?.view.isHidden = true
            self.tools?.showTools(false)
            self.assetsButton.isHidden = !show
            self.toolsButton.isHidden = !show
            self.undoButton.isHidden = !show
            
            if (getTargetName() == "Builder") {
                self.assetsButton.isHidden = true
            }
            
            if(!(getTargetName() == "ShawDemo")) {
                self.favoritesButton.isHidden = !show
            }
            
            
        }) {(true) in
        }
        self.view.layoutIfNeeded()
    }
}
