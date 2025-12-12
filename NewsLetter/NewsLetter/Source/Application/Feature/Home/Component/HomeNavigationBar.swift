//
//  HomeNavigationBar.swift
//  NewsLetter
//
//  Created by 이원빈 on 11/22/25.
//

import SwiftUI

struct HomeNavigationBar: View {
    private enum Metric {
        static let fakeViewWidth: CGFloat = 40
        static let fakeViewHeight: CGFloat = 32
        static let buttonSize: CGFloat = 24
        static let barHeight: CGFloat = UIDevice.isSmallScreen ? 36 : 48
        static let topPadding: CGFloat = UIDevice.isSmallScreen ? 24 : 50
    }
    
    @Binding var selectedSegment: SegmentView.SegmentType
    let settingButtonTapHandler: (() -> Void)
    
    private var foregroundMainColor: Color {
        selectedSegment == .recommend ? .black : .white
    }
    
    private var backgroundMainColor: Color {
        selectedSegment == .recommend ? .white : .black // TODO: Figma 디자인 요구사항에 맞게 고도화 필요.
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: Metric.fakeViewWidth, height: Metric.fakeViewHeight)
                .opacity(0)
            Spacer()
            SegmentView(selectedSegment: $selectedSegment)
            Spacer()
            Button {
                settingButtonTapHandler()
            } label: {
                Image("setting_icon")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Metric.buttonSize, height: Metric.buttonSize)
                    .foregroundColor(foregroundMainColor)
                    .padding(8)
                    .padding(.trailing, 8)
            }
        }
        .frame(width: Device.width, height: Metric.barHeight)
        .padding(.top, Metric.topPadding)
        .background(backgroundMainColor)
    }
}

#Preview {
    HomeNavigationBar(selectedSegment: .constant(.recommend), settingButtonTapHandler: {})
}
