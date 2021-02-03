//
//  UITableviewCellExtensions.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 3.2.21.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
