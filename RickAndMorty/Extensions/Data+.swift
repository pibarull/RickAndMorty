//
//  Data+.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 21.11.2024.
//

import Foundation
import UIKit

extension Data {

    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }

    var image: UIImage? {
        if let image = UIImage(data: self) {
            return image
        } else {
            return nil
        }
    }
}
