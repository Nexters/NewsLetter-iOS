//
//  CareerCell.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/29/25.
//

import UIKit

final class CareerCell: UICollectionViewCell, CellType {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 15)
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = UIColor(hexCode: "#292A2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var iconImage: UIImageView? = nil
    
    var isTapped = false {
        didSet {
            titleLabel.font = isTapped ? UIFont(name: "Pretendard-SemiBold", size: 15) :
            UIFont(name: "Pretendard-Medium", size: 15)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        attribute()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        attribute()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func attribute() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = isTapped ? UIColor(hexCode: "#121212").cgColor :
        UIColor(hexCode: "#E8EBF0").cgColor
        self.backgroundColor = UIColor(hexCode: "#FFFFFF")
    }
    
    private func layout() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
}
