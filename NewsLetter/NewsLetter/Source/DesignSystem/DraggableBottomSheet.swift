//
//  DraggableBottomSheet.swift
//  NewsLetter
//
//  Created by 이원빈 on 7/28/25.
//

import SwiftUI

extension View {
    func draggableBottomSheet<DialogContent: View>(
        isShow: Binding<Bool>,
        dismissHandler: @escaping () -> Void,
        @ViewBuilder dialogContent: @escaping () -> DialogContent
    ) -> some View {
        modifier(
            DraggableBottomSheetInfo(
                isShowModal: isShow,
                dismissHandler: dismissHandler,
                dialogContent: dialogContent
            )
        )
    }
}

struct DraggableBottomSheetInfo<DialogContent: View>: ViewModifier {
    @Binding var isShowModal: Bool
    @State private var offsetY: CGFloat = 0.0
    @State private var accumulatedOffset: CGFloat = 0.0
    @State private var currentHeight: CGFloat = .zero
    
    let dismissHandler: () -> Void
    let injectedView: DialogContent
    
    init(
        isShowModal: Binding<Bool>,
        dismissHandler: @escaping () -> Void,
        @ViewBuilder dialogContent: () -> DialogContent
    ) {
        _isShowModal = isShowModal
        self.dismissHandler = dismissHandler
        injectedView = dialogContent()
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if isShowModal {
                DraggableBottomSheet(height: $currentHeight, dragGesture: drag) {
                    injectedView
                }
                .frame(width: Device.width)
                .offset(y: offsetY)
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .bottom),
                    removal: AnyTransition.move(edge: .bottom))
                )
                .zIndex(1)
                .ignoresSafeArea(edges: .bottom)
                .animation(.default, value: isShowModal)
                
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        dismissHandler()
                        isShowModal.toggle()
                    }
            }
        }
        .animation(.default, value: isShowModal)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                guard gesture.translation.height > 0 else { return }
                
                DispatchQueue.main.async {
                    offsetY = gesture.translation.height * 0.7
                }
            }
            .onEnded { gesture in
                guard gesture.translation.height > 0 else {
                    DispatchQueue.main.async {
                        offsetY = 0
                    }
                    return
                }
                
                if gesture.translation.height > currentHeight * 0.3 {
                    DispatchQueue.main.async {
                        dismissHandler()
                        withAnimation {
                            isShowModal = false
                        }
                        offsetY = 0
                    }
                } else {
                    DispatchQueue.main.async {
                        withAnimation(.bouncy) {
                            offsetY = 0
                        }
                    }
                }
            }
    }
}

struct DraggableBottomSheet_TestView: View {
    @State private var isShow = false
    @State private var index = 0
    @State private var currentHeight:CGFloat = 200
    
    var body: some View {
        NavigationView {
            
            VStack {
                Button {
                    withAnimation(.bouncy) {
                        isShow = true
                    }
                } label: {
                    Text("bottomsheet")
                }
                Spacer()
            }
            .draggableBottomSheet(isShow: $isShow, dismissHandler: { print("hello world")}) {
                VStack {
                    Text("DraggableBottomSheet2 테스트.............")
                    Text("내부 영역의 높이에 따라 자동으로 BottomSheet의 높이가 설정되는지")
                    Text("내부 영역의 높이에 따라 자동으로 BottomSheet의 높이가 설정되는지")
                    Text("내부 영역의 높이에 따라 자동으로 BottomSheet의 높이가 설정되는지")
                    Text("내부 영역의 높이에 따라 자동으로 BottomSheet의 높이가 설정되는지")
                }.debug()
            }
        }
    }
}

// MARK: - Preview

struct DraggableBottomSheet_TestView_Previews: PreviewProvider {
    
    static var previews: some View {
        DraggableBottomSheet_TestView()
    }
}

// MARK: - BottomSheet View

struct DraggableBottomSheet<DragGesture: Gesture, InjectedView: View>: View {
    
    @Binding var height: CGFloat
    
    let dragGesture: DragGesture
    let injectedView: InjectedView
    
    init(
        height: Binding<CGFloat>,
        dragGesture: DragGesture,
        @ViewBuilder injectedView: @escaping () -> InjectedView
    ) {
        _height = height
        self.dragGesture = dragGesture
        self.injectedView = injectedView()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            handleBar.gesture(dragGesture)
            injectedView
            Rectangle()
                .frame(
                    width: Device.width,
                    height: Device.safeAreaInsets.bottom
                )
                .foregroundColor(.white)
        }
        .background(GeometryReader { proxy in
            Color.white.onAppear {
                height = proxy.frame(in: .local).height
            }
        })
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
    
    var handleBar: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .frame(
                    width: Device.width,
                    height: 36
                )
                .foregroundColor(Color(.white))
            
            Capsule()
                .frame(width: 34, height: 4)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
    }
}
