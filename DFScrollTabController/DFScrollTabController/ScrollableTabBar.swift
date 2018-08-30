//
//  ScrollableTabBar.swift
//  DFScrollTabController
//
//  Created by Fuxp on 2018/8/29.
//  Copyright © 2018年 fuxp. All rights reserved.
//

import UIKit

extension String {
    func widthWithFont(_ font: UIFont) -> CGFloat {
        return ceil(self.size(withAttributes: [NSAttributedStringKey.font: font]).width)
    }
}

extension UIScrollView {
    func scrollRectToCenter(_ rect: CGRect) {
        if self.contentSize.width <= self.frame.width {
            return
        }
        var offset = (rect.width - self.frame.width) / 2.0 + rect.minX
        if offset < 0 {
            offset = 0
        } else if offset + self.frame.width > self.contentSize.width {
            offset = self.contentSize.width - self.frame.width
        }
        self.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}

/// A scrollable tab bar
open class ScrollableTabBar: TabBarBase, ScrollTabBar {

    /// scroll view of the tab bar
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView
    }()

    /// view appear at the right side of the bar
    open var accessoryView: UIView? {
        return nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(scrollView)
        if let accessory = accessoryView {
            self.addSubview(accessory)
            accessory.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[accessory]-1-|", metrics: nil, views: ["accessory": accessory]))
            NSLayoutConstraint(item: accessory, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: accessory, attribute: .width, relatedBy: .equal, toItem: accessory, attribute: .height, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView][accessory]", metrics: nil, views: ["scrollView": scrollView, "accessory": accessory]))
        } else {
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", metrics: nil, views: ["scrollView": scrollView]))
        }
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]-1-|", metrics: nil, views: ["scrollView": scrollView]))
        scrollView.addSubview(indicator)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator(height)]|", metrics: ["height": indicatorHeight], views: ["indicator": indicator]))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func handleButtonAction(sender: UIButton) {
        super.handleButtonAction(sender: sender)
        scrollView.scrollRectToCenter(sender.frame)
    }

    public func setTitles(_ titles: [ScrollTabBarTitleItem]) {
        for button in scrollView.subviews {
            if button is UIButton {
                button.removeFromSuperview()
            }
        }
        var last: UIButton? = nil
        for (index, title) in titles.enumerated() {
            let button = buttonWithTitle(title, tag: index + itemTag)
            scrollView.addSubview(button)
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: -indicatorHeight).isActive = true
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: -indicatorHeight).isActive = true
            if last == nil {
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0).isActive = true
            } else {
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: last!, attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
            let width = title.itemTitle().widthWithFont(font) + 10
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width).isActive = true
            if index == titles.count - 1 {
                NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
            last = button
        }
    }

    public func selectItem(at index: Int) {
        currentSelectedItem?.isSelected = false
        for view in scrollView.subviews {
            if view is UIButton && view.tag == index + itemTag {
                currentSelectedItem = view as! UIButton
                scrollView.scrollRectToCenter(view.frame)
                break
            }
        }
    }
}
