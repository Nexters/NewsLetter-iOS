//
//  CardTypeScaleAppearance.swift
//  NewsLetter
//
//  Created by 이조은 on 9/22/25.
//

import SwiftUI

/// 카드 타입에 따른 크기(스케일) 변화를 드래그 진행도(progress)에 맞춰 보간하는 AnimatableModifier
/// 즉, 카드가 fromType → toType으로 바뀔 때 크기가 자연스럽게 애니메이션되도록 도와주는 역할을 합니다.
public struct CardTypeScaleAppearance<ID: Hashable>: AnimatableModifier {
    public var id: ID
    public var fromType: CardType
    public var toType: CardType
    public var progress: CGFloat
    public var namespace: Namespace.ID

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    public func body(content: Content) -> some View {
        // 타입 기준 스케일을 진행도에 따라 보간
        let start = fromType.visualScale
        let end   = toType.visualScale
        let s     = start + (end - start) * progress

        return content
            .matchedGeometryEffect(id: id, in: namespace, isSource: false)
            .scaleEffect(s)
    }
}

public extension View {
    func cardTypeScaleAppearance<ID: Hashable>(
        id: ID,
        from fromType: CardType,
        to toType: CardType,
        progress: CGFloat,
        namespace: Namespace.ID
    ) -> some View {
        modifier(CardTypeScaleAppearance(id: id, fromType: fromType, toType: toType, progress: progress, namespace: namespace))
    }
}
