//
//  SelectorWheelRing.swift
//  Prestige
//
//  Created by Joel Teply on 7/9/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift



internal protocol SelectorWheelRingDelegate : NSObjectProtocol {
    func categorySelected(_ category:BrandCategory, ring: SelectorWheelRing) -> Bool
    func itemSelected(_ item:BrandItem, row: Int)
}

class SelectorWheelRing: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    weak internal var delegate: SelectorWheelRingDelegate?
    
    var row = 0
    var isLandscape = false
    
    let backgroundView = UIView()
    var path = UIBezierPath()
    
    var innerRadiusClipping:CGFloat = 10
    var disableDelegateCall = false
    
    var category: BrandCategory? {

        didSet {
            self.collectionView.reloadData()
            
            self.collectionView.performBatchUpdates({  }) { (completed) in
                
                let numItems = self.collectionView.numberOfItems(inSection: 0)
                if let position = self.scrollPosition {
                    self.scrollTo(position: position)
                } else {
                    self.scrollTo(position: numItems/2, animated: false)
                }
                self.scrollPosition = nil
            }
        }
    }
    
    
    var scrollPosition: Int?
    
    var outerRadius:CGFloat = 200.0 {
        didSet {
            updateLayout()
        }
    }
    var innerRadius:CGFloat = 100.0 {
        didSet {
            updateLayout()
        }
    }
    
    var itemSize:CGSize = CGSize(width: 100.0, height: 100.0) {
        didSet {
            updateLayout()
        }
    }
    
    var angleSpan:CGFloat {
        return atan(itemSize.width/self.outerRadius)
    }
    
    func updateLayout() {
        if let ringLayout = self.collectionView.collectionViewLayout as? SelectorWheelRingLayout {
            ringLayout.anglePerItem = atan(itemSize.width/self.outerRadius)
            ringLayout.innerRadius = self.innerRadius
            ringLayout.outerRadius = self.outerRadius
            ringLayout.itemSize = self.itemSize
        }
    }

    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.path.contains(point) {
            return true
        }
        return false
    }
    
    func categoryIndex(_ category:BrandCategory) -> Int? {
        return self.category?.subCategories.index(of: category)
    }
    
    func itemIndex(_ item:BrandItem) -> Int? {
        return self.category?.items.index(of: item)
    }
    
    
    
    
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: SelectorWheelRingLayout())
    fileprivate let cellReuseIdentifier = "SelectorWheelCell"
    
    var selectedCell:SelectorWheelRingCell?

    
    fileprivate func initialize() {
        
        collectionView.register(SelectorWheelRingCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.993)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        backgroundView.clipsToBounds = false
        addSubview(backgroundView)
        
        addSubview(collectionView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func drawBG() {
        
        var center:CGPoint!
        if(self.isLandscape) {
            center = CGPoint(x: self.bounds.size.width / 2.0, y: outerRadius)
        } else {
            center = CGPoint(x: self.bounds.size.width / 2.0, y: outerRadius)
        }
        
        let startAngle = -0.5 * Double.pi
        let endAngle = startAngle + 2.0 * Double.pi
        
        let clippedRadius = innerRadius + self.innerRadiusClipping
        
        let outerArcStart = CGPoint(
            x: center.x + outerRadius * CGFloat(cos(startAngle)),
            y: center.y + outerRadius * CGFloat(sin(startAngle)))
        
        let innerArcStart = CGPoint(
            x: center.x + clippedRadius * CGFloat(cos(startAngle)),
            y: center.y + clippedRadius * CGFloat(sin(startAngle)))
        
        let innerArcEnd = CGPoint(
            x: center.x + clippedRadius * CGFloat(cos(endAngle)),
            y: center.y + clippedRadius * CGFloat(sin(endAngle)))
        
        path = UIBezierPath()
        
        //stroke inner to outer line at start
        path.move(to: innerArcStart)
        path.addLine(to: outerArcStart)
        
        //stroke outer arc
        path.addArc(withCenter: center, radius: outerRadius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        
        //stroke outer to inner line at end
        path.addLine(to: innerArcEnd)
        
        //stroke inner arc
        path.addArc(withCenter: center, radius: clippedRadius, startAngle: CGFloat(endAngle), endAngle: CGFloat(startAngle), clockwise: false)
        
        path.close()
        
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        backgroundView.frame = self.frame
        backgroundView.bounds = self.bounds
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.backgroundView.layer.mask = mask;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = CGRect(x: 0, y: self.frame.height * 0.07, width: self.frame.size.width, height: self.frame.size.height)
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if let category = self.category {
            if category.subCategories.count > 0 {
                return category.subCategories.count
            } else {
                return category.items.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! SelectorWheelRingCell
        
        var drawable: Drawable!

        let index = (indexPath as NSIndexPath).row
        if let category = self.category {
            if category.subCategories.count > 0 {
                drawable = category.subCategories[index]
            } else if category.items.count > 0 {
                drawable = category.items[index]
            }
        }
        
        
        cell.angleSpan = self.angleSpan
        cell.innerRadius = self.innerRadius
        cell.outerRadius = self.outerRadius
        cell.isLandscape = self.isLandscape
        
        cell.setDrawable(drawable)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = (indexPath as NSIndexPath).row

        if let selectedCell = self.selectedCell {
            selectedCell.isSelected = false
            self.selectedCell = nil
        }
        
        var cell = self.collectionView.cellForItem(at: indexPath) as? SelectorWheelRingCell
        
        if cell == nil {
            self.collectionView.reloadData()
            cell = self.collectionView.cellForItem(at: indexPath) as? SelectorWheelRingCell
        }
        cell?.innerRadiusClipping = self.innerRadiusClipping
        self.selectedCell = cell

        let existingOffset = self.collectionView.contentOffset.x
        let ringLayout = self.collectionView.collectionViewLayout as? SelectorWheelRingLayout
        let offset = ringLayout?.offsetForRow(index)
        if (abs(offset! - existingOffset) > 1) {
            self.scrollTo(position: index)
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.03) {
                cell?.setEnlarged(true, animated: true)
            }
        }
        
        if !self.disableDelegateCall {
            if let category = self.category {
                if category.subCategories.count > 0 {
                    self.delegate?.categorySelected(category.subCategories[index], ring: self)
                } else if category.items.count > 0 {
                    self.delegate?.itemSelected(category.items[index], row: self.row)
                }
            }
        }
    }
    
    func scrollTo(position: Int, animated: Bool = true) {
        
        if let ringLayout = self.collectionView.collectionViewLayout as? SelectorWheelRingLayout {
            let offset = ringLayout.offsetForRow(position)
            self.collectionView.setContentOffset(CGPoint (x: offset, y: 0), animated: animated)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.03) {
            self.selectedCell?.setEnlarged(true, animated: true)
        }
    }
}






