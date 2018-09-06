//
//  ScrollTabBar.swift
//  ScrollTabController
//
//  Created by fuxp on 2018/8/24.
//  Copyright © 2018 fuxp. All rights reserved.
//

import UIKit

public protocol ScrollTabBar {
    func selectItem(at index: Int)
    func setTitles(_ titles: [ScrollTabBarTitleItem])
}

public protocol ScrollTabBarTitleItem {
    func itemTitle() -> String
}

extension String: ScrollTabBarTitleItem {
    public func itemTitle() -> String {
        return self
    }
}

open class TabBarBase: UIView {
    /// the line at the bottom of the bar
    let shadowLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let indicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Color of the title. To modify, subclass and override
    open var color: UIColor {
        return .black
    }
    
    /// Color of the title when selected. To modify, subclass and override
    open var selectedColor: UIColor {
        return .red
    }
    
    /// Font of the title. To modify, subclass and override
    open var font: UIFont {
        return .systemFont(ofSize: 14)
    }
    
    /// Height of the indicator. To modify, subclass and override
    open var indicatorHeight: CGFloat {
        return 2
    }
    
    /// Color of the indicator. To modify, subclass and override
    open var indicatorColor: UIColor {
        return .red
    }

    /// Color of the shadow line. To modify, subclass and override
    open var shadowLineColor: UIColor {
        return .lightGray
    }

    let itemTag = 100

    public weak var scrollTabController: ScrollTabController?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        shadowLine.backgroundColor = shadowLineColor
        self.addSubview(shadowLine)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadowLine]|", metrics: nil, views: ["shadowLine": shadowLine]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[shadowLine(height)]|", metrics: ["height": 1.0 / UIScreen.main.scale], views: ["shadowLine": shadowLine]))
        indicator.backgroundColor = indicatorColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buttonWithTitle(_ title: ScrollTabBarTitleItem, tag: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(title.itemTitle(), for: .normal)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(selectedColor, for: .selected)
        button.titleLabel?.font = font
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
        return button
    }

    private var indicatorCenterX: NSLayoutConstraint?
    private var indicaotrWidth: NSLayoutConstraint?

    var currentSelectedItem: UIButton! {
        willSet {
            indicatorCenterX?.isActive = false
            indicaotrWidth?.isActive = false
        }
        didSet {
            currentSelectedItem.isSelected = true
            indicatorCenterX = NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: currentSelectedItem, attribute: .centerX, multiplier: 1, constant: 0)
            indicaotrWidth = NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: currentSelectedItem, attribute: .width, multiplier: 1, constant: 0)
            UIView.animate(withDuration: 0.25) {
                self.indicatorCenterX?.isActive = true
                self.indicaotrWidth?.isActive = true
                self.layoutIfNeeded()
            }
        }
    }

    @objc func handleButtonAction(sender: UIButton) {
        currentSelectedItem.isSelected = false
        currentSelectedItem = sender
        scrollTabController?.transitionToController(at: sender.tag - itemTag)
    }
}
