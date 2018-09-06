//
//  ScrollTabController.swift
//  ScrollTabController
//
//  Created by fuxp on 2018/8/24.
//  Copyright © 2018 fuxp. All rights reserved.
//

import UIKit

public typealias TabBar = UIView & ScrollTabBar

public struct ScrollTabControllerStyle {
    ///Determines whether scrolling is enabled. Default is true
    let scrollEnabled: Bool
    ///Space between pages, in points. Default is 0.
    let interPageSpacing: CGFloat
    ///Height of the bar. 0 means the bar will not be added to the view of the controller, and you can manage it youself. Default is 44
    let barHeight: CGFloat
    public init(scrollEnabled: Bool = true, interPageSpacing: CGFloat = 0, barHeight: CGFloat = 44) {
        self.scrollEnabled = scrollEnabled
        self.interPageSpacing = interPageSpacing
        self.barHeight = barHeight
    }
}

open class ScrollTabController: UIViewController {
    private var controllers: [UIViewController?]!

    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal
            , options: [UIPageViewControllerOptionInterPageSpacingKey: self.style.interPageSpacing])
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()

    open private (set) var currentIndex: Int
    open let style: ScrollTabControllerStyle
    open let tabBar: TabBar
    open weak var dataSource: ScrollTabControllerDataSource?

    public init(style: ScrollTabControllerStyle = ScrollTabControllerStyle(), tabBar: TabBar, index: Int = 0) {
        self.style = style
        self.tabBar = tabBar
        self.currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }

    ///init(nibName:bundle:) has not been implemented
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    ///init(coder:) has not been implemented
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        reload()
    }

    open func reload() {
        let count = dataSource?.numberOfControllers(for: self) ?? 0
        guard count > 1 else {
            return
        }
        if currentIndex >= count {
            currentIndex = 0
        }
        controllers = Array(repeating: nil, count: count)
        if style.barHeight > 0 {
            configTabBar()
        }
        configControllers()
    }

    private func configTabBar() {
        tabBar.removeFromSuperview()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tabBar)
        if #available(iOS 11.0, *) {
            tabBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            tabBar.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tabBar.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
            tabBar.heightAnchor.constraint(equalToConstant: style.barHeight).isActive = true
        } else {
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bar]|", metrics: nil, views: ["bar": tabBar]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide][bar(height)]", metrics: ["height": style.barHeight], views: ["topLayoutGuide": topLayoutGuide, "bar": tabBar]))
        }
        let count = (dataSource?.numberOfControllers(for: self))!
        var titles = [ScrollTabBarTitleItem]()
        for i in 0..<count {
            titles.append(dataSource?.tabController(self, titleForControllerAt: i) ?? "")
        }
        tabBar.setTitles(titles)
        tabBar.selectItem(at: currentIndex)
    }

    private func configControllers() {
        for child in childViewControllers {
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        if style.scrollEnabled {
            addChildViewController(pageViewController)
            displayViewOfChildController(pageViewController)
            if let controller = viewController(at: currentIndex) {
                pageViewController.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            }
        } else {
            for i in 0..<controllers.count {
                if let controller = viewController(at: i) {
                    addChildViewController(controller)
                    if i == currentIndex {
                        displayViewOfChildController(controller)
                    }
                }
            }
        }
    }

    private func displayViewOfChildController(_ childController: UIViewController) {
        let view = childController.view!
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        if #available(iOS 11.0, *) {
            view.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            if style.barHeight > 0 {
                view.topAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
            } else {
                view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            }
        } else {
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", metrics: nil, views: ["view": view]))
            if style.barHeight > 0 {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[bar][view][bottom]", metrics: nil, views: ["bar": tabBar, "view": view, "bottom": bottomLayoutGuide]))
            } else {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][view][bottom]", metrics: nil, views: ["top": topLayoutGuide, "view": view, "bottom": bottomLayoutGuide]))
            }
        }
    }

    private  func viewController(at index: Int) -> UIViewController? {
        if let controller = controllers[index] {
            return controller
        }
        if let controller = dataSource?.tabController(self, viewControllAt: index) {
            controllers[index] = controller
            return controller
        }
        return nil
    }

    open func transitionToController(at index: Int) {
        guard index != currentIndex else {
            return
        }
        if let controller = viewController(at: index) {
            if style.scrollEnabled {
                pageViewController.setViewControllers([controller], direction: currentIndex > index ? .reverse : .forward, animated: true, completion: { (completed) in
                    if completed {
                        self.currentIndex = index
                    }
                })
            } else {
                if let from = viewController(at: currentIndex) {
                    from.view.removeFromSuperview()
                    displayViewOfChildController(controller)
                    currentIndex = index
                }
            }
        }
    }
}

extension ScrollTabController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        let vc = self.viewController(at: currentIndex - 1)
        return vc
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let count = controllers.count
        if count == 0 {
            return nil
        }
        if currentIndex == count - 1 {
            return nil
        }
        return self.viewController(at: currentIndex + 1)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        let current = pageViewController.viewControllers?.first!
        for (index, item) in controllers.enumerated() {
            if item == current {
                currentIndex = index
                tabBar.selectItem(at: currentIndex)
                break
            }
        }
    }
}

public protocol ScrollTabControllerDataSource: AnyObject {
    func numberOfControllers(for tabController: ScrollTabController) -> Int
    func tabController(_ tab: ScrollTabController, viewControllAt index: Int) -> UIViewController
    func tabController(_ tab: ScrollTabController, titleForControllerAt index: Int) -> ScrollTabBarTitleItem
}
