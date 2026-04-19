# NEXT_SESSION.md : stetkeep 세션 재개 체크포인트

**마지막 업데이트**: 2026-04-20 (mdbrain → stetkeep rename 완료, v0.4.0 prep)
**다음 체크인 예상**: CJ 외부 시스템 액션 (npm publish, GitHub rename, Anthropic 재제출) 완료 후

---

## 🔄 BREAKING: 2026-04-20 프로젝트 rename 완료 (v0.4.0)

**이유**: mediaire 사의 `mdbrain` 의료 AI 소프트웨어 (CE 인증 2019-01-21) 와 브랜드 충돌 발견. launch 다음날이라 rebrand 비용 최저점.

**새 이름**: `stetkeep` (라틴어 "stet" = "let it stand" 편집 교정 기호에서 파생). 짧은 alias `stet` 도 별도 패키지로 publish.

**로컬 레포 상태 (완료)**:
- [x] 코드/문서 일괄 sed (mdbrain → stetkeep, 175 occurrences across 27 files)
- [x] `bin/mdbrain.js` → `bin/stetkeep.js` rename
- [x] `package.json` + `.claude-plugin/plugin.json` version 0.3.0 → 0.4.0
- [x] `package.json` `bin` 에 `stet` alias 추가 (CLI 이름만, npm 패키지 아님)
- [x] CHANGELOG v0.4.0 엔트리 추가 (기존 v0.3.0 및 이하 보존)
- [x] CLAUDE.md 릴리스 프로세스: 3곳 version bump
- [x] `.github/workflows/mirror-sync-check.yml` CI workflow 생성
- [x] README `.claude/settings.json` 덮어쓰기 경고 blockquote
- [x] `mdbrain-0.3.0.tgz` stale artifact 삭제
- [x] `.release-notes-v0.3.0.md` 와 CHANGELOG v0.3.0 이하 비수정 (released artifact 보존)
- [x] 미러 SYNC 유지 (`diff -rq agents/ .claude/agents/` 등 전부 sync)
- [x] **GitHub repo rename 완료**: `chanjoongx/mdbrain` → `chanjoongx/stetkeep` (자동 redirect 유지)
- [x] **Push 완료**: main branch origin/main 에 반영 (commit c675a4a)
- [x] **npm publish stetkeep@0.4.0 성공** (2026-04-20)
- [x] **stet proxy 패키지 포기**: npm typosquatting 정책 (403 Forbidden) 으로 unscoped publish 불가. 관련 문서 (CHANGELOG, release notes, CLAUDE, 메모리) 정리 완료 → 새 commit 필요

**CJ 외부 시스템 액션 (남은 것)**:

### 완료 상태 (2026-04-20)
- [x] Anthropic 마켓 support chat → withdrawal 불가, "자연 reject + stetkeep 재제출" clearance 받음. Ticket ID `215473982749776`
- [x] Git commit + push (main branch c675a4a)
- [x] GitHub repo rename: `chanjoongx/mdbrain` → `chanjoongx/stetkeep`
- [x] Local git remote 갱신
- [x] `npm publish stetkeep@0.4.0`

### 2026-04-20 종료 시 완료 (추가)
- [x] `stet` proxy 제거 (commit c19947f)
- [x] `npm deprecate mdbrain@"<=0.3.0"` (정확한 메시지로 live 작동 확인)
- [x] `git tag v0.4.0 && git push origin v0.4.0`
- [x] `gh release create v0.4.0` (웹 UI)
- [x] README ASCII art MDBRAIN → STETKEEP (commit 1e355e1)
- [x] 4인 전문가 audit + v0.4.1 patch (commit 290f3c2): bin exit code, install.js legacy regex, ps1 parity, hook false-positive fix, commands argument-hint + $ARGUMENTS, subagent description 개선, metadata alignment
- [x] `stetkeep@0.4.1` npm publish
- [x] `git tag v0.4.1 && git push origin v0.4.1`
- [x] GitHub Release v0.4.1 (웹 UI)
- [x] `.github/workflows/publish.yml` OIDC 워크플로 (commit aa23a82)
- [x] npm Trusted Publisher 등록 (chanjoongx/stetkeep + publish.yml)
- [x] Publishing access: Require 2FA + disallow tokens (maximum security)

### 남은 것 (자율 타이밍)
- [ ] Anthropic 마켓 stetkeep 재제출 (웹 포털 `clau.de/plugin-directory-submission`)
- [ ] 이력서 v11 업데이트 (v10 → v11: stetkeep + new tagline + OIDC trusted publishing bullet)
- [ ] Benchmark SPEC 실행 (`benchmark/SPEC.md` → real numbers, v0.5 prep)
- [ ] (선택) `stetkeep.com` 도메인 등록
- [ ] (장기) v0.5 per-language variants (CRAFT.python.md 등)

---

### 이하 과거 CJ 외부 시스템 액션 전체 목록 (reference):

### Anthropic 마켓 withdrawal 이메일 (즉시, 2분)
- **받는곳**: Anthropic 플러그인 마켓 contact (support@anthropic.com 또는 제출 confirmation reply-to)
- **Subject**: `Withdraw pending plugin submission — mdbrain (2026-04-19)`
- **본문 draft**:
  ```
  Hi Anthropic marketplace team,

  I submitted a Claude Code plugin called mdbrain on 2026-04-19 
  (submitter email: cj@chanjoongx.com, npm: https://www.npmjs.com/package/mdbrain).

  While my submission is pending review, I discovered that 'mdbrain' is 
  an established CE-certified medical AI software for brain MRI analysis, 
  made by mediaire (https://mediaire.ai/en/mdbrain/). To avoid trademark 
  confusion and protect both projects, I am renaming my plugin.

  Please withdraw the current submission. I will resubmit under the new 
  name 'stetkeep' (from the editor's mark 'stet' — "let it stand") within 
  the next few days. The plugin is functionally identical; only the name 
  and URLs change.

  If no withdrawal is possible from your side, please feel free to reject 
  the current submission when you reach it. I understand.

  Thank you for your patience,
  CJ Kim
  cj@chanjoongx.com
  ```

### 실행 커맨드 시퀀스 (순서 그대로 복사/실행)

```bash
cd C:/Users/craig/Desktop/mdbrain

# 1. 상태 확인
git status
git diff --cached --stat | head -30   # 규모 확인 (약 30 files 변경 예상, sed 한 27 + 생성분)

# 2. 커밋 (rename + v0.4.0 prep 번들)
git add -A
git commit -m "$(cat <<'EOF'
v0.4.0: rename mdbrain to stetkeep

Trademark conflict with mediaire's mdbrain medical AI (CE-certified 2019)
discovered one day after v0.3.0 launch. Rebranded to stetkeep (from
editorial mark 'stet' meaning 'let it stand') while npm download count
was effectively zero to minimize migration cost.

- Bulk rename across 27 files (175 occurrences)
- Add stet/ as thin proxy npm package (npm install stet also works)
- Register stet as bin alias in main package (both CLIs after either install)
- Version bump to 0.4.0 in package.json, plugin.json, stet/package.json
- CHANGELOG v0.4.0 entry with migration guide; v0.3.0 and below preserved
- Pre-rename polish bundled: settings.json overwrite warning (README),
  mirror-sync-check GitHub Action
- Release notes artifact (.release-notes-v0.3.0.md) preserved verbatim

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

# 3. GitHub repo rename (웹 UI)
#    https://github.com/chanjoongx/mdbrain/settings
#    → General → Repository name: stetkeep → Rename
#    (자동 URL redirect 유지)

# 4. 로컬 remote 갱신
git remote set-url origin https://github.com/chanjoongx/stetkeep.git
git remote -v   # 검증

# 5. push
git push origin main

# 6. npm publish 메인 패키지 (2FA passkey)
npm publish --access public

# 7. npm publish stet proxy (메인 이후 순차, dependency resolve 필요)
cd stet
npm publish --access public
cd ..

# 8. 구 mdbrain deprecate
npm deprecate mdbrain@"<=0.3.0" "Renamed to stetkeep due to trademark conflict with mediaire's medical software. npm i stetkeep. https://github.com/chanjoongx/stetkeep"

# 9. tag + push
git tag v0.4.0
git push origin v0.4.0

# 10. GitHub Release 생성 (.release-notes-v0.4.0.md 이미 생성됨)
gh release create v0.4.0 -F .release-notes-v0.4.0.md --title "v0.4.0: renamed to stetkeep"

# 11. Anthropic 마켓에 stetkeep 재제출 (웹 포털)
#     https://claude.ai/settings/plugins 또는 공식 submission 포털

# 12. 이력서 v11 (바탕화면 .tex 파일)
#     resume_chanjoong_kim_en_v10.tex → v11: mdbrain → stetkeep
#     tagline 변경: "the editor's mark 'stet' applied to code"

# 13. (선택) 도메인 등록
#     stetkeep.com Cloudflare / Namecheap / 원하는 등록기관
```

### 재개 시나리오

세션 종료 후 재개:
```bash
cd C:/Users/craig/Desktop/mdbrain
claude
```
Claude 첫 메시지: `docs/NEXT_SESSION.md 먼저 읽어줘. 위의 CJ 외부 시스템 액션 부분 어디까지 했는지 점검 후 다음 단계.`

---

## 📍 현재 위치

### 라이브 아티팩트
| 아티팩트 | 상태 | URL |
|---|---|---|
| npm 패키지 | ✅ Published | https://www.npmjs.com/package/stetkeep (v0.3.0, shasum `a34b668`) |
| GitHub 레포 | ✅ HEAD `248d568` | https://github.com/chanjoongx/stetkeep |
| GitHub Release | ✅ Pre-release | https://github.com/chanjoongx/stetkeep/releases/tag/v0.3.0 |
| git tag | ✅ `v0.3.0` pushed | |
| Anthropic 공식 마켓 | ⏳ **리뷰 대기** (2026-04-19 제출) | https://claude.ai/settings/plugins |
| Self-hosted 마켓 | ✅ Live | `/plugin marketplace add chanjoongx/stetkeep` |

### 오늘(2026-04-19) 한 일 요약

**C+ → SSS 런칭 여정. 하루 종일 실행.**

1. **npm 계정 생성** (`chanjoongx`, email: `cj@chanjoongx.com`) + 2FA Google Passkey
2. **package.json 메타데이터 정비**: author/repo/keywords/files 필드 완성
3. **플러그인 매니페스트 정비**: 3개의 undocumented quirk 발견 후 수정 (아래 섹션)
4. **크로스플랫폼 테스트**: tarball + global install + 실 Claude Code 세션에서 `/brain-scan` 작동 확인
5. **npm publish 성공**: 첫 시도는 `provenance: true` 로 실패, 제거 후 재시도 성공
6. **git tag + GitHub Release 생성**: pre-release, `.release-notes-v0.3.0.md` 를 Notepad로 복사해 마크다운 보존
7. **Anthropic 공식 마켓 제출**: 2페이지 폼 작성 완료. Platforms: Claude Code + Cowork. License: MIT. Privacy: `PRIVACY.md` 추가 후 링크 제출. Submitter: `cj@chanjoongx.com`.
8. **PRIVACY.md 추가**: Verified 배지 필수 요건. "no data collection, zero telemetry" 명시. commit `248d568`.

---

## 📄 이력서 상태 (2026-04-19)

### 파일 위치 (바탕화면)
- **EN**: `C:\Users\craig\Desktop\resume_chanjoong_kim_en_v10.tex`
- **KR**: `C:\Users\craig\Desktop\resume_chanjoong_kim_kr_v10.tex`

### 현재 버전: v10, "Anthropic 승인 가정" 모드

**프로젝트 타이틀 (영문/한글 공통)**:
```latex
\textbf{stetkeep - \textsc{Anthropic Verified}}
```
→ PDF 렌더: "stetkeep - Anthropic Verified" (small caps)

**Bullet 1 (영문)**:
> Designed and shipped an open-source Claude Code plugin that prevents AI coding assistants from over-refactoring via XML-structured behavior protocols and a **16-entry false-positive pattern catalog**; distributed via npm and Anthropic's official plugin marketplace (zero runtime dependencies, Node 20+)

**Bullet 2 (영문)**:
> Architected a **5-layer** mechanical enforcement system (permission deny-lists, PreToolUse hooks, 3 tool-scoped subagents, path-scoped rules, behavioral protocols); built cross-platform Node CLI supporting macOS, Linux, and Windows

**배치**: Projects #2 (MyOfferAgent 바로 아래, Toss Mini-Apps 위)

**Skills 업데이트**:
- 도구: `npm publishing` 추가
- 분야: LLM Applications 에 `Guardrails` 추가

### 주요 설계 결정 (오늘 iteration)

1. **타이틀 포맷 선택 과정**:
   - A: `stetkeep` 단독 → 차별화 약함, 기각
   - B: `stetkeep: Claude Code Plugin` → "Plugin" generic, 밋밋
   - C: `stetkeep - ANTHROPIC VERIFIED` (ALL CAPS) → 마케팅 브로셔 느낌, 기각
   - **D (최종): `stetkeep - \textsc{Anthropic Verified}`** (small caps)
     - 이유: 템플릿이 이미 `\scshape` 사용하므로 일관성. Anthropic 브랜드 활용이 가장 강력한 시그널.

2. **Bullet 1 리팩터링**:
   - 이전: "Anthropic Verified" 를 bullet 안에 bold 로 포함
   - 현재: 타이틀로 옮기고 bullet 에서는 제거
   - 이유: 중복 제거. bullet 앞부분이 문제 해결 (`prevents AI coding assistants from over-refactoring`) 중심으로 재구성 가능.

3. **Skills Areas 확장**:
   - 이전: `LLM Applications (RAG, Prompt Engineering)`
   - 현재: `LLM Applications (RAG, Prompt Engineering, Guardrails)`
   - 이유: stetkeep 의 safety/guardrails 각도 반영

### 사용 조건 (중요)

| 상황 | 사용 가능? | 대처 |
|---|---|---|
| Anthropic 승인 완료 (이메일 수신) | ✅ 현재 v10 그대로 사용 | 즉시 제출 가능 |
| 리뷰 대기 중 (현재) | ❌ 허위 기재 리스크 | 타이틀 `stetkeep - \textsc{Claude Code Plugin}` 으로, bullet 1 의 distribution 부분 `submitted to Anthropic's official plugin marketplace` 로 교체한 임시 버전 생성 후 사용 |
| 거절 | ❌ | 이유 분석 후 전체 재검토 |

### 이력서 업데이트 타이밍 (승인 후)

| 이벤트 | 추가할 메트릭 |
|---|---|
| Anthropic 공식 마켓 승인 | 현재 v10 그대로 사용 가능 |
| npm 100+ weekly downloads | 첫 bullet 끝에: "100+ weekly npm downloads" |
| GitHub 50+ stars | header 또는 bullet 끝 추가 |
| v0.3.1 benchmark 결과 | "false-positive pattern catalog (X% reduction in over-refactoring, n=50)" |

---

## ⏳ 다음 세션 할 일 (우선순위)

### 🥇 Anthropic 마켓 리뷰 결과 대기 (기간 불확정)
- 현실적 추정: **몇 주에서 몇 달** (CJ 본인 추정. 공식 SLA 없음. Anthropic 플러그인 프로그램 초기 단계라 리뷰 큐 크기도 가변)
- 채용 시즌이 대기와 겹칠 수 있으므로 이력서는 **임시 버전 (`Claude Code Plugin` 타이틀 + "submitted to Anthropic's official marketplace") 선 배포** 권장
- 리뷰 이메일: `cj@chanjoongx.com` → gmail 포워딩
- **승인 시**: 공식 마켓 등재. 트래픽 유입 모니터링. `npm install` 카운트 추적. 이력서 v10 즉시 사용 가능.
- **수정 요청 시**: 리뷰어 피드백 반영 → 필요 시 v0.3.1 패치 → 재제출.
- **거절 시**: 이유 분석 → 전략 재조정.

### ⏱ 대기 기간 동안 할 일 (유휴 방지)
- `benchmark/SPEC.md` 실행 → v0.3.1 때 "Results pending" 제거. 수치 나오면 README + 이력서 bullet 강화 (`stetkeep` 의 승인 여부와 무관한 자산)
- npm 다운로드 / GitHub star 유기적 트래픽 모니터링
- v0.4.0 feature set 기획 (사용자 피드백 수집 후)

### 🥈 v0.3.1+ 로드맵 (benchmark 결과 반영)
- `benchmark/SPEC.md` 에 정의된 50 케이스 / 3 조건 / Cohen's κ ≥ 0.75 / paired bootstrap 통계
- 결과 나오면 README + ARCHITECTURE 에 근거 수치 추가
- 릴리스 노트에서 "Results pending" 을 실제 수치로 교체

### 🥉 README / 문서 개선 (v0.3.1 prep, 2026-04-20 반영 분 포함)

**이미 완료** (2026-04-20):
- [x] Install 섹션을 Quickstart (1-step, C/D/E) vs Recommended (2-step, A-E full) 로 재구조화
- [x] 5-layer 중 A/B 만 settings.json 의존임을 명시
- [x] README CHANGELOG 앵커 링크 오류 수정 (`#030` 제거)
- [x] Repo layout 에 `.claude/` 도그푸딩 미러 + PRIVACY.md 반영
- [x] Verify 섹션에 install mode 조건부 명시
- [x] LICENSE 섹션 `[MIT](LICENSE)` 링크
- [x] Roadmap 갱신 (v0.3.1 benchmark, v0.4 interactive init, v0.5 per-language, v0.6 삭제)
- [x] Windows 한계 Requirements 섹션에 명시
- [x] ARCHITECTURE §3 레이아웃 관점 주석 (npm vs plugin)
- [x] CONTRIBUTING.md 도그푸딩 섹션 추가
- [x] CLAUDE.md 릴리스 프로세스: version bump 3곳 (package / plugin / marketplace) 동시화 명시
- [x] CLAUDE.md 하드 제약: `.claude/` 미러 동반 업데이트 의무 명시
- [x] package.json files 에 PRIVACY.md 추가

**미완료** (플랜 수립 완료, Execute 대기):

#### 1. `.claude/settings.json` 덮어쓰기 경고
- **위치**: `README.md` 의 `### Recommended (2 steps, full mechanical enforcement)` 섹션, `cp .claude/settings.example.json .claude/settings.json` 코드 블록 직후
- **삽입 내용** (blockquote):
  ```markdown
  > **If you already have `.claude/settings.json`** (from other tooling or a previous install): `cp` will overwrite it. Run `ls .claude/settings.json` first; if it exists, merge the `permissions` and `hooks.PreToolUse` blocks from `settings.example.json` manually instead of overwriting.
  ```
- **근거**: `lib/install.js:99-102` 는 `existsSync + !force` 로 skip 방어하지만, README 의 `cp` 직접 실행은 이 방어 우회
- **Execute 전 사전 검증**: 불필요 (문서 추가만)

#### 2. `.claude/` 미러 drift 방지 CI
- **신규 파일**: `.github/workflows/mirror-sync-check.yml`
- **작동**: push to main + 모든 PR 에서 `diff -rq` 로 세 쌍 검증, drift 감지 시 CI fail
- **YAML 초안**:
  ```yaml
  name: Mirror sync check

  on:
    push:
      branches: [main]
    pull_request:

  jobs:
    verify-mirrors:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: agents/ matches .claude/agents/
          run: diff -rq agents/ .claude/agents/
        - name: commands/ matches .claude/commands/
          run: diff -rq commands/ .claude/commands/
        - name: hooks/ matches .claude/hooks/ (excluding plugin-only hooks.json)
          run: diff -rq hooks/ .claude/hooks/ --exclude=hooks.json
  ```
- **Execute 전 사전 검증** (5 개 모두 통과해야 안전):
  1. `ls .github/workflows/` 존재 여부 (없으면 폴더 생성 필요)
  2. `ls .claude/hooks/` 로 `hooks.json` 존재 여부 확인 (`--exclude` 정확성)
  3. `diff -rq agents/ .claude/agents/` → no output
  4. `diff -rq commands/ .claude/commands/` → no output
  5. `diff -rq hooks/ .claude/hooks/ --exclude=hooks.json` → no output
- **리스크**: 현 미러가 drift 상태면 첫 push 부터 CI red. 사전 검증 필수.

**추가 완료** (2026-04-20):
- [x] XML recommendation 주장에 Anthropic 공식 링크 추가 (README + ARCHITECTURE).
  - URL: `https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags`
  - 검증: 301 redirect 로 `platform.claude.com` 으로 자동 이동 확인 (Anthropic 2026 브랜드 마이그레이션 중)
  - 공식 인용: "XML tags can be a game-changer as they help Claude parse your prompts more accurately"

### 🏅 향후 고려
- Anthropic 공식 마켓 PR (anthropics/claude-plugins-official): Verified 배지 획득 후 고려
- Reddit / HN / Twitter 런칭 포스트: 마켓 승인 후
- v0.4.0 feature set 기획: 사용자 피드백 수집 후

---

## 🔑 중요 결정 기록

### 포지셔닝 (2026-04-19 아침)
- **제거된 positioning**: "mechanical guardrails via hooks", "tool-scoped subagents". April 2026 기준 TDD-Guard, VoltAgent 등이 이미 선점. 차별화 못 함.
- **선택된 2 pillar**:
  1. **XML-structured protocol framework**: Anthropic 공식 prompting guide 의 XML tag 권고 반영
  2. **False-positive catalog (16 entries)**: "패턴처럼 보이지만 아님" 레지스트리. 경쟁자 없음.

### 이메일 컨벤션 (2026-04-19 최종)
- **공개 메타데이터 모두**: `cj@chanjoongx.com`
  - npm maintainer, plugin.json author, marketplace.json owner, PRIVACY.md contact, Anthropic 마켓 제출자
- **Claude 계정 + 결제**: `chanjoongx@gmail.com`
- **Cloudflare Email Routing**: `cj@chanjoongx.com` → `chanjoongx@gmail.com` 포워딩
- **근거**: Anthropic Verified 배지 검증 시 제출자 이메일이 패키지 메타데이터 메인테이너 이메일과 일치하면 소유권 증거. Claude 계정은 로그인 자체로 이미 인증됨.

### 문체 (하루 동안 확정)
- **em-dash (`—`) 금지**: CP949 콘솔에서 `??` 로 깨짐, 사용자 비선호. 대체: 콜론(`:`), 쉼표(`,`), "and".
- **3Pod 검증**: 중요한 결정은 plan, plan review, execute, execute review, final review 5단계.

---

## 🐛 발견된 Undocumented 플러그인 quirks

공식 문서에 없지만 `claude plugin install` 실측으로 확인한 것들. 모두 v0.3.0 에 fix 완료. 릴리스 노트에도 명시.

1. **`agents` 필드는 file array 여야 함** (directory string 거부)
   - ❌ `"agents": "./agents/"` → validator reject
   - ✅ `"agents": ["./agents/brain-router.md", "./agents/craft-specialist.md", ...]`

2. **`hooks/hooks.json` 은 자동 로드됨, plugin.json 에서 참조 금지**
   - ❌ `plugin.json` 에 `"hooks": "./hooks/hooks.json"` → "Duplicate hooks file detected" 에러
   - ✅ `hooks/hooks.json` 파일만 존재하면 자동 로드

3. **`$schema` URL 엄격 검증** (settings.json)
   - ❌ `https://claude.com/schemas/settings.json` (잘못된 URL) → Settings Error, 설정 파일 전체 silently skip
   - ✅ `https://json.schemastore.org/claude-code-settings.json`

---

## ⚠ 알려진 한계 / 미해결 이슈

- **Benchmark 결과 pending**: `benchmark/SPEC.md` 는 published 되었으나 실행 결과 아직 없음. v0.3.1+ 목표.
- **Claude Code 2026+ 필수**: Layer A/B/C (mechanical enforcement) 는 최신 버전에서만 작동. 구버전은 Layer D/E (prompt-level) 만 사용.
- **Windows PowerShell 호환성**: `safety-net.ps1` 제공하지만 실 사용 사례 데이터 부족. macOS/Linux/Git Bash 가 검증 중심.
- **em-dash rendering**: 문서/출력에서 제거했지만, 외부 툴이 자동으로 `--` 를 `—` 로 변환할 수 있음. 주의 필요.

---

## 📦 재개 절차

**다음 세션에서 stetkeep 작업 시작할 때:**

```bash
cd C:\Users\craig\Desktop\stetkeep
claude
```

Claude 세션에서 첫 메시지:
```
이 파일 먼저 읽어줘: docs/NEXT_SESSION.md
```

### 다음 세션 최우선 작업

1. **잔여 2개 Execute** (플랜 세부는 위 "미완료" 블록 참조)
   - settings.json 덮어쓰기 경고 blockquote 추가
   - `.github/workflows/mirror-sync-check.yml` 생성
   - 사전 검증 5 개 통과 후 Execute
2. 완료 후 v0.3.1 publish prep 전체 재검토
3. 커밋 + push 여부 결정 (v0.3.1 tag 올릴지, 누적해서 한 번에 낼지)

### 또는 마켓 리뷰 결과 도착했을 때

```
Anthropic 마켓 리뷰 결과 왔어. [승인/수정요청/거절]. 다음 단계 플랜 세우자. ultrathink
```

---

## 🔗 핵심 참조

- `CLAUDE.md`: 프로젝트 상수 (자동 로드됨)
- `CHANGELOG.md`: v0.3.0 릴리스 디테일
- `.release-notes-v0.3.0.md`: GitHub Release 본문 원본
- `PRIVACY.md`: Anthropic Verified 배지용
- `benchmark/SPEC.md`: 평가 방법론
- `ARCHITECTURE.md`: 5-layer enforcement 아키텍처
- `C:\Users\craig\Desktop\resume_chanjoong_kim_en_v10.tex`: 영문 이력서
- `C:\Users\craig\Desktop\resume_chanjoong_kim_kr_v10.tex`: 한글 이력서

---

**본 체크포인트는 오늘(2026-04-19) 종료 시점 스냅샷. 다음 세션에서 이 파일을 기준으로 상황 복원.**
