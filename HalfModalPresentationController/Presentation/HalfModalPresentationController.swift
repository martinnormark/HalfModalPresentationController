//
//  HalfModalPresentationController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

enum ModalScaleState {
    case adjustedOnce
    case normal
}

class HalfModalPresentationController : UIPresentationController {
    var isMaximized: Bool = false
    
    var _dimmingView: UIView?
    var panGestureRecognizer: UIPanGestureRecognizer
    var direction: CGFloat = 0
    var state: ModalScaleState = .normal
    var dimmingView: UIView {
        if let dimmedView = _dimmingView {
            return dimmedView
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        
        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        _dimmingView = view
        
        return view
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func onPan(pan: UIPanGestureRecognizer) -> Void {
        let endPoint = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
        case .began:
            presentedView!.frame.size.height = containerView!.frame.height
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            print(velocity.y)
            switch state {
            case .normal:
                presentedView!.frame.origin.y = endPoint.y + containerView!.frame.height / 2
            case .adjustedOnce:
                presentedView!.frame.origin.y = endPoint.y
            }
            direction = velocity.y
            
            break
        case .ended:
            if direction < 0 {
                changeScale(to: .adjustedOnce)
            } else {
                if state == .adjustedOnce {
                    changeScale(to: .normal)
                } else {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            }
            
            print("finished transition")
            
            break
        default:
            break
        }
    }
    
    func changeScale(to state: ModalScaleState) {
        if let presentedView = presentedView, let containerView = self.containerView {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { () -> Void in
                presentedView.frame = containerView.frame
                let containerFrame = containerView.frame
                let halfFrame = CGRect(origin: CGPoint(x: 0, y: containerFrame.height / 2),
                                       size: CGSize(width: containerFrame.width, height: containerFrame.height / 2))
                let frame = state == .adjustedOnce ? containerView.frame : halfFrame
                
                presentedView.frame = frame
                
                if let navController = self.presentedViewController as? UINavigationController {
                    self.isMaximized = true
                    
                    navController.setNeedsStatusBarAppearanceUpdate()
                    
                    // Force the navigation bar to update its size
                    navController.isNavigationBarHidden = true
                    navController.isNavigationBarHidden = false
                }
            }, completion: { (isFinished) in
                self.state = state
            })
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
    }
    
    override func presentationTransitionWillBegin() {
        let dimmedView = dimmingView
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            
            dimmedView.alpha = 0
            containerView.addSubview(dimmedView)
            dimmedView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                dimmedView.alpha = 1
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView.alpha = 0
                self.presentingViewController.view.transform = CGAffineTransform.identity
            }, completion: { (completed) -> Void in
                print("done dismiss animation")
            })
            
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        print("dismissal did end: \(completed)")
        
        if completed {
            dimmingView.removeFromSuperview()
            _dimmingView = nil
            
            isMaximized = false
        }
    }
}

protocol HalfModalPresentable { }

extension HalfModalPresentable where Self: UIViewController {
    func maximizeToFullScreen() -> Void {
        if let presetation = navigationController?.presentationController as? HalfModalPresentationController {
            presetation.changeScale(to: .adjustedOnce)
        }
    }
}

extension HalfModalPresentable where Self: UINavigationController {
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? HalfModalPresentationController {
            return presentationController.isMaximized
        }
        
        return false
    }
}
