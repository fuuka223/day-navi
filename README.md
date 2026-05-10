# Day-Navi

## 1. アプリケーション概要
環境情報と時間を掛け合わせた、意思決定支援型スケジュール最適化アプリ

Day-Naviは、カレンダー・タスク・外部環境（天気）を一つのタイムラインで統合管理し、ユーザーの「判断コスト」を最小化することを目的としています。アイゼンハワーマトリクスによる優先順位付けと、位置情報に基づいた天候連動機能を備え、「今、何に集中すべきか」という結論を直感的に提示します。

## 2. 開発背景・想い
日々の生活において「何から手をつけるべきか」「天候による移動時間の変化をどう計算するか」という判断は、意外にも脳のリソースを消費します。プログラミングの力でこの「判断の負荷」を軽減し、新人社会人や学習者が自己研鑽のための「余白」を最大化できるよう開発いたしました。

## 3. 想定ユーザー
- 生活とキャリアの向上を目指す新人社会人・学習者
- 複数のツールを往復せず、一つの画面で「今日一日の流れ」を把握したい。
- 優先順位に基づいたタスク管理を行い、生産性を最大化したい。
- 天候による突発的なスケジュール変更にも、余裕を持って対応したい。

## 4. 主な機能

### 🗓️ タイムライン型スケジュール
- 日付ベースルーティング: `/schedules/YYYY-MM-DD` 形式を採用し、特定日の予定へダイレクトにアクセス可能。
- スワイプUI: 予定ブロックをスワイプすることで編集・削除ボタンが出現する、直感的で省スペースなモダンUI。
- ボトムシート詳細: 予定をクリックすると下から詳細情報がスライド表示され、画面遷移なしで内容を確認可能。

### 📊 アイゼンハワーマトリクス・タスク管理
- 4象限自動分類: タスクを「重要・緊急」「重要・非緊急」などの4エリアに可視化し、意思決定をサポート。
- クイックステータス切替: 一覧画面のチェックボックス（✅/⬜️）で、非同期的に完了状態を更新。
- 期限警告: 期限切れタスクには「⚠️ 期限切れ」の警告と経過日数を表示し、放置を防止。

### 🌤️ 位置情報連動・天気アラート
- マルチテーブル設計: `users`が`locations`を持つ設計により、ユーザーごとの拠点に基づいた正確な天気情報を取得。
- 自動前倒しアラート: 雨予報時に移動時間のリスクを自動計算し、早めの行動を促すポジティブな通知を表示。

## 5. 技術的な工夫と解決した課題
- スワイプUIの堅牢なテスト: スワイプ操作で出現する「重なっているボタン」に対し、JavaScript（`execute_script`）を用いた強制クリック手法を導入。Seleniumのクリック遮断エラーを回避し、メンテナンス性の高い自動テストを実現。
- 効率的なDB設計とクエリ: `users`テーブルに`location_id`を配置し、外部キー制約を用いたリレーションを構築。ログインユーザーに紐づく地域情報を効率的に取得し、API連携のパフォーマンスを最適化。
- UXの追求: モバイル利用を第一に考え、スワイプやボトムシート、CSS Flexboxを用いたレスポンシブデザインを徹底。

## 6. データベース設計

### users テーブル (Devise)
| Column | Type | Options |
| --- | --- | --- |
| name | string | null: false |
| email | string | null: false, unique: true |
| encrypted_password | string | null: false |
| location | references | null: false, foreign_key: true |

### locations テーブル
| Column | Type | Options |
| --- | --- | --- |
| city | string | null: false |
| ward | string | |
| town | string | |
| latitude | decimal | precision: 9, scale: 6 |
| longitude | decimal | precision: 9, scale: 6 |

### tasks テーブル
| Column | Type | Options |
| --- | --- | --- |
| title | string | null: false |
| content | text | |
| priority_level | integer | null: false (enum管理: 1〜4) |
| deadline | date | |
| is_completed | boolean | default: false, null: false |
| user | references | null: false, foreign_key: true |

### schedules テーブル
| Column | Type | Options |
| --- | --- | --- |
| title | string | null: false |
| content | text | |
| start_time | datetime | null: false |
| end_time | datetime | null: false |
| category_name | string | |
| category_color | string | default: "#cacaca" |
| user | references | null: false, foreign_key: true |

## 7. 開発環境
- **言語/フレームワーク**: Ruby 3.2.0 / Ruby on Rails 7.1.6
- **フロントエンド**: JavaScript (Vanilla JS / Turbo), CSS (Flexbox/Grid)
- **テスト**: RSpec / Capybara / Selenium (System Spec)
- **データベース**: PostgreSQL
- **インフラ**: Render
- **API**: OpenWeatherMap API