//
//  LeftAlignedCell.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/29/25.
//

import UIKit

final class JobCell: UICollectionViewCell, CellType {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 15)
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = UIColor(hexCode: "#292A2E")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var iconImage: UIImageView? = {
        let uiImage = UIImageView()
        uiImage.translatesAutoresizingMaskIntoConstraints = false
        return uiImage
    }()
    
    var isTapped: Bool = false {
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
        self.layer.borderColor = isTapped ? UIColor(hexCode: "#121212").cgColor : UIColor(hexCode: "#E8EBF0").cgColor
        self.backgroundColor = UIColor(hexCode: "#FFFFFF")
    }
    
    private func layout() {
        if let iconImage = iconImage {
            
            contentView.addSubview(iconImage)
            contentView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                iconImage.widthAnchor.constraint(equalToConstant: 18),
                iconImage.heightAnchor.constraint(equalToConstant: 18),
                iconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 4),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            ])
        }
    }
}
