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
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        let defaults = UserDefaults.standard
        defaults.set(tabBarController.selectedIndex, forKey: "appSelectedTabBarIndex")
        defaults.synchronize()
    }
}
