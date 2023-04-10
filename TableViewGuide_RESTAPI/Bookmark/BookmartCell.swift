//
//  BookmartCell.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 08/04/2023.
//

import UIKit

class BookmartCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var bookmartImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        bookmartImage.image = UIImage(systemName: "book")
        contentView.addSubview(bookmartImage)
        bookmartImage.translatesAutoresizingMaskIntoConstraints = false
        bookmartImage.heightAnchor.constraint(equalToConstant: 25).isActive = true
        bookmartImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        bookmartImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        bookmartImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: bookmartImage.trailingAnchor, constant: 10).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
