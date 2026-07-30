//
//  ConfirmAlertDialog.swift
//  NewsLetter
//

import SwiftUI

struct ConfirmAlertDialog: View {
    /// `**강조 문구**` 형태로 감싼 구간만 세미볼드 + 진한 색으로 표시하고, 나머지는 Regular + 회색으로 표시합니다.
    let message: String
    let cancelTitle: String
    let confirmTitle: String
    let cancelHandler: () -> Void
    let confirmHandler: () -> Void

    private var styledMessage: Text {
        message.components(separatedBy: "**")
            .enumerated()
            .reduce(Text("")) { result, element in
                let (index, part) = element
                let isEmphasized = index % 2 == 1
                // 이 모달 안에서만 글자 단위로 줄바꿈이 가능하도록 글자 사이에 폭 없는 공백을 삽입합니다.
                let charWrappablePart = part.map(String.init).joined(separator: "\u{200B}")
                let segment = Text(charWrappablePart)
                    .font(isEmphasized ? FontStyle.body16_semiBold.font : FontStyle.body16_regular.font)
                    .foregroundColor(isEmphasized ? Color.semanticColor.text_strong : Color.semanticColor.text_secondary)
                return result + segment
            }
    }

    var body: some View {
        VStack(spacing: 20) {
            styledMessage
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Button(action: cancelHandler) {
                    Text(cancelTitle)
                        .font(.body16_semiBold)
                        .foregroundStyle(.semanticColor.text_secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.semanticColor.fill_primary)
                        )
                }

                Button(action: confirmHandler) {
                    Text(confirmTitle)
                        .font(.body16_semiBold)
                        .foregroundStyle(.semanticColor.text_strongInverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.semanticColor.fill_primaryInversion)
                        )
                }
            }
        }
        .padding(.top, 26)
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
        .frame(width: 315)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(ColorPalette.white)
        )
    }
}

extension View {
    func confirmAlertDialog(
        isPresented: Binding<Bool>,
        message: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "확인",
        cancelHandler: @escaping () -> Void = {},
        confirmHandler: @escaping () -> Void
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented.wrappedValue = false
                            cancelHandler()
                        }

                    ConfirmAlertDialog(
                        message: message,
                        cancelTitle: cancelTitle,
                        confirmTitle: confirmTitle,
                        cancelHandler: {
                            isPresented.wrappedValue = false
                            cancelHandler()
                        },
                        confirmHandler: {
                            isPresented.wrappedValue = false
                            confirmHandler()
                        }
                    )
                }
                .transition(.opacity)
                .zIndex(Z.alertDialog)
            }
        }
        .animation(.easeInOut, value: isPresented.wrappedValue)
    }
}

#Preview {
    ConfirmAlertDialog(
        message: "관심 직군 변경은 **계정당 한 번만 가능**합니다. 변경 후에는 다른 직군으로 수정할 수 없습니다.",
        cancelTitle: "취소",
        confirmTitle: "변경하기",
        cancelHandler: {},
        confirmHandler: {}
    )
}
