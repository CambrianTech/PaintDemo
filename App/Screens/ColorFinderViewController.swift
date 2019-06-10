//
//  ColorFinderViewController.swift
//  HarmonyApp
//
//  Created by Joel Teply on 4/17/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import UIKit

class ColorFinderViewController: UIViewController, CBColorFinderDelegate {

    @IBOutlet weak var colorFinderView: CBColorFinderView!
    @IBOutlet weak var colorList: UIView!
    @IBOutlet weak var playPauseButton: RoundButton!
    
    private var items = [BrandItem]()
    private var colorCircles = [ColorPickCircle]()
    
    
    weak var bottomSheet: BottomColorSheet!
    
    var live: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.colorFinderView.delegate = self
        
        for i in (0..<5) {
            let colorCircle = ColorPickCircle()
            colorCircle.tag = i
            colorCircle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.circleMoved(_:))))
            colorCircles.append(colorCircle)
            self.colorFinderView.addSubview(colorCircle)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ImageManager.sharedInstance.proceedWithCameraAccess(self, handler: {
            //Gained camera access
            self.colorFinderView.startRunning()
        })
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.useTransparentNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBottomSheet()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func colorsFound(_ results: [CBColorResult]) {
        foundColors(results: results, offset: self.colorFinderView.frame.origin)
    }
    
    @IBAction func playPausePressed(_ sender: Any) {
        
        if(live) {
            self.colorFinderView.captureCurrentState()
            playPauseButton.imageView?.image = UIImage(named: "ic_video")
        } else {
            self.colorFinderView.startRunning()
            playPauseButton.imageView?.image = UIImage(named: "ic_camera")
        }
        live = !live
    }
    
    var busyUpdating = false;
    
    @objc func circleMoved(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if (busyUpdating) {
            return
        }
        
        busyUpdating = true
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            if let color = self.colorFinderView.getColorAt(sender.view!.center), let colorView = sender.view as? ColorPickCircle {
                colorView.backgroundColor = color
                colorView.setColor(color)
                
                DispatchQueue.main.async {
                    if let item = BrandItem.getClosestMatch(color, range:100) {
                        
                        let index = colorView.tag
                        colorView.setColor(item.color)
                        self.items[index] = item
                        self.colorList.subviews[index].backgroundColor = item.color
                        //print("match: \(item.name)")
                        
                        self.busyUpdating = false
                    }
                }
            }
        }
    }
    
    @objc func colorClicked(_ sender: UITapGestureRecognizer) {
        if let colorView = sender.view {
            let item = items[colorView.tag]
            updateBottomSheet(item)
        }
    }
    
    func setupBottomSheet() {
        let sheetStoryboard = UIStoryboard(name: "BottomColorSheet", bundle: nil)
        bottomSheet = sheetStoryboard.instantiateViewController(withIdentifier: "BottomColorSheet") as! BottomColorSheet
        addChild(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.view.isHidden = true
    }
    
    func updateBottomSheet(_ item: BrandItem) {
        self.bottomSheet.item = item
        self.bottomSheet.show(true)
    }

/*
    //doesn't do item matches, just displays found colors
    func foundColors(results: [CBColorResult], offset:CGPoint) {
        
        self.colorList.subviews.forEach({$0.removeFromSuperview()})
        var pos = 0
        
        for index in self.colorCircles.indices {
            let circle = colorCircles[index]
            let result = results[index]
            
            print("updating circle at index \(index)")
            circle.update(color: result.color, position: result.position, offset: offset)
            
            
            let width = Int(self.colorList.frame.width) / Int(results.count)
            let view = UIView(frame: CGRect(x: pos, y: 0, width: width, height: Int(self.colorList.frame.height)))
            view.backgroundColor = result.color
            self.colorList.addSubview(view)
            pos += width
        }
    }
*/
    
    func foundColors(results: [CBColorResult], offset:CGPoint) {
        
        self.colorList.subviews.forEach({$0.removeFromSuperview()})
        self.items.removeAll()
        
        var matches = [CBColorResult]()
        for result in results {
            if let item = BrandItem.getClosestMatch(result.color) {
                print("match: \(item.name)")
                self.items.append(item)
                matches.append(result)
            }
        }
        
        for index in self.colorCircles.indices {
            let circle = colorCircles[index]
            
            if index < matches.count {
                let match = matches[index]
                print("updating circle at index \(index)")
                circle.update(color: self.items[index].color, position: match.position, offset: offset)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    circle.alpha = 0
                })
            }
        }
        
        var pos = 0
        
        for i in self.items.indices {
            let width = Int(self.colorList.frame.width) / Int(self.items.count)
            let view = UIView(frame: CGRect(x: pos, y: 0, width: width, height: Int(self.colorList.frame.height)))
            view.tag = i
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.colorClicked(_:))))
            view.backgroundColor = self.items[i].color
            self.colorList.addSubview(view)
            pos += width
        }
    }
}
