//
//  AppTabControllerDelegate.swift
//  SWSabres
//
//  Created by Mark Johnson on 2/22/16.
//  Copyright © 2016 swdev.net. All rights reserved.
//

import Foundation
import UIKit

final class AppTabControllerDelegate: NSObject, UITabBarControllerDelegate
{
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(tabBarController.selectedIndex, forKey: "appSelectedTabBarIndex")
        defaults.synchronize()
    }
}