# 배포 파이프라인 재설계 — git flow 조정 + 트리거 재배선

## Context

현재 `.github/workflows/deploy.yml`은 `release` 브랜치에 push될 때 `beta` lane(TestFlight 업로드)을 자동 실행한다. "release"라는 이름의 장수 브랜치가 실제로는 QA용 TestFlight 빌드를 만드는 용도로 쓰이고 있어 브랜치 룰과 실제 배포 의미가 어긋나 있다.

이번 작업은 **git flow를 조정하고 CI 트리거를 거기에 맞춰 재배선**한다.

### 브랜치 구조 변경

| | 기존 | 변경 |
|---|---|---|
| 기본 브랜치 | `release` | **`main`** |
| 출시 브랜치 | `release` (장수) | **`main`** (장수) |
| 통합 브랜치 | `develop` | `develop` (유지) |
| QA 브랜치 | 없음 | **`release/vX.Y.Z`** (임시, QA 종료 시 삭제) |

기존의 장수 `release` 브랜치는 폐기하고 `main`이 그 역할을 한다. QA는 릴리스마다 새로 따는 `release/vX.Y.Z` 임시 브랜치에서 진행한다.

> **사전 작업:** GitHub 레포 설정에서 기본 브랜치를 `release` → `main`으로 변경해야 한다. 현재 `origin/HEAD`가 `origin/release`를 가리키고 있다.

---

## 전체 플로우

```
feature/#131 ──squash──> develop
                            │
                            ├─[CI] TestFlight 업로드 (내부 전용)
                            │      + build/1.1.2-42 태그 자동 생성
                            │
                            └──> release/v1.1.2  (QA 시작 시 분기)
                                    │
                                    ├── QA 이슈 수정 커밋
                                    ├─[CI] TestFlight 업로드 (내부 전용)
                                    │
                                    ├──merge commit──> main
                                    │                    │
                                    │                    └── v1.1.2 태그 push
                                    │                         └─[CI] 심사용 빌드 → App Store Connect
                                    │
                                    └──merge commit──> develop  (싱크)

                                 release/v1.1.2 브랜치 삭제
```

**빌드는 두 종류뿐이다.**
- **내부 전용 빌드** (`develop`, `release/*`) → QA용. 심사 제출 불가.
- **심사용 빌드** (`v*.*.*` 태그) → App Store Connect 업로드.

### 최초 요청 대비 확정된 사항

- **PR 단계 빌드는 두지 않는다.** 검토 과정에서 라벨(`deploy:testflight`) opt-in 방식을 설계했으나 제외하기로 결정했다. 빌드는 `develop` 머지 이후부터 발생한다.
- **승격(promote) 방식은 채택하지 않는다.** `release/vX.Y.Z`에서 QA 이슈를 수정하면 develop 빌드와 코드가 달라지므로, develop 빌드를 심사에 승격할 수 없다. 태그 시점에 **재빌드**한다.
- 위 결정의 결과로 `testFlightInternalTestingOnly`가 유효해진다 (아래 ② 참고).

### 사전 조사에서 확인된 사실

**① 레포가 public이다** (`fairy-band/NewsLetter-iOS`, `"visibility": "public"`)
GitHub-hosted 표준 러너는 public 레포에서 **무제한 무료**다. macOS 러너도 포함이며 분 단위 과금이 적용되지 않는다. 빌드 빈도를 비용 때문에 제한할 이유는 없다.

**② `testFlightInternalTestingOnly` 옵션** (Xcode 26.3 `xcodebuild -help`로 확인)

> `testFlightInternalTestingOnly : Bool`
> When enabled, this build cannot be distributed via external TestFlight or the App Store. **This is recommended for pull requests, development branches**, and other builds that are not suitable for external distribution.

Xcode Organizer의 Distribute App → **"TestFlight Internal Only"** 메뉴에 대응하는 키다. 재빌드 방식을 택했으므로 `develop`/`release/*` 빌드에 적용해도 잃는 것이 없고, **QA 빌드가 실수로 심사에 올라가는 사고가 구조적으로 불가능해진다.**

**③ `method: "app-store"`는 deprecated다**
`xcodebuild -help` 기준 현재 이름은 `app-store-connect`다.

**④ `Info.plist`에 `ITSAppUsesNonExemptEncryption` 키가 없다**
이 상태로 업로드된 빌드는 App Store Connect에서 "수출 규정 준수 정보 누락"으로 멈추며, 매번 수동으로 넘기지 않으면 테스터가 설치할 수 없다.

**⑤ `skip_waiting_for_build_processing: true`가 changelog를 무력화하고 있다**
이 옵션이 `true`면 fastlane은 업로드만 하고 즉시 종료하며, processing 완료 이후에나 가능한 작업(changelog 반영 등)이 전부 스킵된다. 즉 현재 코드의 `changelog: last_git_commit[:message]`(`Fastfile:130`)는 사실상 적용되지 않고 있다.

---

## Merge 전략

| 경로 | 방식 | 이유 |
|---|---|---|
| `feature/*` → `develop` | **Squash and merge** | develop 히스토리가 기능 단위로 정리되고, `build/*` 태그를 달 커밋이 PR당 하나로 명확해진다 |
| `release/vX.Y.Z` → `main` | **Merge commit (`--no-ff`)** | 릴리스 단위를 히스토리에 남긴다 |
| `release/vX.Y.Z` → `develop` | **Merge commit (`--no-ff`)** | 싱크용 |
| `hotfix/*` → `main` | **Merge commit (`--no-ff`)** | 위와 동일 |

> **`release/*` → `main` / `develop`에 squash를 쓰지 말 것.** 같은 내용이 서로 다른 해시로 두 브랜치에 생성되어, 이후 develop↔main 머지마다 동일한 충돌이 반복된다.

GitHub 레포 설정에서 Squash와 Merge commit 두 방식을 모두 허용해두고, PR 종류에 따라 선택한다. (Rebase and merge는 비활성화 권장 — 위 표에서 쓰이지 않는다.)

---

## 변경 파일 1: `.github/workflows/deploy.yml`

### 1-1. 트리거 변경

```yaml
on:
  push:
    branches:
      - develop           # develop 머지 시 QA용 TestFlight 배포
      - 'release/**'      # QA 브랜치 수정사항 재검증용 TestFlight 배포
    tags:
      - 'v*.*.*'          # main의 릴리스 태그 push 시 심사용 빌드 배포

  workflow_dispatch:      # 수동 배포 / 재시도용
    inputs:
      lane:
        description: "실행할 Fastlane 레인"
        required: true
        default: "beta"
        type: choice
        options:
          - beta
          - release
```

- 기존 `branches: [release]` 트리거 제거 (장수 release 브랜치 폐기).
- `push`의 `branches`와 `tags`는 OR로 동작한다.
- 태그는 어느 브랜치를 가리키든 트리거된다(GitHub Actions는 태그 ref로 매칭). 운영상 `v*.*.*` 태그는 **`main`의 머지 커밋에만** 단다.
- `main` 브랜치 push 자체는 트리거하지 않는다. 머지만으로 빌드가 돌면 태그 빌드와 중복된다.

### 1-2. 권한 추가

`build/*` 태그를 CI가 push해야 하므로 워크플로 최상단에 추가:

```yaml
permissions:
  contents: write
```

`actions/checkout@v4`가 자격증명을 유지하므로 별도 토큰 설정은 불필요하다.

### 1-3. concurrency 직렬화

기존:
```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true
```

변경:
```yaml
concurrency:
  group: testflight-upload
  cancel-in-progress: false
```

**이유 — 빌드 번호 레이스.** `bump_version`은 `latest_testflight_build_number + 1` 방식이라 동시 실행에 안전하지 않다. 두 워크플로가 동시에 돌면 같은 빌드 번호를 받고, 나중에 업로드된 쪽이 Apple에서 거절된다. 기존 `deploy-${{ github.ref }}`는 ref가 다르면 병렬 실행되므로 develop과 release/* 가 겹치는 순간 터진다. 단일 그룹으로 묶어 직렬화한다.

`cancel-in-progress: false`인 이유: 진행 중인 업로드를 중간에 죽이면 빌드 번호만 소비하고 실패 상태가 남는다.

### 1-4. Lane 선택 로직

```yaml
run: |
  if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
    LANE="${{ github.event.inputs.lane }}"
  elif [[ "${{ github.ref }}" == refs/tags/* ]]; then
    LANE="release"
  else
    LANE="beta"
  fi
  echo "Selected lane: $LANE"
  bundle exec fastlane $LANE
```

- `workflow_dispatch` → 사용자가 고른 lane
- 태그 push → `release` lane (심사용)
- develop / release/* push → `beta` lane (내부 전용)

### 1-5. changelog용 환경변수 추가

"Fastlane 실행" step에 `id`를 부여하고 `env:`에 추가:

```yaml
      - name: Fastlane 실행
        id: fastlane
        env:
          # ... 기존 secret들 유지 ...
          SOURCE_BRANCH: ${{ github.ref_name }}
```

### 1-6. 빌드 태그 자동 생성 (develop 전용)

```yaml
      # develop 빌드에만 태그를 답니다. release/* 는 수명이 짧고
      # 최종적으로 main에 v태그가 붙으므로 별도 추적이 불필요합니다.
      - name: 빌드 태그 생성
        if: github.ref_name == 'develop' && steps.fastlane.outputs.build_tag != ''
        run: |
          TAG="${{ steps.fastlane.outputs.build_tag }}"
          git tag "$TAG"
          git push origin "$TAG"
```

생성되는 태그: `build/1.1.2-42` (마케팅 버전 - 빌드 번호)

**용도:** 출시 후 `v1.1.2` 태그를 달 때 커밋 해시를 역추적할 필요 없이 `git tag v1.1.2 build/1.1.2-42`처럼 태그명으로 커밋을 참조할 수 있다. 또한 "어느 커밋이 몇 번 빌드가 됐는지"가 git 히스토리에 남는다.

**감수할 점:** develop 머지마다 태그가 하나씩 쌓인다. `build/` prefix로 격리되므로 `git tag -l 'v*'`로 릴리스 이력만 조회할 수 있고, fetch 부담도 미미하다.

---

## 신규 파일 2: `.github/workflows/prepare-release.yml`

### 왜 필요한가

QA 시작 시 두 가지를 해야 한다.

1. `release/v1.1.2` 브랜치 생성
2. develop의 마케팅 버전 상향 (안 하면 TestFlight에서 QA 빌드와 develop 빌드가 섞인다)

**2번을 빠뜨리기 쉽다.** 그렇다고 `release/**` 브랜치 생성을 감지해 자동 실행하는 방식은 쓸 수 없다 — 브랜치 push라는 행위에는 **다음 버전을 minor로 올릴지 patch로 올릴지에 대한 정보가 담기지 않기** 때문이다.

| 다음 릴리스 성격 | 올려야 할 버전 |
|---|---|
| 새 기능 | 1.1.2 → **1.2.0** (minor) |
| 버그 수정만 | 1.1.2 → **1.1.3** (patch) |
| 대규모 개편 | 1.1.2 → **2.0.0** (major) |

이건 사람만 판단할 수 있으므로 자동 감지로는 minor 하드코딩 외에 방법이 없다.

**따라서 순서를 뒤집는다. 브랜치 생성 자체를 워크플로가 담당한다.** `workflow_dispatch`는 실행 시 입력을 받을 수 있으므로 bump 단위를 매번 선택할 수 있고, 브랜치 생성과 버전 상향이 한 트랜잭션으로 묶여 **2번 누락이 원천적으로 불가능해진다.**

### 워크플로

```yaml
name: 릴리스 브랜치 생성

on:
  workflow_dispatch:
    inputs:
      release_version:
        description: "릴리스할 버전 (예: 1.1.2) — release/v* 브랜치가 됩니다"
        required: true
        type: string
      next_bump:
        description: "develop을 올릴 단위"
        required: true
        default: "minor"
        type: choice
        options:
          - minor      # 1.1.2 → 1.2.0  (다음이 기능 릴리스)
          - patch      # 1.1.2 → 1.1.3  (다음이 버그 수정 릴리스)
          - major      # 1.1.2 → 2.0.0
          - custom     # next_version_custom 값을 그대로 사용
      next_version_custom:
        description: "custom 선택 시 develop 버전 (예: 2.0.0)"
        required: false
        type: string

permissions:
  contents: write

jobs:
  prepare:
    # 빌드는 하지 않지만 agvtool(= fastlane increment_version_number)이 필요해 macOS를 사용합니다.
    runs-on: macos-latest
    timeout-minutes: 15

    steps:
      - name: Checkout develop
        uses: actions/checkout@v4
        with:
          ref: develop
          fetch-depth: 0

      - name: Ruby 설정
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - name: 입력값 검증 및 다음 버전 계산
        id: plan
        run: |
          REL="${{ inputs.release_version }}"
          BUMP="${{ inputs.next_bump }}"
          CUSTOM="${{ inputs.next_version_custom }}"

          if [[ ! "$REL" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "::error::릴리스 버전 형식 오류: '$REL' (x.y.z 형식이어야 합니다)"
            exit 1
          fi

          if git ls-remote --exit-code --heads origin "release/v$REL" >/dev/null 2>&1; then
            echo "::error::release/v$REL 브랜치가 이미 존재합니다."
            exit 1
          fi

          IFS='.' read -r MAJOR MINOR PATCH <<< "$REL"
          case "$BUMP" in
            major)  NEXT="$((MAJOR + 1)).0.0" ;;
            minor)  NEXT="$MAJOR.$((MINOR + 1)).0" ;;
            patch)  NEXT="$MAJOR.$MINOR.$((PATCH + 1))" ;;
            custom) NEXT="$CUSTOM" ;;
          esac

          # App Store 마케팅 버전은 x.y.z 정수 형식만 허용됩니다 (1.2.0-beta 등 불가).
          if [[ ! "$NEXT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "::error::다음 develop 버전 형식 오류: '$NEXT'"
            exit 1
          fi

          echo "next_version=$NEXT" >> $GITHUB_OUTPUT
          echo "릴리스 브랜치: release/v$REL / develop 다음 버전: $NEXT"

      - name: Git 사용자 설정
        run: |
          git config user.name  "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

      - name: release 브랜치 생성
        run: |
          REL="${{ inputs.release_version }}"
          git switch -c "release/v$REL"
          bundle exec fastlane set_marketing_version version:"$REL"
          # 이미 해당 버전이면 커밋할 변경이 없습니다.
          if git diff --quiet; then
            echo "마케팅 버전이 이미 $REL 입니다. 커밋을 건너뜁니다."
          else
            git commit -am "release: v$REL 버전 업데이트"
          fi
          git push -u origin "release/v$REL"

      - name: develop 마케팅 버전 상향
        run: |
          NEXT="${{ steps.plan.outputs.next_version }}"
          git switch develop
          bundle exec fastlane set_marketing_version version:"$NEXT"
          git commit -am "chore: develop 마케팅 버전 $NEXT 으로 상향"
          git push origin develop
```

### 동작 순서

1. `develop` 체크아웃
2. 입력값 검증 (버전 형식, 브랜치 중복) 및 다음 develop 버전 계산
3. `release/v1.1.2` 브랜치 생성 → 마케팅 버전 확정 → push **(→ QA 빌드 자동 시작)**
4. `develop`으로 돌아와 계산된 버전으로 상향 → push

### 주의

- **`runs-on: macos-latest`인 이유:** 초기 설계에서는 `agvtool` 의존 때문이었으나, `set_marketing_version`이 pbxproj를 직접 수정하는 방식으로 바뀌어 이 제약은 사라졌다. 다만 `bundle install`이 다른 macOS 전용 gem에 걸릴 여지가 있어 우선 macOS를 유지한다. 빌드가 없어 소요는 짧고, public 레포라 비용도 없다. (추후 `ubuntu-latest`로 전환 가능)
- **develop 브랜치 보호 규칙이 있다면** `github-actions[bot]`의 push를 허용하도록 예외를 추가해야 한다.
- 이 워크플로는 `deploy.yml`과 별개 파일이며, `deploy.yml`의 트리거에는 영향을 주지 않는다.

---

## 변경 파일 3: `fastlane/Fastfile`

### 3-1. `build_app` lane 개명 → `build_ipa`, `internal_only` 파라미터 추가

**`build_app`은 fastlane 내장 액션(`gym`의 별칭) 이름과 충돌한다.** 파라미터를 넘기기 시작하면 혼선 위험이 있으므로 개명한다.

동시에 `export_method: "app-store"`(gym 파라미터, `Fastfile:98`)와 `export_options[:method]`(`Fastfile:110`)의 **중복 지정을 정리**한다. `export_options` 쪽이 우선하므로 `export_method` 줄을 제거한다.

```ruby
  desc "Release IPA 빌드 (업로드 없음)"
  desc "Usage: bundle exec fastlane build_ipa"
  desc "       bundle exec fastlane build_ipa internal_only:true"
  lane :build_ipa do |options|
    # CLI로 넘기면 문자열 "true"가 오므로 명시적으로 변환합니다.
    internal_only = options[:internal_only].to_s == "true"
    UI.message "TestFlight Internal Only: #{internal_only}"

    setup_ci
    match(
      type:           "appstore",
      readonly:       true,
      app_identifier: BUNDLE_ID
    )
    gym(
      scheme:            SCHEME,
      project:           PROJECT,
      configuration:     "Release",
      clean:             false,
      xcargs:            "-skipPackagePluginValidation -disablePackageRepositoryCache -skipMacroValidation DEVELOPMENT_TEAM=SWPBG3YXG5",
      output_directory:  "./build",
      output_name:       "NewsLetter.ipa",
      # 상세 로그
      xcpretty_report_html: "build/report.html",
      silent: false,
      suppress_xcode_output: false,
      # pbxproj의 Release 설정에 'match Development' 프로파일이 지정되어 있으므로
      # export 시점에 AppStore 프로파일로 오버라이드
      export_options: {
        method:                        "app-store-connect",
        signingStyle:                  "manual",
        teamID:                        "SWPBG3YXG5",
        # true면 외부 TestFlight/App Store 배포가 불가능한 내부 전용 빌드가 됩니다.
        testFlightInternalTestingOnly: internal_only,
        provisioningProfiles: {
          BUNDLE_ID => "match AppStore #{BUNDLE_ID}"
        }
      }
    )
  end
```

### 3-2. `set_marketing_version` lane 신설

`prepare-release.yml`이 호출한다. 마케팅 버전(`CFBundleShortVersionString`)을 지정한 값으로 설정한다.

```ruby
  desc "마케팅 버전 설정"
  desc "Usage: bundle exec fastlane set_marketing_version version:1.2.0"
  lane :set_marketing_version do |options|
    version = options[:version].to_s
    UI.user_error!("version 파라미터가 필요합니다.") if version.empty?
    # App Store 마케팅 버전은 x.y.z 정수 형식만 허용됩니다.
    UI.user_error!("버전 형식이 올바르지 않습니다: #{version}") unless version.match?(/\A\d+\.\d+\.\d+\z/)

    # 이 프로젝트는 GENERATE_INFOPLIST_FILE = YES 방식이라 버전의 실제 소스가
    # pbxproj의 MARKETING_VERSION입니다. agvtool 기반인 increment_version_number는
    # Info.plist를 찾지 못해 동작하지 않으므로 pbxproj를 직접 수정합니다.
    pbxproj_path = File.join(PROJECT_ROOT, PROJECT, "project.pbxproj")
    content = File.read(pbxproj_path)
    updated = content.gsub(/MARKETING_VERSION = [^;]+;/, "MARKETING_VERSION = #{version};")

    if content == updated
      UI.important "마케팅 버전이 이미 #{version} 입니다. 변경 사항이 없습니다."
    else
      File.write(pbxproj_path, updated)
      UI.success "마케팅 버전: #{version}"
    end
  end
```

> **`increment_version_number`를 쓰지 않는 이유 (실제 검증됨):** 이 프로젝트는 `GENERATE_INFOPLIST_FILE = YES`로 Info.plist를 자동 생성하며, 버전의 실제 소스는 `pbxproj`의 `MARKETING_VERSION`(346, 388줄)이다. fastlane의 `increment_version_number`와 그 기반인 `agvtool`은 Info.plist를 찾으려 하다가 실패한다.
>
> 로컬에서 `xcrun agvtool new-marketing-version 1.1.2`를 실행하면 성공 메시지가 나오지만 **실제로는 아무 파일도 변경되지 않는다** (`Cannot find "NewsLetter.xcodeproj/../YES"` — `GENERATE_INFOPLIST_FILE = YES`의 `YES`를 경로로 오인). 조용히 실패하므로 특히 주의해야 한다.
>
> 읽기(`get_version_number`)는 xcodeproj gem을 사용하므로 정상 동작한다.

기존 `bump_version`(빌드 번호 증가)과는 별개 lane이다. 이름이 비슷하므로 혼동하지 말 것 — `bump_version`은 **빌드 번호**, `set_marketing_version`은 **마케팅 버전**을 다룬다.

### 3-3. `bump_version`에서 빌드 태그명 내보내기

`increment_build_number` 직후에 추가:

```ruby
    # CI 후속 step이 build/* 태그를 만들 수 있도록 값을 내보냅니다.
    if is_ci && ENV["GITHUB_OUTPUT"]
      File.open(ENV["GITHUB_OUTPUT"], "a") do |f|
        f.puts("build_tag=build/#{version}-#{next_build}")
      end
    end
```

### 3-4. changelog 생성 private lane 추가

```ruby
  # TestFlight changelog 문구를 생성합니다. (어느 브랜치/커밋의 빌드인지 구분용)
  private_lane :testflight_changelog do
    branch = ENV["SOURCE_BRANCH"].to_s
    branch = git_branch if branch.empty?
    commit = last_git_commit

    "[#{branch}] #{commit[:abbreviated_commit_hash]}\n#{commit[:message]}"
  end
```

QA 담당자가 TestFlight에서 `[develop]` 빌드와 `[release/v1.1.2]` 빌드를 구분할 수 있어야 하므로 브랜치명을 표기한다.

### 3-5. `beta` / `release` lane 수정

```ruby
  desc "TestFlight 내부 전용 업로드 (develop / release/* push 시 자동 실행)"
  desc "이 빌드는 App Store 심사에 제출할 수 없습니다."
  lane :beta do
    write_xcconfig if is_ci
    write_google_service_plist if is_ci
    bump_version
    build_ipa(internal_only: true)
    upload_to_testflight(
      api_key:                           $api_key,
      app_identifier:                    BUNDLE_ID,
      skip_waiting_for_build_processing: false,
      distribute_external:               false,
      changelog:                         testflight_changelog
    )
    clean_build_artifacts
  end

  desc "App Store 제출용 빌드 업로드 (main의 vX.Y.Z 태그 push 시 자동 실행)"
  lane :release do
    write_xcconfig if is_ci
    write_google_service_plist if is_ci
    bump_version
    build_ipa
    upload_to_app_store(
      api_key:            $api_key,
      app_identifier:     BUNDLE_ID,
      submit_for_review:  false,
      automatic_release:  false,
      skip_screenshots:   true,
      force:              true
    )
    clean_build_artifacts
  end
```

**`skip_waiting_for_build_processing`을 `true` → `false`로 바꾸는 이유:** 위 Context ⑤ 참고. changelog를 실제로 반영하려면 필수다. 대신 Apple의 processing 완료까지 러너가 대기한다(통상 5~15분). public 레포라 러너 시간이 무료이므로 비용 문제는 없으나, concurrency 직렬화와 결합하면 1건당 총 소요가 늘어난다. **처리 속도가 더 중요하다면 이 항목만 `true`로 되돌리고 3-4를 생략하면 된다.**

---

## 변경 파일 4: `NewsLetter/NewsLetter/Resource/Info.plist`

수출 규정 준수 정보를 빌드에 포함시켜, 업로드 후 수동 확인 절차 없이 테스터가 바로 설치할 수 있게 한다. 앱이 HTTPS 등 면제 대상 암호화만 사용하므로 `false`로 설정한다.

```xml
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
```

`<dict>` 내부 알파벳 순서를 유지해 `FirebaseAppDelegateProxyEnabled`와 `LSApplicationQueriesSchemes` 사이에 삽입한다.

> 앱에 자체 구현 암호화나 면제 대상이 아닌 알고리즘이 추가되면 이 값을 재검토해야 한다.

---

## 변경 파일 5: `CLAUDE.md`

### 브랜치 네이밍 섹션 갱신

```markdown
| type | 용도 |
|---|---|
| `feature` | 새 기능 (`feature/#111`) |
| `fix` | 버그 수정 (`fix/#72`) |
| `hotfix` | 긴급 수정 (`hotfix/#117`) |
| `release` | QA 브랜치 (`release/v1.1.2`) — 릴리스마다 develop에서 분기, 출시 후 삭제 |

**장수 브랜치**: `main`(출시), `develop`(통합)
```

### 빌드 & CI 섹션에 추가

```markdown
- **배포 트리거**:
  - `develop` push → TestFlight 내부 전용 빌드 (QA용) + `build/X.Y.Z-N` 태그 자동 생성
  - `release/**` push → TestFlight 내부 전용 빌드 (QA 수정사항 재검증용)
  - `main`에 `vX.Y.Z` 태그 push → App Store Connect에 심사용 빌드 업로드
  - `main` 브랜치 push 자체는 빌드를 트리거하지 않음 (태그가 트리거)
- **내부 전용 빌드**: `beta` lane은 `testFlightInternalTestingOnly: true`로 빌드하므로 심사 제출이 **불가능**함. 심사용 빌드는 반드시 `main`의 태그를 통해 생성된다.
- **Merge 전략**: feature → develop은 Squash, release/* → main·develop은 Merge commit. release/* 머지에 squash를 쓰면 두 브랜치에 다른 해시가 생겨 이후 머지 충돌이 반복된다.
- **QA 기간 버전 분리**: `release/vX.Y.Z` 분기와 동시에 develop의 마케팅 버전을 다음으로 올린다. TestFlight가 버전 단위로 빌드를 묶으므로 QA 빌드와 develop 빌드가 섞이지 않는다.
- **릴리스 브랜치 생성**: 수동으로 만들지 말고 Actions의 **"릴리스 브랜치 생성"** 워크플로를 실행한다. 브랜치 생성과 develop 버전 상향이 함께 처리되며, 버전 증가 단위(minor/patch/major)를 실행 시 선택한다.
```

---

## 릴리스 절차 (운영 규칙)

1. **QA 시작** — GitHub → Actions → **"릴리스 브랜치 생성"** 워크플로를 실행한다.

   | 입력 | 값 예시 | 설명 |
   |---|---|---|
   | `release_version` | `1.1.2` | 이번에 릴리스할 버전 |
   | `next_bump` | `minor` | develop을 올릴 단위. 다음이 버그 수정 릴리스면 `patch` |
   | `next_version_custom` | (비움) | `custom` 선택 시에만 입력 |

   실행하면 `release/v1.1.2` 브랜치 생성 + QA 빌드 시작 + develop 버전 상향이 **한 번에** 처리된다. 터미널 작업이나 Xcode에서 버전을 고치는 수작업은 없다.

   > develop 버전 상향이 이 워크플로에 포함된 이유는 아래 "QA 기간 빌드 분리" 참고. 수동 절차였다면 빠뜨리기 쉬운 단계다.

2. **QA 진행** — 이슈가 나오면 `release/v1.1.2`에 직접 수정 커밋을 올린다. push마다 TestFlight에 새 빌드가 올라간다. QA는 TestFlight에서 **1.1.2 버전 묶음**의 빌드만 테스트한다.
3. **main 머지** — `release/v1.1.2` → `main` PR을 **Merge commit**으로 머지한다.
4. **태그 push** — main의 머지 커밋에 태그를 달아 심사용 빌드를 트리거한다.
   ```bash
   git switch main && git pull
   git tag v1.1.2
   git push origin v1.1.2
   ```
5. **심사 제출** — App Store Connect에서 업로드된 빌드를 선택해 제출한다. (`submit_for_review: false`이므로 제출은 수동)
6. **develop 싱크** — `release/v1.1.2` → `develop`을 **Merge commit**으로 머지한다.
7. **정리** — `release/v1.1.2` 브랜치를 삭제한다.

> **태그 시점 주의:** `vX.Y.Z` 태그는 빌드 트리거이므로 **심사 제출 전**에 달아야 한다. (검토 과정에서 "스토어 공개 후 태그" 안이 나왔으나, 그것은 승격 방식을 전제로 한 것이었다. 재빌드 방식에서는 태그가 빌드를 만드는 시작점이다.)
>
> 심사가 거절되어 빌드를 다시 만들어야 하면 `v1.1.3` 등 다음 패치 버전으로 진행한다. 이미 push한 태그는 되도록 삭제하지 않는다.

---

## QA 기간 빌드 분리

### 문제

`release/v1.1.2` QA가 진행되는 동안에도 develop에는 다음 릴리스 작업이 계속 머지된다. 두 브랜치 모두 TestFlight로 빌드가 올라가므로 목록에서 섞인다.

```
빌드 45  [develop]           ← 다음 릴리스. QA 대상 아님
빌드 44  [release/v1.1.2]    ← QA 대상
빌드 43  [develop]           ← 아님
빌드 42  [release/v1.1.2]    ← QA 대상
```

TestFlight 앱은 최신 빌드를 먼저 노출하므로, QA 담당자가 무심코 45번을 설치하면 엉뚱한 빌드를 테스트하게 된다. changelog의 `[브랜치]` 표기만으로는 실수를 막기 어렵다.

### 해결: release 분기 시 develop의 마케팅 버전을 올린다

`prepare-release.yml`(신규 파일 2)이 이 문제를 담당한다. `release/v1.1.2` 분기와 **동시에** develop을 `1.2.0`으로 올리면 TestFlight가 **마케팅 버전 단위로 빌드를 묶어 표시**하므로 두 흐름이 시각적으로 완전히 분리된다.

```
── 1.2.0 ────────────────
   빌드 2   [develop]         ← 다음 릴리스 작업
   빌드 1   [develop]

── 1.1.2 ────────────────
   빌드 44  [release/v1.1.2]  ← QA는 이 묶음만 본다
   빌드 42  [release/v1.1.2]
```

빌드 번호도 자연히 분리된다. `bump_version`은 `latest_testflight_build_number(version:)`로 **해당 마케팅 버전의** 최신 빌드를 조회하므로 1.2.0은 1번부터 새로 시작한다. 해당 버전의 빌드가 없을 때 0으로 초기화하는 `rescue`가 `Fastfile:76`에 이미 있어 **코드 수정은 불필요**하다.

이는 git flow의 표준 관행이기도 하다 — release 브랜치를 따는 순간 develop은 다음 버전으로 넘어간다.

**올릴 단위(minor/patch/major)는 다음 릴리스의 성격에 따라 달라지므로 워크플로 실행 시 매번 선택한다.** 자동 감지 방식을 쓰지 않은 이유는 신규 파일 2의 "왜 필요한가" 참고.

### 보조 수단 (선택): TestFlight 그룹 분리

버전 분리만으로 혼선이 남는다면, App Store Connect에서 내부 테스터 그룹을 `QA` / `Dev` 둘로 나누고 브랜치에 따라 배포 대상을 다르게 하는 방법이 있다. QA 담당자를 `QA` 그룹에만 배정하면 develop 빌드가 아예 노출되지 않는다.

```ruby
  private_lane :testflight_groups do
    ENV["SOURCE_BRANCH"].to_s.start_with?("release/") ? ["QA"] : ["Dev"]
  end
```

```ruby
    upload_to_testflight(
      # ...
      groups: testflight_groups
    )
```

> **검증 필요:** fastlane의 `groups` 옵션은 본래 외부 테스터 그룹용으로 문서화되어 있어, 내부 테스터 그룹에도 적용되는지 확인이 필요하다. (`skip_waiting_for_build_processing: false`가 전제이며, 이는 이미 충족된다.)
>
> 우선 버전 분리만 적용하고, 실제로 혼선이 관측될 때 도입한다.

---

## 실행 순서

### 착수 시점 브랜치 현황 (2026-07-31 기준)

| 브랜치 | 최신 커밋 | 상태 |
|---|---|---|
| `main` | 2025-07-15 `[#6] feat: App, AppView, AppReducer 구현` | **318커밋 뒤처짐**, 사실상 방치 |
| `release` | 2026-07-25 `Merge branch 'develop' into release` | 실질적 최신 (기본 브랜치) |
| `develop` | 2026-07-22 `[#128] feat: 카테고리 필터 기능 추가` | — |

- `main`은 `release`의 **조상**이다 → fast-forward 가능, 히스토리 재작성 불필요.
- `develop`과 `release`의 **트리 내용은 완전히 동일**하다. 차이는 머지 커밋 2개(`f4a653e`, `ac72787`)뿐이라 백머지에 충돌이 없다.
- 진행 중인 **PR #132**(`[#131] feat: 온보딩 후 직군 변경 바텀시트`, 6커밋/14파일)는 앱 소스만 수정한다. `.github`, `fastlane`, `Info.plist`를 건드리지 않아 이 작업과 **파일 충돌이 없다.**
- 브랜치 보호 규칙은 현재 전부 없음 (`protected: false`).

### 왜 main에 먼저 넣는가

1. **`workflow_dispatch` 워크플로는 파일이 기본 브랜치에 있어야 Actions UI에 "Run workflow" 버튼이 나타난다.** develop에만 있으면 `prepare-release.yml`을 실행할 방법이 없다.
2. 새 `deploy.yml`에서 **main push는 빌드를 트리거하지 않으므로**(태그만 트리거) main 머지는 안전하며, 첫 빌드 리스크를 develop 머지 시점으로 미룰 수 있다.

### Phase 0 — 브랜치 기반 정리

```bash
git fetch origin --prune
git push origin origin/release:main      # main을 release로 fast-forward
```

> 현재 `deploy.yml`은 `release` push만 트리거하므로 이 단계에서 **빌드가 돌지 않는다.**

그다음 **GitHub 웹에서 기본 브랜치를 `release` → `main`으로 변경**한다 (Settings → Branches → Default branch).

### Phase 1 — CI 작업을 main에 먼저

```bash
git switch main && git pull
git switch -c hotfix/cicd-refactor
```

변경 파일: `deploy.yml`, `prepare-release.yml`(신규), `Fastfile`, `Info.plist`, `CLAUDE.md`

→ `main`으로 PR을 열고 **Merge commit**으로 머지한다.

- 빌드가 돌지 않는다 (main push는 트리거가 아니다)
- 이 시점부터 `prepare-release.yml`이 Actions UI에 나타난다

> **Merge commit을 쓰는 이유:** main과 develop에 같은 커밋 해시가 흘러가야 한다. squash를 쓰면 두 브랜치에 다른 해시의 동일 내용이 생겨 "Merge 전략" 섹션에서 경고한 반복 충돌이 시작된다.

### Phase 2 — develop 동기화 = 첫 빌드 검증

`main` → `develop` PR을 **Merge commit**으로 머지한다. main의 머지 커밋 2개까지 함께 흘러가 브랜치 그래프도 정리된다.

**여기서 새 파이프라인의 첫 빌드가 발생한다.** 아래 4가지를 확인한다.

1. 빌드가 ASC의 **심사 제출 대상 목록에 나타나지 않는지** (internal only)
2. `build/1.1.1-N` 태그가 원격에 생성됐는지 (`permissions: contents: write`)
3. changelog에 `[develop] <해시>` 표기가 있는지
4. 수출 규정 경고 없이 테스터에게 바로 노출되는지

> **첫 빌드는 실패할 수 있다.** PR 단계 빌드를 두지 않기로 했으므로 사전 검증 기회가 없다. 실패 시 롤백보다 develop에 수정 커밋을 얹는 쪽이 낫다. `permissions: contents: write` 누락으로 태그 step에서 실패하는 것이 가장 흔한 케이스다.

### Phase 3 — PR #132 머지

**Squash and merge**로 머지한다. 두 번째 빌드가 돌면서 파이프라인 안정성이 확인된다.

### Phase 4 — 정리 (검증 완료 후)

구 `release` 브랜치를 삭제한다. 빌드가 두어 번 정상 동작하는 것을 확인한 뒤에 진행한다.

---

## 검증 방법

1. **develop push** — develop에 머지 → `beta` lane 트리거 확인.
2. **internal only 반영 (핵심)** — 업로드된 빌드가 App Store Connect의 **심사 제출 대상 빌드 목록에 나타나지 않는지** 확인. 이 검증이 이번 변경의 안전장치를 담보한다.
3. **빌드 태그** — develop 빌드 후 `build/1.1.2-42` 태그가 원격에 생성됐는지 확인. `permissions: contents: write` 누락 시 이 step에서 실패한다.
4. **changelog** — TestFlight "테스트 정보"에 `[develop] a1b2c3d` + 커밋 메시지가 표시되는지 확인. (`skip_waiting_for_build_processing: false` 변경이 먹었는지 검증하는 항목)
5. **수출 규정** — 업로드된 빌드가 "수출 규정 준수 정보 누락" 상태 없이 바로 테스터에게 노출되는지 확인.
6. **release/* push** — `release/v1.1.2` 브랜치를 push → `beta` lane 트리거 및 changelog의 `[release/v1.1.2]` 표기 확인. **태그는 생성되지 않아야 함.**
7. **릴리스 브랜치 생성 워크플로** — "릴리스 브랜치 생성"을 `release_version: 1.1.2`, `next_bump: minor`로 실행 → ① `release/v1.1.2` 브랜치 생성 및 QA 빌드 시작, ② develop이 `1.2.0`으로 상향 커밋되는지 확인.
   - `next_bump: patch`로도 실행해 `1.1.3`이 나오는지 확인 (minor 하드코딩이 아님을 검증)
   - 이미 존재하는 `release_version`으로 실행 시 브랜치 중복 에러로 중단되는지 확인
   - 잘못된 버전 형식(예: `1.1`)으로 실행 시 검증 단계에서 실패하는지 확인
8. **QA 기간 버전 분리** — 위 실행 후 develop에 머지 → TestFlight에서 1.1.2와 1.2.0이 **서로 다른 버전 묶음으로 표시**되고, 1.2.0 빌드 번호가 1부터 시작하는지 확인.
9. **태그 push** — main에 `v1.1.2` 태그 push → `release` lane 트리거 확인. 업로드된 빌드는 심사 제출이 **가능해야** 한다 (2번과 반대).
10. **기존 트리거 제거** — 구 `release` 브랜치에 push해도 워크플로가 트리거되지 않는지 확인.
11. **main push** — main에 머지만 하고 태그를 달지 않았을 때 빌드가 돌지 않는지 확인.
12. **workflow_dispatch** — 수동 실행 시 lane 선택이 정상 동작하는지 확인.

---

## 향후 개선 (이번 범위 밖)

**빌드 번호 레이스의 근본 해결.** 이번에는 concurrency 직렬화로 회피하지만 큐 지연이라는 비용을 치른다. `bump_version`이 `latest_testflight_build_number`(원격 조회 + 경쟁 조건)에 의존하는 대신 `github.run_number`처럼 **단조 증가가 보장된 값**을 쓰면 직렬화 없이 충돌이 원천 차단된다. 현재 TestFlight 빌드 번호와의 연속성을 먼저 확인해야 하므로 별도 작업으로 분리한다.

**`build/*` 태그 정리.** develop 머지가 누적되면 태그가 쌓인다. 필요 시 오래된 `build/*` 태그를 일괄 삭제하는 스크립트나 주기적 워크플로를 추가한다.
