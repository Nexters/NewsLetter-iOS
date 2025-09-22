//
//  CardStackAnimation.swift
//  NewsLetter
//
//  Created by 이조은 on 9/22/25.
//

import SwiftUI

public enum CardStackDirection { case up, down }

public struct CardStackAnimator {
    public static var rotation: Animation { .spring(response: 0.55, dampingFraction: 0.9) }
    public static func perform(_ action: @escaping () -> Void) {
        withAnimation(rotation, action)
    }
}

public extension View {
    /// 카드 스택에 적용할 드래그 제스처와 애니메이션 로직을 정의
    /// 사용자가 위/아래로 드래그하거나 플링할 때 카드 순서를 회전시키고, 여러 장 넘김까지 자연스럽게 애니메이션 처리하는 역할을 합니다.
    func cardStackDragGesture(
        trigger: CGFloat = 48,
        maxStepsPerFling: Int = 2,
        interStepDelay: TimeInterval = 0.06,
        onProgress: @escaping (_ progress: CGFloat, _ direction: CardStackDirection?) -> Void,
        onRotateDown: @escaping () -> Void,
        onRotateUp: @escaping () -> Void
    ) -> some View {
        gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    let dy = value.translation.height
                    let dir: CardStackDirection? = dy == 0 ? nil : (dy > 0 ? .down : .up)
                    let prog = min(1, abs(dy) / max(1, trigger))   // 0…1
                    onProgress(prog, dir)
                }
                .onEnded { value in
                    let dy = value.translation.height
                    let endDY = value.predictedEndTranslation.height

                    let dirSign = (endDY != 0) ? (endDY > 0 ? 1 : -1) : (dy > 0 ? 1 : (dy < 0 ? -1 : 0))
                    guard dirSign != 0 else {
                        withAnimation(CardStackAnimator.rotation) { onProgress(0, nil) }
                        return
                    }

                    let distance = abs(endDY)
                    var steps = Int(floor(distance / trigger))

                    if steps == 0 {
                        withAnimation(CardStackAnimator.rotation) { onProgress(0, nil) }
                        return
                    }

                    let cap = maxStepsPerFling
                    steps = min(steps, cap)

                    let direction: CardStackDirection = (dirSign > 0) ? .down : .up

                    for i in 0..<steps {
                        let delay = interStepDelay * Double(i)
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            CardStackAnimator.perform {
                                switch direction {
                                case .down: onRotateDown()
                                case .up:   onRotateUp()
                                }
                            }
                        }
                    }

                    let resetDelay = interStepDelay * Double(max(0, steps - 1)) + 0.01
                    DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                        withAnimation(CardStackAnimator.rotation) { onProgress(0, nil) }
                    }
                }

        )
    }
}
