//
//  File.swift
//  
//
//  Created by Macbook Pro on 15/5/24.
//

import UIKit
import MBProgressHUD

public class HUDHelper {
    
    public static func showToast(in view: UIView, message: String, duration: TimeInterval = 2.0) {
        // Ensure MBProgressHUD is only shown once
        MBProgressHUD.hide(for: view, animated: true)
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = message
        hud.margin = 10.0
        hud.offset.y = UIScreen.main.bounds.size.height / 2 - 100 // Adjust position if needed
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: duration) // Duration for the toast to be visible
    }
}

