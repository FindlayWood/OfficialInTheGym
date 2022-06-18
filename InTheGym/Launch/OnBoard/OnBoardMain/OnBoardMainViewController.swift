//
//  OnBoardMainViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class OnBoardMainViewController: UIPageViewController {
    // MARK: - Properties
    var controllers: [UIViewController] = [UIViewController]()
    var pageControl = UIPageControl()
    var skipButton = UIButton()
    let initialPage: Int = 0
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initDisplay()
        configureUI()
//        style()
//        layout()
    }
    func setup() {
        dataSource = self
        delegate = self
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)

        // create an array of viewController
        let page1 = OnBoardFirstViewController()
        let page2 = OnBoardSecondViewController()
        let page3 = OnBoardThirdViewController()

        controllers.append(page1)
        controllers.append(page2)
        controllers.append(page3)
        
        // set initial viewController to be displayed
        // Note: We are not passing in all the viewControllers here. Only the one to be displayed.
        setViewControllers([page1], direction: .forward, animated: true, completion: nil)
        
        page3.childContentView.startedButtonAction
            .sink { [weak self] in self?.getStartedAction() }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions

extension OnBoardMainViewController {
    
    // How we change page when pageControl tapped.
    // Note - Can only skip ahead on page at a time.
    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([controllers[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
    func getStartedAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.launchScreen()
    }
}
// MARK: - DataSource
extension OnBoardMainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = controllers.firstIndex(of: viewController) else {return nil}
        if currentIndex > 0 {
            return controllers[currentIndex - 1]
        } else {
            return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = controllers.firstIndex(of: viewController) else {return nil}
        if currentIndex < controllers.count - 1 {
            return controllers[currentIndex + 1]
        } else {
            return nil
        }
    }
}
// MARK: - Delegate
extension OnBoardMainViewController: UIPageViewControllerDelegate {
    // How we keep our pageControl in sync with viewControllers
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = controllers.firstIndex(of: viewControllers[0]) else { return }
        
        pageControl.currentPage = currentIndex
    }
}
