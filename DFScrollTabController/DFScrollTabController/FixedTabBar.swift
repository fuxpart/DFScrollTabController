//
//  FixedTabBar.swift
//  DFScrollTabController
//
//  Created by Fuxp on 2018/8/29.
//  Copyright © 2018年 fuxp. All rights reserved.
//

import UIKit

open class FixedTabBar: TabBarBase, ScrollTabBar {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(indicator)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator(height)]-1-|", metrics: ["height": indicatorHeight], views: ["indicator": indicator]))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func selectItem(at index: Int) {
        currentSelectedItem?.isSelected = false
        for view in self.subviews {
            if view is UIButton && view.tag == index + itemTag {
                currentSelectedItem = view as! UIButton
                break
            }
        }
    }

    public func setTitles(_ titles: [ScrollTabBarTitleItem]) {
        for button in self.subviews {
            if button is UIButton {
                button.removeFromSuperview()
            }
        }
        var last: UIButton? = nil
        for (index, title) in titles.enumerated() {
            let button = buttonWithTitle(title, tag: index + itemTag)
            self.addSubview(button)
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: indicator, attribute: .top, multiplier: 1, constant: 0).isActive = true
            if last == nil {
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
            } else {
                NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: last!, attribute: .right, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: last!, attribute: .width, multiplier: 1, constant: 0).isActive = true
            }
            if index == titles.count - 1 {
                NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
            }
            last = button
        }
    }
}
