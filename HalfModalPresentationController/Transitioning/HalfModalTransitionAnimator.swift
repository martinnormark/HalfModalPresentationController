//
//  HalfModalTransitionAnimator.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 29/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class HalfModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: HalfModalTransitionAnimatorType
    
    init(type:HalfModalTransitionAnimatorType) {
        self.type = type
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let _ = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            
            from!.view.frame.origin.y = 800
            
            print("animating...")
            
        }) { (completed) -> Void in
            print("animate completed")
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
}

internal enum HalfModalTransitionAnimatorType {
    case Present
    case Dismiss
}