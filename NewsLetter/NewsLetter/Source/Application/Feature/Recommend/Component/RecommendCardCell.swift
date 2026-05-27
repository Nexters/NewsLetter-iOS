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
    let isTrendingCard: Bool
    let kind: Card.Kind
    let colorSet: ColorSet
}

extension RecommendCardCellProps {
    static func stub(title: String = "가나다라마바사아자차카타파하가나다라마바사아자차카타파하",
                     job: String = "직군",
                     source: String = "출처",
                     imageURL: String? = nil,
                     isTrendingCard: Bool = true,
                     kind: Card.Kind = .blog,
                     colorSet: ColorSet = defaultColorSet.first!) -> Self {
        .init(title: title,
              job: job,
              source: source,
              imageURL: imageURL,
              isTrendingCard: isTrendingCard,
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
        VStack(spacing: 0) {
            SpeechBubble(text: "함께 읽으면 더 좋은 인기 컨텐츠")
                .padding(.bottom, 12)
                .opacity(props.isTrendingCard ? 1.0 : 0.0)
            
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
                    CachedAsyncImage(url: props.imageURL ?? "") {
                        placeHolder(kind: props.kind)
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
    }
    
    @ViewBuilder
    private func placeHolder(kind: Card.Kind) -> some View {
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
