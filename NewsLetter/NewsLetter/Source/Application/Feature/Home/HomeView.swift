//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI

struct HomeView: View {
  var body: some View {
      VStack{
          Rectangle()
              .fill(.blue)
              .frame(width: 50, height: 50)
          Rectangle()
              .fill(.red)
              .frame(width: 50, height: 50)
      }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
