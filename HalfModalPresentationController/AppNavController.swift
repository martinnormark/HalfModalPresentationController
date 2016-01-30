//
//  AppNavController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 28/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class AppNavController: UINavigationController, HalfModalPresentable {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isHalfModalMaximized() ? .Default : .LightContent
    }
}