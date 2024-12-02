//
//  SearchPicker.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 29.11.2024.
//

import Foundation
import UIKit
import RxSwift

enum Category: String {
    case byEpisodeNumber = "Episode"
    case byName = "Name"
}

final class SearchPicker: UIPickerView {

    private let categories: [Category] = [.byEpisodeNumber, .byName]
    let selectedCategory = PublishSubject<Category>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
        self.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchPicker: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory.onNext(categories[row])
    }
}
