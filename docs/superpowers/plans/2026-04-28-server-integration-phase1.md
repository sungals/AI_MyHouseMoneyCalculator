# Server Integration Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter 주택 자금 계산기 앱에 Supabase 기반 클라우드 동기화 추가 — 이메일 로그인, 비회원 모드, Hive↔Supabase 이중 저장, 오프라인 자동 동기화

**Architecture:** Flutter 앱이 Supabase Auth + PostgreSQL에 직접 연결. 기존 Hive 로컬 저장은 그대로 유지하고 Supabase를 레이어로 추가. Repository 패턴으로 두 저장소를 추상화. 모든 Supabase 호출은 try/catch로 감싸 서버 장애 시에도 로컬 기능 유지.

**Tech Stack:** Flutter 3.x, Riverpod 2.5, Hive 2.2, supabase_flutter 2.x, connectivity_plus 6.x, uuid 4.x, go_router 14.x

---

## File Structure

```
lib/
├── core/
│   └── config/
│       └── supabase_config.dart          [NEW] Supabase URL/anon key 상수
├── data/
│   ├── models/
│   │   └── calculation_history.dart      [MODIFY] taxDeduction 추가, syncedAt HiveField 7, copyWith
│   ├── local/
│   │   └── calculation_history_store.dart [MODIFY] boxName public, getAllUnsynced(), _safeBox 개선
│   ├── remote/
│   │   └── calculation_history_remote_store.dart [NEW] Supabase CRUD
│   └── repositories/
│       └── calculation_history_repository.dart   [NEW] Local+Remote 통합
├── providers/
│   └── calculation_history_provider.dart [NEW] repositoryProvider, historyProvider
├── features/
│   ├── auth/
│   │   ├── auth_state.dart               [NEW] AuthState sealed class
│   │   ├── auth_notifier.dart            [NEW] StateNotifier, Hive→Supabase 이전
│   │   └── login_screen.dart             [NEW] 이메일/비밀번호 + 비회원 버튼
│   ├── settings/
│   │   └── settings_screen.dart          [MODIFY] ConsumerWidget, _AccountSection 추가
│   ├── history/
│   │   ├── history_screen.dart           [MODIFY] ConsumerStatefulWidget, Repository 사용
│   │   └── history_detail_screen.dart    [MODIFY] ConsumerStatefulWidget, Repository 사용
│   ├── rent_compare/
│   │   └── rent_compare_screen.dart      [MODIFY] Repository 사용
│   ├── semi_rent/
│   │   └── semi_rent_screen.dart         [MODIFY] Repository 사용
│   ├── loan_interest/
│   │   └── loan_interest_screen.dart     [MODIFY] Repository 사용
│   └── monthly_expense/
│       └── monthly_expense_screen.dart   [MODIFY] Repository 사용
├── shared/
│   └── widgets/
│       └── offline_banner.dart           [NEW] 상단 오프라인 배지
├── connectivity/
│   └── connectivity_notifier.dart        [NEW] 온/오프라인 감지, 재연결 시 동기화
├── app.dart                              [MODIFY] ConsumerWidget, builder로 OfflineBanner 삽입
└── main.dart                             [MODIFY] Supabase.initialize(), Adapter 등록, box 열기
supabase/
└── migrations/
    └── 20260428000000_initial.sql        [NEW] calculation_history 테이블 + RLS
pubspec.yaml                              [MODIFY] 3개 패키지 추가
```

---

## Task 1: Supabase 프로젝트 생성 (수동 설정)

**Files:**
- 없음 (브라우저에서 수동 작업)

- [ ] **Step 1: Supabase 프로젝트 생성**

  1. https://supabase.com 접속 → 로그인 → "New project" 클릭
  2. 이름: `house-money-calculator`, 비밀번호: 강력한 비밀번호, Region: Northeast Asia (Tokyo)
  3. 프로젝트 생성 완료까지 약 1~2분 대기

- [ ] **Step 2: API 자격증명 확인**

  Project Settings → API 탭에서 다음 두 값 메모:
  - **Project URL**: `https://xxxxxxxxxxxx.supabase.co`
  - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

- [ ] **Step 3: 이메일 인증 설정**

  Authentication → Providers → Email 탭:
  - "Confirm email" 체크 확인 (기본값 ON)
  - Site URL: `http://localhost` (개발 중 임시)

---

## Task 2: pubspec.yaml 패키지 추가

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 패키지 추가**

  `pubspec.yaml`의 `dependencies:` 블록에 추가:

  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    flutter_riverpod: ^2.5.1
    go_router: ^14.2.0
    hive: ^2.2.3
    hive_flutter: ^1.1.0
    supabase_flutter: ^2.5.0
    connectivity_plus: ^6.0.3
    uuid: ^4.4.0
    intl: ^0.19.0
  ```

- [ ] **Step 2: 패키지 설치 및 확인**

  ```bash
  cd /Users/sungals07/AI_MyFinanceApp/house_money_calculator
  flutter pub get
  ```

  Expected output: `Got dependencies!` (오류 없음)

- [ ] **Step 3: 커밋**

  ```bash
  git add pubspec.yaml pubspec.lock
  git commit -m "chore: add supabase_flutter, connectivity_plus, uuid packages"
  ```

---

## Task 3: CalculationHistory 모델 + Store 업데이트

**Files:**
- Modify: `lib/data/models/calculation_history.dart`
- Modify: `lib/data/local/calculation_history_store.dart`
- Test: `test/data/models/calculation_history_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (RED)**

  `test/data/models/calculation_history_test.dart` 생성:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:house_money_calculator/data/models/calculation_history.dart';

  void main() {
    group('CalculationHistory', () {
      final sample = CalculationHistory(
        id: 'test-id',
        typeIndex: 0,
        title: '전월세 비교',
        summary: '월세 50만원',
        input: {'deposit': 100000000},
        result: {'monthlyRent': 500000},
        createdAt: DateTime(2026, 4, 28),
        syncedAt: null,
      );

      test('copyWith updates specified fields only', () {
        final now = DateTime(2026, 4, 29);
        final updated = sample.copyWith(syncedAt: now);
        expect(updated.id, equals('test-id'));
        expect(updated.syncedAt, equals(now));
        expect(updated.title, equals('전월세 비교'));
      });

      test('CalculationType.taxDeduction exists at index 4', () {
        expect(CalculationType.values.length, equals(5));
        expect(CalculationType.values[4], equals(CalculationType.taxDeduction));
      });

      test('featureType returns correct string', () {
        expect(sample.featureType, equals('rent_compare'));
        final taxSample = CalculationHistory(
          id: 'tax-id',
          typeIndex: 4,
          title: '세금 공제',
          summary: '공제 10만원',
          input: {},
          result: {},
          createdAt: DateTime.now(),
          syncedAt: null,
        );
        expect(taxSample.featureType, equals('tax_deduction'));
      });
    });
  }
  ```

- [ ] **Step 2: 테스트 실행 (FAIL 확인)**

  ```bash
  flutter test test/data/models/calculation_history_test.dart
  ```

  Expected: FAIL (taxDeduction, copyWith, syncedAt 없음)

- [ ] **Step 3: 모델 업데이트**

  `lib/data/models/calculation_history.dart` 전체 교체:

  ```dart
  import 'package:hive/hive.dart';

  part 'calculation_history.g.dart';

  enum CalculationType {
    rentCompare,
    semiRent,
    loanInterest,
    monthlyExpense,
    taxDeduction,
  }

  @HiveType(typeId: 0)
  class CalculationHistory extends HiveObject {
    @HiveField(0)
    final String id;

    @HiveField(1)
    final int typeIndex;

    @HiveField(2)
    final String title;

    @HiveField(3)
    final String summary;

    @HiveField(4)
    final Map<String, dynamic> input;

    @HiveField(5)
    final Map<String, dynamic> result;

    @HiveField(6)
    final DateTime createdAt;

    @HiveField(7)
    final DateTime? syncedAt;

    CalculationHistory({
      required this.id,
      required this.typeIndex,
      required this.title,
      required this.summary,
      required this.input,
      required this.result,
      required this.createdAt,
      this.syncedAt,
    });

    CalculationHistory copyWith({
      String? id,
      int? typeIndex,
      String? title,
      String? summary,
      Map<String, dynamic>? input,
      Map<String, dynamic>? result,
      DateTime? createdAt,
      DateTime? syncedAt,
    }) {
      return CalculationHistory(
        id: id ?? this.id,
        typeIndex: typeIndex ?? this.typeIndex,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        input: input ?? Map.from(this.input),
        result: result ?? Map.from(this.result),
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt ?? this.syncedAt,
      );
    }

    String get featureType {
      const types = [
        'rent_compare',
        'semi_rent',
        'loan_interest',
        'monthly_expense',
        'tax_deduction',
      ];
      return types[typeIndex];
    }

    Map<String, dynamic> toSupabaseJson() {
      return {
        'id': id,
        'feature_type': featureType,
        'title': title,
        'summary': summary,
        'input_data': input,
        'result_data': result,
        'created_at': createdAt.toUtc().toIso8601String(),
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      };
    }

    factory CalculationHistory.fromSupabaseJson(Map<String, dynamic> json) {
      const featureTypeMap = {
        'rent_compare': 0,
        'semi_rent': 1,
        'loan_interest': 2,
        'monthly_expense': 3,
        'tax_deduction': 4,
      };
      return CalculationHistory(
        id: json['id'] as String,
        typeIndex: featureTypeMap[json['feature_type'] as String] ?? 0,
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        input: Map<String, dynamic>.from(json['input_data'] as Map? ?? {}),
        result: Map<String, dynamic>.from(json['result_data'] as Map? ?? {}),
        createdAt: DateTime.parse(json['created_at'] as String),
        syncedAt: json['synced_at'] != null
            ? DateTime.parse(json['synced_at'] as String)
            : null,
      );
    }
  }
  ```

- [ ] **Step 4: Hive 코드 재생성**

  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

  Expected: `calculation_history.g.dart` 재생성

- [ ] **Step 5: Store 업데이트**

  `lib/data/local/calculation_history_store.dart` 전체 교체:

  ```dart
  import 'package:hive_flutter/hive_flutter.dart';
  import '../models/calculation_history.dart';

  class CalculationHistoryStore {
    static const String boxName = 'calculation_history';

    Box<CalculationHistory>? _box;

    Box<CalculationHistory> get _safeBox {
      if (_box != null && _box!.isOpen) return _box!;
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<CalculationHistory>(boxName);
        return _box!;
      }
      throw StateError('CalculationHistory box is not open. Call init() first.');
    }

    Future<void> init() async {
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<CalculationHistory>(boxName);
        return;
      }
      _box = await Hive.openBox<CalculationHistory>(boxName);
    }

    Future<void> save(CalculationHistory history) async {
      await _safeBox.put(history.id, history);
    }

    List<CalculationHistory> getAll() {
      final items = _safeBox.values.toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }

    CalculationHistory? getById(String id) {
      return _safeBox.get(id);
    }

    List<CalculationHistory> getAllUnsynced() {
      return _safeBox.values
          .where((h) => h.syncedAt == null)
          .toList();
    }

    Future<void> markSynced(String id) async {
      final item = _safeBox.get(id);
      if (item == null) return;
      final updated = item.copyWith(syncedAt: DateTime.now());
      await _safeBox.put(id, updated);
    }

    Future<void> delete(String id) async {
      await _safeBox.delete(id);
    }

    Future<void> clear() async {
      await _safeBox.clear();
    }
  }
  ```

- [ ] **Step 6: 테스트 실행 (PASS 확인)**

  ```bash
  flutter test test/data/models/calculation_history_test.dart
  ```

  Expected: All tests PASS

- [ ] **Step 7: 커밋**

  ```bash
  git add lib/data/models/ lib/data/local/ test/data/
  git commit -m "feat: add taxDeduction enum, syncedAt field, copyWith, featureType, Supabase serialization"
  ```

---

## Task 4: Supabase 설정 + main.dart 초기화

**Files:**
- Create: `lib/core/config/supabase_config.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: 설정 파일 생성**

  `lib/core/config/supabase_config.dart`:

  ```dart
  class SupabaseConfig {
    static const String url = 'YOUR_SUPABASE_PROJECT_URL';
    static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  }
  ```

  > Task 1에서 메모한 실제 URL과 anon key로 교체하세요.

- [ ] **Step 2: main.dart 업데이트**

  `lib/main.dart` 전체 교체:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:hive_flutter/hive_flutter.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'app.dart';
  import 'core/config/supabase_config.dart';
  import 'data/local/calculation_history_store.dart';
  import 'data/models/calculation_history.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    Hive.registerAdapter(CalculationHistoryAdapter());
    await Hive.openBox('app_settings');
    await Hive.openBox<CalculationHistory>(CalculationHistoryStore.boxName);

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    runApp(const ProviderScope(child: App()));
  }
  ```

- [ ] **Step 3: 빌드 확인**

  ```bash
  flutter build apk --debug 2>&1 | tail -5
  ```

  Expected: `BUILD SUCCESSFUL` (오류 없음)

- [ ] **Step 4: 커밋**

  ```bash
  git add lib/core/ lib/main.dart
  git commit -m "feat: initialize Supabase and pre-open Hive boxes in main"
  ```

---

## Task 5: Supabase SQL 마이그레이션

**Files:**
- Create: `supabase/migrations/20260428000000_initial.sql`

- [ ] **Step 1: 마이그레이션 파일 생성**

  `supabase/migrations/20260428000000_initial.sql`:

  ```sql
  -- calculation_history 테이블
  create table if not exists public.calculation_history (
    id           text        primary key,
    user_id      uuid        not null references auth.users(id) on delete cascade,
    feature_type text        not null check (feature_type in (
                               'rent_compare', 'semi_rent', 'loan_interest',
                               'monthly_expense', 'tax_deduction'
                             )),
    title        text        not null default '',
    summary      text        not null default '',
    input_data   jsonb       not null default '{}',
    result_data  jsonb       not null default '{}',
    created_at   timestamptz not null default now(),
    synced_at    timestamptz
  );

  -- 사용자별 조회 성능 인덱스
  create index if not exists idx_calculation_history_user_id
    on public.calculation_history(user_id, created_at desc);

  -- Row Level Security 활성화
  alter table public.calculation_history enable row level security;

  -- 본인 데이터만 읽기/쓰기 가능
  create policy "Users can read own history"
    on public.calculation_history for select
    using (auth.uid() = user_id);

  create policy "Users can insert own history"
    on public.calculation_history for insert
    with check (auth.uid() = user_id);

  create policy "Users can update own history"
    on public.calculation_history for update
    using (auth.uid() = user_id);

  create policy "Users can delete own history"
    on public.calculation_history for delete
    using (auth.uid() = user_id);
  ```

- [ ] **Step 2: Supabase 대시보드에서 SQL 실행**

  1. Supabase 대시보드 → SQL Editor 탭
  2. 위 SQL 전체 복사 → 붙여넣기 → "Run" 클릭
  3. Table Editor에서 `calculation_history` 테이블 확인

- [ ] **Step 3: 커밋**

  ```bash
  git add supabase/
  git commit -m "feat: add calculation_history table with RLS policies"
  ```

---

## Task 6: CalculationHistoryRemoteStore

**Files:**
- Create: `lib/data/remote/calculation_history_remote_store.dart`
- Test: `test/data/remote/calculation_history_remote_store_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (RED)**

  `test/data/remote/calculation_history_remote_store_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:house_money_calculator/data/models/calculation_history.dart';
  import 'package:house_money_calculator/data/remote/calculation_history_remote_store.dart';

  void main() {
    group('CalculationHistoryRemoteStore', () {
      test('can be instantiated', () {
        final store = CalculationHistoryRemoteStore();
        expect(store, isNotNull);
      });

      test('toSupabaseJson produces correct keys', () {
        final history = CalculationHistory(
          id: 'abc',
          typeIndex: 0,
          title: '비교',
          summary: '요약',
          input: {'a': 1},
          result: {'b': 2},
          createdAt: DateTime.utc(2026, 4, 28),
          syncedAt: null,
        );
        final json = history.toSupabaseJson();
        expect(json['feature_type'], equals('rent_compare'));
        expect(json['input_data'], equals({'a': 1}));
        expect(json['created_at'], contains('2026-04-28'));
      });
    });
  }
  ```

- [ ] **Step 2: 테스트 실행 (FAIL 확인)**

  ```bash
  flutter test test/data/remote/
  ```

  Expected: FAIL (`CalculationHistoryRemoteStore` not found)

- [ ] **Step 3: RemoteStore 구현**

  `lib/data/remote/calculation_history_remote_store.dart`:

  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../models/calculation_history.dart';

  class CalculationHistoryRemoteStore {
    SupabaseClient get _client => Supabase.instance.client;
    static const _table = 'calculation_history';

    Future<List<CalculationHistory>> fetchAll() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CalculationHistory.fromSupabaseJson(
                Map<String, dynamic>.from(json as Map),
              ))
          .toList();
    }

    Future<void> upsert(CalculationHistory history) async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final json = history.toSupabaseJson();
      json['user_id'] = userId;

      await _client.from(_table).upsert(json);
    }

    Future<void> upsertMany(List<CalculationHistory> items) async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      if (items.isEmpty) return;

      final rows = items.map((h) {
        final json = h.toSupabaseJson();
        json['user_id'] = userId;
        return json;
      }).toList();

      await _client.from(_table).upsert(rows);
    }

    Future<void> delete(String id) async {
      await _client.from(_table).delete().eq('id', id);
    }
  }
  ```

- [ ] **Step 4: 테스트 실행 (PASS 확인)**

  ```bash
  flutter test test/data/remote/
  ```

  Expected: All tests PASS

- [ ] **Step 5: 커밋**

  ```bash
  git add lib/data/remote/ test/data/remote/
  git commit -m "feat: add CalculationHistoryRemoteStore for Supabase CRUD"
  ```

---

## Task 7: CalculationHistoryRepository + Riverpod Provider

**Files:**
- Create: `lib/data/repositories/calculation_history_repository.dart`
- Create: `lib/providers/calculation_history_provider.dart`
- Test: `test/data/repositories/calculation_history_repository_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (RED)**

  `test/data/repositories/calculation_history_repository_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:house_money_calculator/data/local/calculation_history_store.dart';
  import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';

  void main() {
    group('CalculationHistoryRepository', () {
      test('can be instantiated with local store only', () {
        final repo = CalculationHistoryRepository(
          localStore: CalculationHistoryStore(),
        );
        expect(repo, isNotNull);
      });

      test('getAll returns empty list gracefully before init', () {
        final repo = CalculationHistoryRepository(
          localStore: CalculationHistoryStore(),
        );
        expect(() => repo.getAll(), returnsNormally);
        expect(repo.getAll(), isEmpty);
      });
    });
  }
  ```

- [ ] **Step 2: 테스트 실행 (FAIL 확인)**

  ```bash
  flutter test test/data/repositories/
  ```

  Expected: FAIL (Repository class not found)

- [ ] **Step 3: Repository 구현**

  `lib/data/repositories/calculation_history_repository.dart`:

  ```dart
  import '../local/calculation_history_store.dart';
  import '../models/calculation_history.dart';
  import '../remote/calculation_history_remote_store.dart';

  class CalculationHistoryRepository {
    final CalculationHistoryStore localStore;
    final CalculationHistoryRemoteStore? remoteStore;

    CalculationHistoryRepository({
      required this.localStore,
      this.remoteStore,
    });

    Future<void> init() => localStore.init();

    Future<void> save(CalculationHistory history) async {
      await localStore.save(history);
      if (remoteStore != null) {
        try {
          await remoteStore!.upsert(history);
          await localStore.markSynced(history.id);
        } catch (_) {
          // 오프라인이거나 서버 오류 — 로컬 저장은 완료됨
        }
      }
    }

    List<CalculationHistory> getAll() {
      try {
        return localStore.getAll();
      } catch (_) {
        return [];
      }
    }

    CalculationHistory? getById(String id) {
      try {
        return localStore.getById(id);
      } catch (_) {
        return null;
      }
    }

    Future<void> delete(String id) async {
      await localStore.delete(id);
      if (remoteStore != null) {
        try {
          await remoteStore!.delete(id);
        } catch (_) {}
      }
    }

    Future<void> syncUnsynced() async {
      if (remoteStore == null) return;
      try {
        final unsynced = localStore.getAllUnsynced();
        if (unsynced.isEmpty) return;
        await remoteStore!.upsertMany(unsynced);
        for (final item in unsynced) {
          await localStore.markSynced(item.id);
        }
      } catch (_) {}
    }

    Future<void> migrateLocalToRemote() async {
      if (remoteStore == null) return;
      try {
        final all = localStore.getAll();
        if (all.isEmpty) return;
        await remoteStore!.upsertMany(all);
        for (final item in all) {
          await localStore.markSynced(item.id);
        }
      } catch (_) {}
    }
  }
  ```

- [ ] **Step 4: Provider 파일 생성**

  `lib/providers/calculation_history_provider.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../data/local/calculation_history_store.dart';
  import '../data/models/calculation_history.dart';
  import '../data/remote/calculation_history_remote_store.dart';
  import '../data/repositories/calculation_history_repository.dart';

  final calculationHistoryRepositoryProvider =
      Provider<CalculationHistoryRepository>((ref) {
    return CalculationHistoryRepository(
      localStore: CalculationHistoryStore(),
      remoteStore: CalculationHistoryRemoteStore(),
    );
  });

  final calculationHistoryListProvider =
      FutureProvider<List<CalculationHistory>>((ref) async {
    final repo = ref.watch(calculationHistoryRepositoryProvider);
    await repo.init();
    return repo.getAll();
  });
  ```

- [ ] **Step 5: 테스트 실행 (PASS 확인)**

  ```bash
  flutter test test/data/repositories/
  ```

  Expected: All tests PASS

- [ ] **Step 6: 커밋**

  ```bash
  git add lib/data/repositories/ lib/providers/ test/data/repositories/
  git commit -m "feat: add CalculationHistoryRepository and Riverpod providers"
  ```

---

## Task 8: 4개 계산 화면 Repository 사용으로 교체

**Files:**
- Modify: `lib/features/rent_compare/rent_compare_screen.dart`
- Modify: `lib/features/semi_rent/semi_rent_screen.dart`
- Modify: `lib/features/loan_interest/loan_interest_screen.dart`
- Modify: `lib/features/monthly_expense/monthly_expense_screen.dart`

> 4개 화면 모두 동일한 패턴으로 교체합니다.

- [ ] **Step 1: 각 화면에서 CalculationHistoryStore 교체**

  각 화면 파일에서 아래 패턴을 찾아 교체:

  **BEFORE (공통 패턴):**
  ```dart
  import '../../data/local/calculation_history_store.dart';
  // ...
  final _store = CalculationHistoryStore();
  // ...
  // 저장 시:
  await _store.init();
  await _store.save(history);
  ```

  **AFTER (공통 패턴):**
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../providers/calculation_history_provider.dart';
  // StatefulWidget → ConsumerStatefulWidget
  // State<T> → ConsumerState<T>
  // _store 필드 삭제

  // 저장 시:
  final repo = ref.read(calculationHistoryRepositoryProvider);
  await repo.init();
  await repo.save(history);
  ```

- [ ] **Step 2: 빌드 확인**

  ```bash
  flutter build apk --debug 2>&1 | grep -E "error:|BUILD"
  ```

  Expected: `BUILD SUCCESSFUL`

- [ ] **Step 3: 커밋**

  ```bash
  git add lib/features/rent_compare/ lib/features/semi_rent/ \
           lib/features/loan_interest/ lib/features/monthly_expense/
  git commit -m "refactor: replace CalculationHistoryStore with Repository in calculation screens"
  ```

---

## Task 9: 히스토리 화면 2개 ConsumerStatefulWidget으로 교체

**Files:**
- Modify: `lib/features/history/history_screen.dart`
- Modify: `lib/features/history/history_detail_screen.dart`

- [ ] **Step 1: history_screen.dart 교체**

  **BEFORE:**
  ```dart
  class HistoryScreen extends StatefulWidget { ... }
  class _HistoryScreenState extends State<HistoryScreen> {
    final _store = CalculationHistoryStore();
    List<CalculationHistory> _items = [];

    Future<void> _load() async {
      await _store.init();
      setState(() { _items = _store.getAll(); });
    }
  ```

  **AFTER:**
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../providers/calculation_history_provider.dart';

  class HistoryScreen extends ConsumerStatefulWidget {
    const HistoryScreen({super.key});
    @override
    ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
  }

  class _HistoryScreenState extends ConsumerState<HistoryScreen> {
    List<CalculationHistory> _items = [];

    @override
    void initState() {
      super.initState();
      _load();
    }

    Future<void> _load() async {
      final repo = ref.read(calculationHistoryRepositoryProvider);
      await repo.init();
      if (mounted) {
        setState(() { _items = repo.getAll(); });
      }
    }
  ```

- [ ] **Step 2: history_detail_screen.dart 교체**

  **BEFORE:**
  ```dart
  class HistoryDetailScreen extends StatefulWidget { ... }
  class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
    final _store = CalculationHistoryStore();
    CalculationHistory? _history;

    Future<void> _load() async {
      await _store.init();
      setState(() { _history = _store.getById(widget.id); });
    }
  ```

  **AFTER:**
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../providers/calculation_history_provider.dart';

  class HistoryDetailScreen extends ConsumerStatefulWidget {
    const HistoryDetailScreen({super.key, required this.id});
    final String id;
    @override
    ConsumerState<HistoryDetailScreen> createState() =>
        _HistoryDetailScreenState();
  }

  class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
    CalculationHistory? _history;

    @override
    void initState() {
      super.initState();
      _load();
    }

    Future<void> _load() async {
      final repo = ref.read(calculationHistoryRepositoryProvider);
      await repo.init();
      if (mounted) {
        setState(() { _history = repo.getById(widget.id); });
      }
    }
  ```

- [ ] **Step 3: 빌드 확인**

  ```bash
  flutter build apk --debug 2>&1 | grep -E "error:|BUILD"
  ```

  Expected: `BUILD SUCCESSFUL`

- [ ] **Step 4: 커밋**

  ```bash
  git add lib/features/history/
  git commit -m "refactor: convert history screens to ConsumerStatefulWidget with Repository"
  ```

---

## Task 10: AuthNotifier 구현

**Files:**
- Create: `lib/features/auth/auth_state.dart`
- Create: `lib/features/auth/auth_notifier.dart`
- Test: `test/features/auth/auth_notifier_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (RED)**

  `test/features/auth/auth_notifier_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:house_money_calculator/features/auth/auth_state.dart';

  void main() {
    group('AuthState', () {
      test('unauthenticated is initial state type', () {
        const state = AuthState.unauthenticated();
        expect(state, isA<AuthUnauthenticated>());
      });

      test('authenticated holds user id', () {
        const state = AuthState.authenticated(userId: 'user-123');
        expect(state, isA<AuthAuthenticated>());
        expect((state as AuthAuthenticated).userId, equals('user-123'));
      });

      test('loading state exists', () {
        const state = AuthState.loading();
        expect(state, isA<AuthLoading>());
      });

      test('error state holds message', () {
        const state = AuthState.error(message: '이메일을 확인해주세요');
        expect(state, isA<AuthError>());
        expect((state as AuthError).message, contains('이메일'));
      });
    });
  }
  ```

- [ ] **Step 2: 테스트 실행 (FAIL 확인)**

  ```bash
  flutter test test/features/auth/
  ```

  Expected: FAIL (auth_state.dart not found)

- [ ] **Step 3: AuthState 구현**

  `lib/features/auth/auth_state.dart`:

  ```dart
  sealed class AuthState {
    const AuthState();

    const factory AuthState.unauthenticated() = AuthUnauthenticated;
    const factory AuthState.loading() = AuthLoading;
    const factory AuthState.authenticated({required String userId}) =
        AuthAuthenticated;
    const factory AuthState.error({required String message}) = AuthError;
  }

  class AuthUnauthenticated extends AuthState {
    const AuthUnauthenticated();
  }

  class AuthLoading extends AuthState {
    const AuthLoading();
  }

  class AuthAuthenticated extends AuthState {
    const AuthAuthenticated({required this.userId});
    final String userId;
  }

  class AuthError extends AuthState {
    const AuthError({required this.message});
    final String message;
  }
  ```

- [ ] **Step 4: AuthNotifier 구현**

  `lib/features/auth/auth_notifier.dart`:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../../providers/calculation_history_provider.dart';
  import 'auth_state.dart';

  class AuthNotifier extends StateNotifier<AuthState> {
    AuthNotifier(this._ref) : super(const AuthState.unauthenticated()) {
      _init();
    }

    final Ref _ref;

    void _init() {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        state = AuthState.authenticated(userId: session.user.id);
      }

      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;
        if (event == AuthChangeEvent.signedIn && session != null) {
          state = AuthState.authenticated(userId: session.user.id);
          _migrateLocalData();
        } else if (event == AuthChangeEvent.signedOut) {
          state = const AuthState.unauthenticated();
        }
      });
    }

    Future<void> signInWithEmail({
      required String email,
      required String password,
    }) async {
      state = const AuthState.loading();
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } on AuthException catch (e) {
        state = AuthState.error(message: e.message);
      } catch (_) {
        state = const AuthState.error(message: '로그인 중 오류가 발생했습니다');
      }
    }

    Future<void> signUpWithEmail({
      required String email,
      required String password,
    }) async {
      state = const AuthState.loading();
      try {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        state = const AuthState.unauthenticated(); // 인증 메일 대기 중
      } on AuthException catch (e) {
        state = AuthState.error(message: e.message);
      } catch (_) {
        state = const AuthState.error(message: '회원가입 중 오류가 발생했습니다');
      }
    }

    Future<void> signOut() async {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        state = const AuthState.unauthenticated();
      }
    }

    Future<void> _migrateLocalData() async {
      try {
        final repo = _ref.read(calculationHistoryRepositoryProvider);
        await repo.init();
        await repo.migrateLocalToRemote();
      } catch (_) {}
    }
  }

  final authNotifierProvider =
      StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier(ref);
  });
  ```

- [ ] **Step 5: 테스트 실행 (PASS 확인)**

  ```bash
  flutter test test/features/auth/
  ```

  Expected: All tests PASS

- [ ] **Step 6: 커밋**

  ```bash
  git add lib/features/auth/ test/features/auth/
  git commit -m "feat: add AuthState sealed class and AuthNotifier with Hive migration on first login"
  ```

---

## Task 11: LoginScreen 구현

**Files:**
- Create: `lib/features/auth/login_screen.dart`

- [ ] **Step 1: LoginScreen 구현**

  `lib/features/auth/login_screen.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../../core/theme/app_colors.dart';
  import '../../shared/widgets/primary_button.dart';
  import 'auth_notifier.dart';
  import 'auth_state.dart';

  class LoginScreen extends ConsumerStatefulWidget {
    const LoginScreen({super.key});

    @override
    ConsumerState<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends ConsumerState<LoginScreen> {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _isSignUp = false;

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    Future<void> _submit() async {
      if (!_formKey.currentState!.validate()) return;
      final notifier = ref.read(authNotifierProvider.notifier);
      if (_isSignUp) {
        await notifier.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('인증 메일을 확인해주세요')),
          );
        }
      } else {
        await notifier.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authNotifierProvider);
      final isLoading = authState is AuthLoading;

      ref.listen(authNotifierProvider, (previous, next) {
        if (next is AuthAuthenticated) {
          context.go('/');
        } else if (next is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.message)),
          );
        }
      });

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    _isSignUp ? '회원가입' : '로그인',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '계산 기록을 클라우드에 저장하고\n어디서든 확인하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
                      if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      hintText: '6자 이상',
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) return '비밀번호는 6자 이상이어야 합니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isSignUp ? '가입하기' : '로그인',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? '이미 계정이 있어요 → 로그인' : '계정이 없어요 → 회원가입',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text(
                      '로그인 없이 계속하기',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: 빌드 확인**

  ```bash
  flutter build apk --debug 2>&1 | grep -E "error:|BUILD"
  ```

  Expected: `BUILD SUCCESSFUL`

- [ ] **Step 3: 커밋**

  ```bash
  git add lib/features/auth/login_screen.dart
  git commit -m "feat: add LoginScreen with email sign-in/sign-up and anonymous continue"
  ```

---

## Task 12: Router + Settings 화면 업데이트

**Files:**
- Modify: `lib/router/app_router.dart`
- Modify: `lib/features/settings/settings_screen.dart`

- [ ] **Step 1: app_router.dart에 /login 라우트 추가**

  `lib/router/app_router.dart` imports 상단에 추가:
  ```dart
  import '../features/auth/login_screen.dart';
  ```

  routes 목록에 추가:
  ```dart
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreen(),
  ),
  ```

- [ ] **Step 2: settings_screen.dart 업데이트**

  `StatelessWidget` → `ConsumerWidget`으로 변경하고 imports 추가:

  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../auth/auth_notifier.dart';
  import '../auth/auth_state.dart';

  class SettingsScreen extends ConsumerWidget {
    const SettingsScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final authState = ref.watch(authNotifierProvider);
      // 기존 build 내용 유지하고 ListView children에 추가:
      // _AccountSection(authState: authState, ref: ref)
    }
  }

  class _AccountSection extends StatelessWidget {
    const _AccountSection({required this.authState, required this.ref});
    final AuthState authState;
    final WidgetRef ref;

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              '계정',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (authState is AuthAuthenticated) ...[
            _ActionTile(
              icon: Icons.cloud_done_outlined,
              label: '클라우드 동기화 중',
              trailing: const Icon(Icons.check, color: AppColors.positive, size: 18),
            ),
            _ActionTile(
              icon: Icons.logout,
              label: '로그아웃',
              onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
            ),
          ] else ...[
            _ActionTile(
              icon: Icons.login,
              label: '로그인 / 회원가입',
              subtitle: '계산 기록을 클라우드에 저장',
              onTap: () => context.push('/login'),
            ),
          ],
        ],
      );
    }
  }

  class _ActionTile extends StatelessWidget {
    const _ActionTile({
      required this.icon,
      required this.label,
      this.subtitle,
      this.onTap,
      this.trailing,
    });

    final IconData icon;
    final String label;
    final String? subtitle;
    final VoidCallback? onTap;
    final Widget? trailing;

    @override
    Widget build(BuildContext context) {
      return ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 15)),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, size: 18)
                : null),
        onTap: onTap,
      );
    }
  }
  ```

- [ ] **Step 3: 빌드 확인**

  ```bash
  flutter build apk --debug 2>&1 | grep -E "error:|BUILD"
  ```

  Expected: `BUILD SUCCESSFUL`

- [ ] **Step 4: 커밋**

  ```bash
  git add lib/router/ lib/features/settings/
  git commit -m "feat: add /login route and account section in settings with login/logout"
  ```

---

## Task 13: ConnectivityNotifier + OfflineBanner + app.dart

**Files:**
- Create: `lib/connectivity/connectivity_notifier.dart`
- Create: `lib/shared/widgets/offline_banner.dart`
- Modify: `lib/app.dart`
- Test: `test/connectivity/connectivity_notifier_test.dart`

- [ ] **Step 1: 테스트 파일 작성 (RED)**

  `test/connectivity/connectivity_notifier_test.dart`:

  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:house_money_calculator/connectivity/connectivity_notifier.dart';

  void main() {
    group('ConnectivityNotifier', () {
      test('isOnlineProvider is defined', () {
        expect(isOnlineProvider, isNotNull);
      });

      test('connectivityNotifierProvider is defined', () {
        expect(connectivityNotifierProvider, isNotNull);
      });
    });
  }
  ```

- [ ] **Step 2: 테스트 실행 (FAIL 확인)**

  ```bash
  flutter test test/connectivity/
  ```

  Expected: FAIL (isOnlineProvider not found)

- [ ] **Step 3: ConnectivityNotifier 구현**

  `lib/connectivity/connectivity_notifier.dart`:

  ```dart
  import 'dart:async';
  import 'package:connectivity_plus/connectivity_plus.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../data/repositories/calculation_history_repository.dart';
  import '../providers/calculation_history_provider.dart';

  class ConnectivityNotifier extends StateNotifier<bool> {
    ConnectivityNotifier(this._ref) : super(true) {
      _init();
    }

    final Ref _ref;
    StreamSubscription? _subscription;

    void _init() {
      _subscription = Connectivity().onConnectivityChanged.listen((results) {
        final wasOffline = !state;
        final isOnline = results.any((r) => r != ConnectivityResult.none);
        state = isOnline;
        if (wasOffline && isOnline) {
          _syncUnsynced();
        }
      });
    }

    Future<void> _syncUnsynced() async {
      try {
        final repo = _ref.read(calculationHistoryRepositoryProvider);
        await repo.init();
        await repo.syncUnsynced();
      } catch (_) {}
    }

    @override
    void dispose() {
      _subscription?.cancel();
      super.dispose();
    }
  }

  final connectivityNotifierProvider =
      StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
    return ConnectivityNotifier(ref);
  });

  final isOnlineProvider = Provider<bool>((ref) {
    return ref.watch(connectivityNotifierProvider);
  });
  ```

- [ ] **Step 4: OfflineBanner 구현**

  `lib/shared/widgets/offline_banner.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../connectivity/connectivity_notifier.dart';

  class OfflineBanner extends ConsumerWidget {
    const OfflineBanner({super.key, required this.child});

    final Widget child;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final isOnline = ref.watch(isOnlineProvider);
      return Column(
        children: [
          if (!isOnline)
            Material(
              color: const Color(0xFFF59E0B),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wifi_off, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          '오프라인 모드',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: child),
        ],
      );
    }
  }
  ```

- [ ] **Step 5: app.dart를 ConsumerWidget으로 업데이트**

  `lib/app.dart` 전체 교체:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'core/theme/app_theme.dart';
  import 'router/app_router.dart';
  import 'shared/widgets/offline_banner.dart';

  class App extends ConsumerWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      return MaterialApp.router(
        title: '집돈계산기',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => OfflineBanner(
          child: child ?? const SizedBox.shrink(),
        ),
      );
    }
  }
  ```

- [ ] **Step 6: 테스트 실행 (PASS 확인)**

  ```bash
  flutter test test/connectivity/
  ```

  Expected: All tests PASS

- [ ] **Step 7: 빌드 최종 확인**

  ```bash
  flutter build apk --debug 2>&1 | grep -E "error:|BUILD"
  ```

  Expected: `BUILD SUCCESSFUL`

- [ ] **Step 8: 최종 커밋**

  ```bash
  git add lib/connectivity/ lib/shared/widgets/offline_banner.dart \
           lib/app.dart test/connectivity/
  git commit -m "feat: add ConnectivityNotifier, OfflineBanner, offline sync on reconnect"
  ```

---

## 수동 테스트 체크리스트 (전체 완성 후)

- [ ] 이메일 회원가입 → 인증 메일 수신 → 로그인 성공
- [ ] 비회원으로 계산 저장 → 설정 → 로그인 → Supabase 대시보드에서 데이터 확인
- [ ] 비행기 모드 → 계산 입력 → 와이파이 켜기 → 자동 동기화 확인
- [ ] 로그아웃 → 재로그인 → 히스토리 복원 확인
- [ ] Supabase 대시보드 Table Editor에서 저장된 행 직접 확인
- [ ] 오프라인 모드 배지 표시/숨김 동작 확인

---

## 구현 순서 요약

| Task | 내용 | 예상 시간 |
|------|------|----------|
| 1 | Supabase 프로젝트 생성 (수동) | 10분 |
| 2 | pubspec.yaml 패키지 추가 | 5분 |
| 3 | 모델 + Store 업데이트 | 20분 |
| 4 | Supabase 설정 + main.dart | 10분 |
| 5 | SQL 마이그레이션 | 10분 |
| 6 | RemoteStore 구현 | 15분 |
| 7 | Repository + Provider | 20분 |
| 8 | 4개 화면 Repository 교체 | 20분 |
| 9 | 히스토리 화면 2개 교체 | 15분 |
| 10 | AuthNotifier 구현 | 20분 |
| 11 | LoginScreen 구현 | 20분 |
| 12 | Router + Settings 업데이트 | 15분 |
| 13 | ConnectivityNotifier + OfflineBanner | 20분 |
| — | 수동 테스트 | 30분 |
| **합계** | | **~3.5시간** |
