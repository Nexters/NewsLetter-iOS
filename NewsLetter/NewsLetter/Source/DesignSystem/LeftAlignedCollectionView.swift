//
//  LeftAlignedCollectionView.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/29/25.
//

import SwiftUI
import UIKit

struct LeftAlignedCollectionView<T: UICollectionViewCell>: UIViewRepresentable where T: CellType {
    
    typealias UIViewType = UICollectionView
    @Binding var data: [CellTypeData]
    @Binding var selectedIndex: Int?
    @Binding var selectedIndices: Set<Int>
    
    func makeUIView(context: Context) -> UICollectionView {
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        let collectionView = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(T.self, forCellWithReuseIdentifier: T.defaultRuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        private let parent: LeftAlignedCollectionView
        
        init(_ collectionView: LeftAlignedCollectionView) {
            self.parent = collectionView
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.parent.data.count
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.defaultRuseIdentifier, for: indexPath) as? T else {
                return UICollectionViewCell()
            }
            cell.titleLabel.text = parent.data[indexPath.row].text
            if T.defaultRuseIdentifier == "JobCell" {
                cell.isTapped = parent.selectedIndices.contains(indexPath.item)
            } else {
                cell.isTapped = parent.selectedIndex == indexPath.row
            }
            
            if let url = parent.data[indexPath.row].imageURL {
                cell.iconImage?.image = UIImage(named: url)
            }
            return cell
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: 100, height: 40)
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let cell = collectionView.cellForItem(at: indexPath) as? T else { return }
            
            if T.defaultRuseIdentifier == "JobCell" {
                if cell.isTapped {
                    parent.selectedIndices.remove(indexPath.item)
                } else {
                    parent.selectedIndices.insert(indexPath.item)
                }
            } else {
                if cell.isTapped {
                    parent.selectedIndex = nil
                } else {
                    parent.selectedIndex = indexPath.item
                }
            }
            
            collectionView.reloadData()
        }
    }
}

protocol CellType {
    var titleLabel: UILabel { get }
    var iconImage: UIImageView? { get }
    var isTapped: Bool { get set }
}

extension CellType {
    static var defaultRuseIdentifier: String {
        return String(describing: Self.self)
    }
}

struct CellTypeData {
    let text: String
    let imageURL: String?
    
    init(text: String, imageURL: String? = nil) {
        self.text = text
        self.imageURL = imageURL
    }
}

final class DynamicHeightCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            
        }
        return attributes
    }
}

#Preview(body: {
    VStack(alignment: .leading, spacing: 16) {
        
        LeftAlignedCollectionView<CareerCell>(
            data: .constant([
                CellTypeData.init(
                    text: "ANDROID",
                    imageURL: "android_icon"
                ),
                CellTypeData.init(
                    text: "iOS",
                    imageURL: "ios_icon"
                ),
                CellTypeData.init(
                    text: "FE",
                    imageURL: "fe_icon"
                ),
                CellTypeData.init(
                    text: "BE",
                    imageURL: "be_icon"
                )
            ]),
            selectedIndex: .constant(nil),
            selectedIndices: .constant(Set<Int>())
        ).debug()
    }
    .padding(24)
    .background(Color.init(hex: 0xffffff))
})
