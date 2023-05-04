//
//  CategoryCell.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 04/05/2023.
//

import UIKit

class CategoryCell: UITableViewCell {

    public lazy var titleLabel: UILabel = {
        let title = UILabel()
        contentView.addSubview(title)
        return title
    }()
    
    var isBookmark: Bool! {
        didSet {
            self.accessoryType = isBookmark ? .checkmark : .none
        }
    }
    
    var category: CategoryTopStories? {
        didSet {
            guard let category = category else { return }
            titleLabel.text = category.title
            isBookmark = category.isBookmark
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(origin: .init(x: 20, y: 0), size: contentView.frame.size)
        selectionStyle = .none
    }
}
