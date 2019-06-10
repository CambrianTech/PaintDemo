//
//  ProjectProperties.swift
//  HomeDecoratorApp
//
//  Created by Joel Teply on 11/23/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher

import JGProgressHUD

//globals
private let s3BucketName = "sample-image-packages"
let sqFfPerExterior:Float = 400
let sqFfPerInterior:Float = 250
let doorSizeSqFt:Float = 20
let windowSizeSqFt:Float = 15


let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]


func getStoreURL(_ itemID:String) -> URL {
    return URL(string:"https://www.amazon.com/gp/product/\(itemID)?ie=UTF8&tag=prestige-ios-20")!
}

func leftChevronImage() -> UIImage? {
    if let image = UIImage(named:"ic_chevron_left") {
        return image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    }
    return nil
}

func rightChevronImage() -> UIImage? {
    if let image = UIImage(named:"ic_chevron_right") {
        return image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    }
    return nil
}

func distanceBetweenColors(_ color1:UIColor, color2:UIColor) -> CGFloat {
    let rgba1 = colorRGBA(color1)
    let rgba2 = colorRGBA(color2)
    
    //because swift sucks at compiling
    let powR = 2 * pow(rgba1[0] - rgba2[0], 2)
    let powG = 4 * pow(rgba1[1] - rgba2[1], 2)
    let powB = 3 * pow(rgba1[2] - rgba2[2], 2)
    
    return sqrt(powR + powG + powB)
}

func colorRGBA(_ color:UIColor) -> [CGFloat] {
    var fRed : CGFloat = 0
    var fGreen : CGFloat = 0
    var fBlue : CGFloat = 0
    var fAlpha: CGFloat = 0
    
    color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha);
    
    return [fRed, fGreen, fBlue, fAlpha]
}


func ensureDirectoryExists(_ path:String) -> Bool {
    if !FileManager.default.fileExists(atPath: path) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
            return false
        }
    }
    return true
}



let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.dark)
var displayingHUD = false

func displayMessage(_ message:String, isSuccess:Bool=false) {
    guard let keyWindow = UIApplication.shared.keyWindow else {
        return
    }
    
    if !displayingHUD && !(progressHUD.isVisible) {
        progressHUD.textLabel.text = message
        progressHUD.indicatorView = isSuccess ? JGProgressHUDSuccessIndicatorView() : JGProgressHUDIndicatorView()
        progressHUD.animation = JGProgressHUDFadeZoomAnimation()
    }
    
    progressHUD.show(in: keyWindow, animated: true)
    progressHUD.dismiss(afterDelay: 1.0, animated: true)
}

func displayProgress(_ message:String, progress:Float) {
    guard let keyWindow = UIApplication.shared.keyWindow else {
        return
    }
    
    if !displayingHUD && !(progressHUD.isVisible) {
        displayingHUD = true
        progressHUD.textLabel.text = message
        progressHUD.indicatorView = JGProgressHUDRingIndicatorView()
        progressHUD.animation = JGProgressHUDFadeZoomAnimation()
        
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if (displayingHUD) {
                progressHUD.show(in: keyWindow, animated: true)
            }
            displayingHUD = false
        }
    }
    
    progressHUD.progress = progress
    
    if progress == 1.0 {
        hideProgress()
    }
}

func hideProgress() {
    displayingHUD = false
    progressHUD.dismiss(afterDelay: 0.5)
}

let errorHUD = JGProgressHUD(style: JGProgressHUDStyle.dark)

func displayError(message: String) {
    guard let keyWindow = UIApplication.shared.keyWindow else {
        return
    }
    errorHUD.textLabel.text = message
    errorHUD.indicatorView = JGProgressHUDErrorIndicatorView()
    errorHUD.show(in: keyWindow)
    errorHUD.dismiss(afterDelay: 3.0)
}


func applyPlainShadow(_ view: UIView, offset:CGSize, radius:CGFloat=0, opacity:Float=0.3) {
    let layer = view.layer
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = offset
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius > 0 ? radius : max(fabs(offset.width), fabs(offset.height)/2.0)
}


let CAMBRIAN_COLOR = UIColor(red: 22/255.0, green: 167/255.0, blue: 231/255.0, alpha: 1.0)

func presentActionSheet(_ actionSheet:UIAlertController, viewController:UIViewController, button: UIBarButtonItem) {
    if let popoverController = actionSheet.popoverPresentationController {
        popoverController.barButtonItem = button
    }
    viewController.present(actionSheet, animated: true, completion: nil)
}

func presentActionSheet(_ actionSheet:UIAlertController, viewController:UIViewController, view: UIView) {
    if let popoverController = actionSheet.popoverPresentationController {
        popoverController.sourceRect = view.frame
        popoverController.sourceView = view
    }
    viewController.present(actionSheet, animated: true, completion: nil)
}

func confirmAction(_ presentingViewController:UIViewController, text:String, completion: @escaping (() -> Void)) {
    let alertController = UIAlertController(title: nil, message:
        text, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
        (alert: UIAlertAction!) -> Void in
        completion()
    }));
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
        (alert: UIAlertAction!) -> Void in
        
    }));
    
    presentingViewController.present(alertController, animated: true, completion: nil)
}


func shareProjectImage(_ presentingViewController:UIViewController, button: UIBarButtonItem, image: VisualizerImage, completion: (() -> Void)?=nil) {
    guard let imagePath = image.directoryPath?.path else {
        return
    }
    
    DispatchQueue.main.async(execute: {
        
        let baImage = CBRemodelingScene.getBeforeAfter(imagePath, isHorizontal: true)
        
        DispatchQueue.main.async(execute: {

            let renderer = ImageRenderer(image: image)
            guard let renderedImage = renderer.getRenderedImage(baImage) else {
                return
            }
            
            
            let avc = UIActivityViewController(activityItems: [renderedImage], applicationActivities:nil)

            avc.popoverPresentationController?.barButtonItem = button
            avc.completionWithItemsHandler = {
                (activity, success, items, error) in
                if let handler = completion , success {
                    handler()
                }
            }

            presentingViewController.present(avc, animated: true, completion: nil)
        })
    })
}

