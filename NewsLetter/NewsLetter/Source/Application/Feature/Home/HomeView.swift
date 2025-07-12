//
//  HomeView.swift
//  NewsLetter
//
//  Created by 이조은 on 7/12/25.
//

import SwiftUI
import FirebaseRemoteConfig

class RemoteConfigManager: ObservableObject {
    @Published var buttonColor: Color = .green
    private var remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1시간
        remoteConfig.configSettings = settings
        fetchRemoteValues()
    }

    func fetchRemoteValues() {
        remoteConfig.fetchAndActivate { status, error in
            if error != nil {
                print("Remote Config fetch failed: \(error!.localizedDescription)")
                return
            }

            let colorValue = self.remoteConfig["button_color"].stringValue ?? "green"
            DispatchQueue.main.async {
                self.buttonColor = (colorValue == "green") ? .green : .orange
                print("실험 그룹 색상: \(colorValue)")
            }
        }
    }
}

struct HomeView: View {
    @StateObject private var remoteConfigManager = RemoteConfigManager()
  var body: some View {
      VStack{
          Rectangle()
              .fill(.blue)
              .frame(width: 50, height: 50)
          Rectangle()
              .fill(.red)
              .frame(width: 50, height: 50)
          Button("A/B Test Button") {
                      print("버튼 클릭됨")
                  }
                  .padding()
                  .background(remoteConfigManager.buttonColor)
                  .foregroundColor(.white)
                  .cornerRadius(10)
      }
  }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
