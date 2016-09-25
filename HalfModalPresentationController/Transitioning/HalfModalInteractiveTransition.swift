//
//  HalfModalInteractiveTransition.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 28/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class HalfModalInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var viewController: UIViewController
    var presentingViewController: UIViewController?
    var panGestureRecognizer: UIPanGestureRecognizer
    
    var shouldComplete: Bool = false
    
    init(viewController: UIViewController, withView view:UIView, presentingViewController: UIViewController?) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.panGestureRecognizer = UIPanGestureRecognizer()
        
        super.init()
        
        self.panGestureRecognizer.addTarget(self, action: #selector(onPan))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        
        print("start interactive")
    }
    
    override var completionSpeed: CGFloat {
        get {
            return 1.0 - self.percentComplete
        }
        set {}
    }
    
    func onPan(pan: UIPanGestureRecognizer) -> Void {
        let translation = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
        case .began:
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
            break
            
        case .changed:
            let screenHeight = UIScreen.main.bounds.size.height - 50
            let dragAmount = screenHeight
            let threshold: Float = 0.2
            var percent: Float = Float(translation.y) / Float(dragAmount)

            percent = fmaxf(percent, 0.0)
            percent = fminf(percent, 1.0)
            
            update(CGFloat(percent))
            
            shouldComplete = percent > threshold
            
            break
            
        case .ended, .cancelled:
            if pan.state == .cancelled || !shouldComplete {
                cancel()
                
                print("cancel transition")
            }
            else {
                finish()
                
                print("finished transition")
            }
            
            break
            
        default:
            cancel()
            
            break
        }
    }
}
