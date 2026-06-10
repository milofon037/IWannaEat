# DEVELOPMENT GUIDELINES

## 1. Назначение документа

Этот документ задает единые инженерные правила для разработки IWannaEat:
- Flutter Android-клиент (Dart, Material 3, Clean Architecture, BLoC/Cubit).
- Java backend (Spring Boot, PostgreSQL, JWT, интеграция с LLM и FCM).

Цель: обеспечить предсказуемое качество, безопасность и скорость разработки без архитектурного хаоса.

## 2. Общие принципы разработки

- Архитектурные решения должны соответствовать `tz.md` и `ui-reqs.md`.
- Любой функционал должен быть трассируем к user story (US1-US4).
- Любое изменение сопровождается тестами и актуализацией документации.
- Не допускается обход бэкенда для AI-запросов: клиент не вызывает LLM напрямую.
- Избегать "quick fixes", нарушающих границы слоев.

## 3. Flutter (Android) best practices

## 3.1 Базовый стек и стандарты

- Flutter stable + Dart 3.x.
- State management: `flutter_bloc` (BLoC/Cubit).
- Networking: `dio` + интерсепторы.
- Secure storage: `flutter_secure_storage`.
- Локализация: `intl`.
- Connectivity: `connectivity_plus`.
- Skeleton loading: `shimmer`.

## 3.2 Архитектура клиента (Clean Architecture + feature-first)

Рекомендуемая структура:

```text
lib/
  core/
    error/
    network/
    storage/
    widgets/
    l10n/
  features/
    auth/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
    recipes/
      data/
      domain/
      presentation/
    playlists/
      data/
      domain/
      presentation/
    ai_chat/
      data/
      domain/
      presentation/
```

Правила слоев:
- `presentation` знает только `domain`.
- `domain` не зависит от `data` и Flutter SDK.
- `data` реализует интерфейсы репозиториев из `domain`.

## 3.3 State management

- Один экран/feature -> отдельный BLoC/Cubit с явными состояниями.
- Состояния должны быть иммутабельными (`equatable`/sealed classes).
- События и состояния именуются предметно: `LoadRecipesRequested`, `RecipesLoaded`.
- Любая загрузка отражается `loading/success/error` без "магических" флагов.

## 3.4 UI/UX и дизайн-система

- Material Design 3 и только 8dp grid.
- Базовые отступы экрана 16dp, радиусы кратны 8.
- Компоненты обязаны иметь состояния: default/focused/disabled/loading/error.
- Для экрана рецепта использовать `CustomScrollView` + `SliverAppBar`.
- Для картинок из сети использовать shimmer-заглушки.
- Для chat recipe cards использовать горизонтальный `ListView`.

## 3.5 Навигация

- Централизованный роутинг (`go_router` или аналог) с auth-guards.
- До авторизации внутренние маршруты недоступны.
- При 401 и невозможности refresh: очистка secure storage и редирект на login.

## 3.6 Работа с сетью и ошибками

- Все запросы по HTTPS (TLS 1.3).
- Унифицированный `ApiException`/`Failure` слой.
- Обработка сценариев:
  - No Internet -> full-screen заглушка + disable action buttons.
  - 401 -> logout flow.
  - 500-504 -> Snackbar "Повторите попытку позже".

## 3.7 Производительность

- Списки: пагинация по 20 элементов, lazy loading.
- Использовать `const` widgets, где возможно.
- Тяжелый JSON parsing выполнять в isolates (`compute`/Isolate).
- Минимизировать rebuild через `BlocSelector`/`buildWhen`.

## 3.8 Безопасность

- JWT/refresh token хранить только в `flutter_secure_storage`.
- Не логировать токены, пароли, персональные данные.
- Не хранить secrets в репозитории.

## 3.9 Тестирование клиента

- Unit tests: use cases, мапперы, BLoC transitions.
- Widget tests: критичные экраны и состояния UI.
- Golden tests: базовые экраны (опционально для дизайн-контроля).
- Интеграционные тесты: auth, создание рецепта, добавление в плейлист, AI чат.

## 4. Java backend best practices

## 4.1 Рекомендуемый стек

- Java 21 (LTS).
- Spring Boot 3.x.
- Spring Security + JWT.
- PostgreSQL.
- Flyway/Liquibase для миграций.
- OpenAPI (springdoc) для контракта API.

## 4.2 Структура backend-модулей

```text
src/main/java/.../
  common/        # shared utils, errors, config
  auth/          # registration, login, token refresh
  user/          # profile, allergies, diet
  recipes/       # recipe CRUD, search, filters
  playlists/     # playlist CRUD, save recipe
  ai/            # chat orchestration + LLM adapter
  moderation/    # admin actions (web panel API)
  notification/  # FCM integration
```

Правило зависимостей:
- Контроллеры не содержат бизнес-логику.
- Бизнес-логика только в service/use-case слое.
- Доступ к БД только через repository/DAO.

## 4.3 API и валидация

- DTO отдельно для request/response, не отдавать JPA сущности наружу.
- Валидация через `jakarta.validation` + единый `@ControllerAdvice`.
- Валидация пароля: >=8, минимум 1 цифра, минимум 1 спецсимвол.
- Валидация email по корректному RFC-совместимому паттерну.

## 4.4 Безопасность и RBAC

- Хранить только `password_hash` (Argon2id или BCrypt).
- Роли: `user`, `admin`.
- Защищать admin endpoints ролями.
- Refresh token rotation и отзыв токенов при подозрительной активности.
- Обязательный rate limiting для auth и AI endpoints.

## 4.5 Работа с PostgreSQL

- UUID для сущностей верхнего уровня (users, recipes, playlists).
- M2M связи через таблицы-связки с composite PK.
- Индексы минимум:
  - `users.email` (unique),
  - `recipes.is_public`,
  - `recipes.title` (GIN/trigram для поиска, если включен full-text),
  - `playlist_recipes(playlist_id, recipe_id)`.
- Миграции только вперед, без ручных hotfix в production БД.

## 4.6 AI orchestration

- Клиент обращается только к backend `/ai/chat`.
- Backend обогащает запрос профилем пользователя (аллергии/диета).
- Ответ AI должен возвращаться строго структурированным JSON:
  - `message` (string),
  - `recipe_ids` (array UUID, может быть пустым).
- Таймауты и retry-политика для вызова LLM обязательны.

## 4.7 Observability и эксплуатация

- Structured logging (JSON) с `request_id`/`user_id` (где допустимо).
- Метрики: latency, error rate, AI timeout rate, DB query timings.
- Health checks: readiness/liveness.
- Трассировка критичных цепочек (auth, recipe creation, ai chat).

## 4.8 Тестирование backend

- Unit tests: services, validators, AI prompt builder.
- Integration tests: controller + DB (Testcontainers).
- Contract tests: стабильность API схем.
- Security tests: RBAC и auth edge cases.

## 5. Кросс-командные стандарты

## 5.1 Git и Pull Request

- Ветки: `feature/*`, `fix/*`, `chore/*`.
- Небольшие PR (до 300-500 строк полезных изменений).
- Каждый PR: цель, изменения, риски, test evidence.
- Минимум 1 ревьюер, для security/auth изменений 2 ревьюера.

## 5.2 Definition of Done

Задача считается завершенной, если:
- реализована в соответствии с требованиями и архитектурой;
- покрыта тестами на нужном уровне;
- не ломает существующие сценарии;
- обновлена документация;
- проходит CI quality gates.

## 5.3 CI quality gates (минимум)

- Lint и static analysis.
- Unit + integration tests.
- Проверка форматирования и сборки.
- Для backend: миграции проходят на чистой БД.

## 6. Чек-лист перед релизом

- Auth flow и refresh token работают стабильно.
- 401/5xx/no-network обрабатываются согласно ТЗ.
- AI-чат корректно рендерит карточки рецептов при `recipe_ids`.
- Пагинация и поиск рецептов работают с реальными объемами данных.
- Нет утечек токенов/секретов в логах и конфиге.
