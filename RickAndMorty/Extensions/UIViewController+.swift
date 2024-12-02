//
//  UIViewController+.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 21.11.2024.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

public extension Reactive where Base: UIViewController {

    var viewDidAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { _ in }
        return ControlEvent(events: source)
    }
}
