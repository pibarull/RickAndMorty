//
//  UIImage+.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 6.12.2024.
//

import UIKit

extension UIImage {
    var data: Data? {
        if let data = self.jpegData(compressionQuality: 1.0) {
            return data
        } else {
            return nil
        }
    }
}
