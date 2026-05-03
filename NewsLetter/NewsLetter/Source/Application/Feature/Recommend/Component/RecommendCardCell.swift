//
//  RecommendCardCell.swift
//  NewsLetter
//
//  Created by 이원빈 on 4/27/26.
//

import SwiftUI


struct RecommendCardCellProps {
    let title: String
    let job: String
    let source: String
    let imageURL: String?
    let kind: Kind
    let colorSet: COLORSET
    
    enum Kind: String {
        case news
        case blog
        case book
    }
}

extension RecommendCardCellProps {
    static func stub(title: String = "가나다라마바사아자차카타파하가나다라마바사아자차카타파하",
                     job: String = "직군",
                     source: String = "출처",
                     imageURL: String? = nil,
                     kind: Kind = .blog,
                     colorSet: COLORSET = COLORSET_LIST.first!) -> Self {
        .init(title: title,
              job: job,
              source: source,
              imageURL: imageURL,
              kind: kind,
              colorSet: colorSet)
    }
}

struct RecommendCardCell: View {
    private enum Metric {
        static let commonPadding: CGFloat = 24
    }
    
    let props: RecommendCardCellProps
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(props.title)
                .font(.body18_bold)
                .foregroundStyle(ColorPalette.gray950)
                .padding(.top, Metric.commonPadding)
                .padding(.horizontal, Metric.commonPadding)
            
            HStack(spacing: 0) {
                Text(props.job)
                    .font(.body13_medium)
                    .foregroundStyle(ColorPalette.gray950.opacity(0.5))
                    .padding(.trailing, 6)
                Rectangle()
                    .frame(width: 1, height: 14)
                    .foregroundStyle(ColorPalette.black.opacity(0.1))
                    .padding(.trailing, 6)
                Text(props.source)
                    .font(.body13_medium)
                    .foregroundStyle(ColorPalette.gray950.opacity(0.5))
            }
            .padding(.top, 4)
            .padding(.leading, Metric.commonPadding)
            
            VStack(spacing: 0) {
                // testURL: https://picsum.photos/400/300
                CachedAsyncImage(url: props.imageURL ?? "") {
                    placeHolder(kind: .news)
                }
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 150)
            }
            .background(RoundedRectangle(cornerRadius: 16).foregroundStyle(ColorPalette.white.opacity(0.3)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.top, 20)
            .padding(.horizontal, Metric.commonPadding)
            .padding(.bottom, 34)
                
        }
        .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(props.colorSet.main))
    }
    
    @ViewBuilder
    private func placeHolder(kind: RecommendCardCellProps.Kind) -> some View {
        VStack(spacing: 0) {
            Text(kind.rawValue.uppercased())
                .font(.system(size: 48, weight: .black))
                .padding(.top, 46)
                .frame(maxWidth: .infinity)
                .foregroundStyle(props.colorSet.sub)
            Rectangle()
                .frame(width: 48, height: 4)
                .padding(.top, 4)
                .padding(.bottom, 48)
                .foregroundStyle(props.colorSet.sub)
        }
    }
}

#Preview {
    RecommendCardCell(props: .stub())
}
