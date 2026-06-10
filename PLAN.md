# PLAN

## 1. Цель реализации

Построить production-ready MVP приложения IWannaEat с AI-подбором рецептов, пользовательскими рецептами/плейлистами и надежным online-only UX в рамках требований из `tz.md` и `ui-reqs.md`.

## 2. Границы MVP

В MVP входят:
- Регистрация/логин, JWT + refresh, профиль, аллергии и диета.
- Публичные и авторские рецепты (CRUD), поиск, фильтры, пагинация.
- Плейлисты и сохранение рецептов (Pinterest-подход).
- AI-чат через backend с возвратом `message + recipe_ids`.
- Базовые push-уведомления через FCM.

Не входит в MVP:
- Оффлайн-режим и локальная БД кэша.
- Прямая интеграция мобильного клиента с LLM.

## 3. Фазовый план

## Phase 0 - Project Foundation

Цель: подготовить инфраструктуру и каркас приложений.

Ключевые задачи:
- Flutter: feature-first структура, core-модули, роутинг, тема MD3.
- Backend: bootstrap Spring Boot, модульная структура, базовые конфиги.
- DevOps: CI pipeline (lint/test/build), базовые quality gates.
- DB: начальные миграции (users, profiles, allergies).

Критерий готовности:
- Оба приложения собираются и проходят CI на main ветке.

Риски:
- Отсутствие единых coding conventions -> нивелируется `DEVELOPMENT_GUIDELINES.md`.

## Phase 1 - Auth & Profile (US1)

Цель: реализовать безопасную аутентификацию и первичную настройку профиля.

Backend:
- `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`.
- Хэширование паролей, JWT access/refresh, RBAC basis.
- `GET/PUT /profile`, `GET /allergies`, `PUT /profile/allergies`.

Flutter:
- Onboarding, login/register screens.
- Валидация email/password на клиенте.
- Экран настройки профиля (allergy chips + diet text).
- Auth-guard маршрутов.

Тесты:
- Unit/integration auth flow на backend.
- Widget/integration tests для auth + profile flow.

Критерий готовности:
- Пользователь может зарегистрироваться, войти и сохранить профиль.

Зависимости:
- Завершена Phase 0.

## Phase 2 - Recipes & Playlists (US2, US3)

Цель: реализовать контентное ядро приложения.

Backend:
- CRUD рецептов с правами доступа и `is_public`.
- Поиск по названию/ингредиентам, фильтры КБЖУ/времени.
- Pagination (20 элементов).
- CRUD плейлистов + сохранение рецептов в плейлист.

Flutter:
- Лента рецептов с infinite scroll.
- Детальная карточка с `CustomScrollView` и `SliverAppBar`.
- Экран создания/редактирования рецепта.
- Bottom sheet сохранения в подборку.

Тесты:
- Backend integration tests CRUD + permissions.
- UI tests для list/detail/save flows.

Критерий готовности:
- Пользователь может создать рецепт и сохранить публичный рецепт в плейлист.

Зависимости:
- Auth/Profile из Phase 1.

## Phase 3 - AI Chat (US4)

Цель: интегрировать диалог с AI-агентом через backend.

Backend:
- `POST /ai/chat` с обогащением prompt данными профиля.
- Адаптер LLM provider, retry/timeout/fallback политика.
- Возврат валидного JSON (`message`, `recipe_ids`).

Flutter:
- Экран чата (пузыри сообщений user/ai).
- Рендер горизонтальной карусели рецептов, если `recipe_ids` не пуст.
- Навигация из карточки в рецепт.

Тесты:
- Unit tests на prompt-builder/response-mapper.
- Интеграционные тесты чата с моком LLM.

Критерий готовности:
- Чат возвращает персонализированные ответы и кликабельные рецепты.

Зависимости:
- Стабильные recipes endpoints из Phase 2.

## Phase 4 - Reliability, FCM, Admin hooks (1 неделя)

Цель: завершить обязательные нефункциональные требования и readiness к beta.

Backend:
- FCM integration для системных уведомлений.
- Базовые admin endpoints (модерация, блокировка пользователя).
- Центральная обработка ошибок и observability.

Flutter:
- Полный сценарий no-internet заглушки и disabled-кнопок.
- Полная обработка 401 и 500-504.
- Empty states, loading states, shimmer.

Тесты:
- E2E smoke сценарии основных user journeys.
- Нагрузочное тестирование ключевых endpoints (recipes search, ai chat).

Критерий готовности:
- Приложение стабильно работает в expected error scenarios и готово к beta.

## 4. Приоритеты поставки (MVP-first)

1. Auth/Profile (блокирует доступ ко всем приватным сценариям).
2. Recipes CRUD + list/detail/search.
3. Playlists + save flow.
4. AI chat с recipe cards.
5. Push/admin/moderation hardening.

## 5. Зависимости и критический путь

- Критический путь: `Phase0 -> Phase1 -> Phase2 -> Phase3 -> Phase4`.
- AI-чат зависит от готовых recipes endpoints и профиля пользователя.
- UI polishing делается параллельно, но финализируется после функционального ядра.

## 6. План тестирования

- Unit coverage (core domain/use-cases/services): минимум 70%.
- Обязательные integration tests:
  - auth lifecycle,
  - recipe CRUD + permissions,
  - playlist save/remove,
  - ai chat response contract.
- Release candidate проходит smoke checklist на Android устройствах 360x640dp-21:9.

## 7. Риски и меры

- Риск: нестабильные ответы LLM -> strict response schema + server-side validation.
- Риск: деградация производительности ленты -> pagination + оптимизированные индексы.
- Риск: сложность UI-сценариев -> ранние widget/integration tests и UI review по `ui-reqs.md`.
- Риск: security gaps в auth -> обязательный security review и rate limiting.
