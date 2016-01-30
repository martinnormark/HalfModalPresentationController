//
//  HalfModalTransitioningDelegate.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class HalfModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactionController: HalfModalInteractiveTransition
    
    var interactiveDismiss = true
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.interactionController = HalfModalInteractiveTransition(viewController: self.viewController, withView: self.presentingViewController.view, presentingViewController: self.presentingViewController)
        
        super.init()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HalfModalTransitionAnimator(type: .Dismiss)
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismiss {
            return self.interactionController
        }
        
        return nil
    }
    
}

extension UIViewController { }