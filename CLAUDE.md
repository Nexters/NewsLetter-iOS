# CLAUDE.md — 쏙 (NewsLetter-iOS)

Claude Code가 이 프로젝트를 올바르게 이해하고 기여할 수 있도록 돕는 문서입니다.
파일을 추가하기 전에 여기서 위치와 컨벤션을 먼저 확인하세요.

---

## Quick Reference

| 찾는 것 | 위치 |
|---|---|
| 앱 진입점 | `Source/Application/NewsLetterApp.swift` |
| 루트 Reducer / View | `Source/Application/App{Reducer,View}.swift` |
| 피처 모듈 | `Source/Application/Feature/<FeatureName>/` |
| 공용 컴포넌트 | `Source/DesignSystem/Component/` |
| 컬러 토큰 | `Source/DesignSystem/Color/ColorPalette.swift` |
| 폰트 토큰 | `Source/DesignSystem/Font/FontStyle.swift` |
| API 엔드포인트 | `Source/Data/API/*API.swift` |
| TCA 클라이언트 | `Source/Data/Client/*Client.swift` |
| DTO | `Source/Data/DTO/` |
| 도메인 엔티티 | `Source/Domain/Entity/` |
| 영속 상태 | `Source/Data/UserInfo.swift` (`@UserDefaultWrapper`) |
| Analytics 이벤트 | `Source/Utils/AnalyticsManager.swift` (`enum GA`) |

---

## 아키텍처: TCA + SwiftUI

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) v1.25.5 사용. iOS 17+, SwiftUI only.

### 피처 파일 구조

```
Feature/XxxFeature/
├── XxxView.swift       # SwiftUI View
├── XxxReducer.swift    # TCA Reducer (State, Action, body)
└── Component/          # 해당 피처 전용 컴포넌트
```

### Reducer 기본 패턴

```swift
@Reducer
struct XxxReducer {
    @ObservableState
    struct State: Equatable { ... }

    enum Action {
        case someAction
        case delegate(Delegate)
        @CasePathable enum Delegate { case someEvent }
    }

    @Dependency(\.someClient) var someClient

    var body: some Reducer<State, Action> {
        BindingReducer()   // Action: BindableAction일 때만
        Reduce { state, action in
            switch action {
            case .someAction:
                return .none
            }
        }
    }
}

struct XxxView: View {
    @Bindable var store: StoreOf<XxxReducer>
    var body: some View { ... }
}
```

### 자식 Reducer 스코핑

```swift
// Reducer body
Scope(state: \.childState, action: \.child) { ChildReducer() }

// View
ChildView(store: store.scope(state: \.childState, action: \.child))
```

### 자식 → 부모 통신 (Delegate Action)

자식 Reducer는 직접 부모 상태를 바꾸지 않고 Delegate Action을 발행합니다.

```swift
// 자식
case .delegate(.presentModal):
    return .none   // 자식은 아무것도 안 함

// 부모
case .child(.delegate(.presentModal)):
    state.isModalPresented = true
    return .none
```

### 스택 네비게이션

```swift
// Reducer
@Reducer enum Path { case detail(DetailReducer) }
var path: StackState<Path.State>

// View
NavigationStack(path: $store.scope(state: \.path, action: \.path)) { ... }
```

### Side Effect

```swift
// 비동기 작업
return .run { send in
    let result = try await someClient.fetch(dto)
    await send(.fetchResponse(result))
}

// 타이머 / 장기 작업 취소
enum CancelID { case timer }
return .run { ... }.cancellable(id: CancelID.timer)
return .cancel(id: CancelID.timer)
```

---

## 새 API 엔드포인트 추가

1. **`Source/Data/API/XxxAPI.swift`** — Moya `TargetType` 작성
   - `baseURL`: `AppInfo.baseURL` 사용 (하드코딩 금지)
   - GET 쿼리 파라미터: `URLEncoding.queryString`
   - POST/PUT JSON body: `JSONEncoding.default` + `dto.toDictionary()`

2. **`Source/Data/DTO/`** — DTO 추가
   - 요청: `XxxRequestDTO` (Encodable)
   - 응답: `XxxResponseDTO` (Decodable), 서버 키가 다르면 `CodingKeys` 작성

3. **`Source/Domain/Entity/`** — 도메인 엔티티 추가 (개념적 객체인 경우)

4. **Client에 wire-up** (아래 섹션 참조)

---

## 새 TCA Client 추가

모든 네트워크 호출은 Reducer에서 `MoyaAPIClient`를 직접 쓰지 않고 `*Client`를 거칩니다.
이유: TCA의 `@Dependency`로 주입하면 Preview / 테스트에서 fake 구현을 쉽게 교체할 수 있습니다.

`Source/Data/Client/CardClient.swift`를 템플릿으로 참고하세요.

```swift
@DependencyClient
struct XxxClient {
    static let apiClient = MoyaAPIClient()

    var fetchSomething: (XxxRequestDTO) async throws -> XxxEntity
}

extension DependencyValues {
    var xxxClient: XxxClient {
        get { self[XxxClient.self] }
        set { self[XxxClient.self] = newValue }
    }
}

extension XxxClient: DependencyKey {
    static var liveValue: XxxClient = {
        XxxClient(
            fetchSomething: { dto in
                let response = try await apiClient.request(XxxAPI.fetchSomething(dto))
                return try response.map(XxxResponseDTO.self).toDomain()
            }
        )
    }()

    static var previewValue: XxxClient = {
        XxxClient(fetchSomething: { _ in .stub() })
    }()

    static var testValue: XxxClient = previewValue  // 반드시 제공
}
```

Reducer에서:
```swift
@Dependency(\.xxxClient) var xxxClient
```

---

## 네이밍 컨벤션

| 종류 | 규칙 | 예시 |
|---|---|---|
| 파일 | PascalCase + 역할 suffix | `UserClient.swift`, `CardAPI.swift` |
| 타입 | PascalCase | `struct CardResponseDTO` |
| 변수 / 함수 | camelCase | `fetchCards`, `isPresentModal` |
| 폰트 토큰 | `size_weight` | `head28_bold`, `body16_semiBold` |
| 컬러 토큰 | `palette + number` | `gray100`, `pointBlue500`, `red300` |
| 주석 | 한국어 | `// 카드 목록을 캐싱합니다` |
| 코드 식별자 | 영어 | `var cardData`, `func fetchCards()` |

폰트는 `FontStyle` View modifier로, 컬러는 `ColorPalette` 토큰으로만 사용합니다.

```swift
Text("제목").fontStyle(.head28_bold)
Rectangle().fill(ColorPalette.pointBlue500)
```

---

## 디자인 시스템 컴포넌트

| 컴포넌트 | 사용법 |
|---|---|
| `DraggableBottomSheet` | `.draggableBottomSheet(isShow:dismissHandler:) { ... }` |
| `CustomNavigationBar` | 직접 View에 배치 |
| `WebView` / `WebViewFullScreen` | URL을 WKWebView로 래핑 |
| `ToastMessage` | `.toastMessage(isPresented:text:bottomPadding:)` |
| `ToastMessageWithButton` | `.toastMessageWithButton(...)` |
| Z-index | `enum Z` 상수 사용 (`Z.carouselModal` 등) |

---

## 영속 상태

- **UserDefaults** (Codable 구조): `@UserDefaultWrapper` — `UserInfo.swift`에 프로퍼티 추가
- **Keychain** (민감 정보): `KeychainManager.shared`
- `@AppStorage`, `UserDefaults.standard.set` 직접 사용 금지

---

## Analytics

`Source/Utils/AnalyticsManager.swift`의 `enum GA`에 이벤트를 추가합니다.
네이밍 패턴: `pageview_<화면>`, `click_<요소>`, `impression_<요소>`

---

## 커밋 메시지

```
[#이슈번호] TYPE: 한국어 설명
```

| TYPE | 용도 |
|---|---|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `chore` | 설정, 의존성, 기타 |
| `refactor` | 기능 변경 없는 리팩토링 |
| `release` | 버전 릴리즈 |

예시: `[#111] feat: 탐색탭 뉴스레터 제보하기 기능 추가`

---

## 브랜치 네이밍

```
type/#issue-number
```

| type | 용도 |
|---|---|
| `feature` | 새 기능 |
| `fix` | 버그 수정 |
| `hotfix` | 긴급 수정 |
| `release` | QA 브랜치 (`release/v1.1.2`) — 릴리스마다 develop에서 분기, 출시 후 삭제 |
| `test` | 테스트용 |

예시: `feature/#111`, `fix/#72`, `hotfix/explore-tab`, `release/v1.1.2`

**장수 브랜치**: `main`(출시), `develop`(통합)

---

## 금지 사항

- View에 비즈니스 로직 금지 → Reducer에 둘 것
- `UserDefaults.standard` 직접 접근 금지 → `@UserDefaultWrapper` 사용
- Reducer에서 `MoyaAPIClient` 직접 호출 금지 → `*Client` 경유
- `liveValue` / `previewValue` / `testValue` 셋 중 하나라도 빠진 Client 추가 금지
- `@StateObject`, `@ObservedObject` 사용 금지 → `@Bindable var store: StoreOf<XxxReducer>`
- BASE_URL 하드코딩 금지 → `AppInfo.baseURL` 사용
- `ColorPalette` 토큰 외의 raw Color, system Font 사용 금지

---

## 빌드 & CI

- **Xcode 프로젝트**: Xcode 16의 `PBXFileSystemSynchronizedRootGroup` 사용 — 폴더 안 파일이 자동으로 타겟에 포함됩니다. 새 Swift 파일을 올바른 폴더에 추가하면 별도 작업 없이 빌드에 포함됩니다.
- **패키지 매니저**: SPM (Xcode에서 직접 관리, `Package.resolved` 참고)
- **CI/CD**: GitHub Actions + Fastlane
- **배포 트리거**:
  - `develop` push → TestFlight 내부 전용 빌드 (QA용) + `build/X.Y.Z-N` 태그 자동 생성
  - `release/**` push → TestFlight 내부 전용 빌드 (QA 수정사항 재검증용)
  - `main`에 `vX.Y.Z` 태그 push → App Store Connect에 심사용 빌드 업로드
  - `main` 브랜치 push 자체는 빌드를 트리거하지 않음 (태그가 트리거)
- **내부 전용 빌드**: `beta` lane은 `testFlightInternalTestingOnly: true`로 빌드하므로 심사 제출이 **불가능**함. 심사용 빌드는 반드시 `main`의 태그를 통해 생성된다.
- **릴리스 브랜치 생성**: 수동으로 만들지 말고 Actions의 **"릴리스 브랜치 생성"** 워크플로를 실행한다. 브랜치 생성과 develop 버전 상향이 함께 처리되며, 버전 증가 단위(minor/patch/major)를 실행 시 선택한다.
- **QA 기간 버전 분리**: `release/vX.Y.Z` 분기와 동시에 develop의 마케팅 버전을 다음으로 올린다. TestFlight가 버전 단위로 빌드를 묶으므로 QA 빌드와 develop 빌드가 섞이지 않는다.
- **Merge 전략**: feature → develop은 Squash, release/* → main·develop은 Merge commit. release/* 머지에 squash를 쓰면 두 브랜치에 다른 해시가 생겨 이후 머지 충돌이 반복된다.
- **Firebase Remote Config**: 버전 체크, 피처 플래그 — `AppReducer.swift`의 `onAppear`에서 fetch
