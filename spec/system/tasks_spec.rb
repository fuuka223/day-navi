require 'rails_helper'

RSpec.describe "タスク管理機能", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    driven_by(:selenium_chrome)
    sign_in user
  end

  it 'タスクを新規登録すると、一覧画面の正しい優先度エリアに表示される' do
    visit tasks_path
    find('.fab').click # 新規作成ボタン

    fill_in 'タイトル', with: '重要なタスク'
    fill_in '内容', with: 'これはテスト用の内容です'
    select '重要・緊急', from: '優先度'
    fill_in '期限', with: Date.today
    
    click_on 'タスクを登録する'

    expect(page).to have_current_path(tasks_path)
    # 「重要・緊急」のセクション内にタイトルがあるか確認
    within '.important.urgent' do
      expect(page).to have_content('重要なタスク')
    end
  end

  it '一覧画面のステータスボタン（チェックボックス）で完了状態を切り替えられる' do
    task = FactoryBot.create(:task, user: user, is_completed: false)
    visit tasks_path
    
    # 未完了の状態を確認
    expect(page).to have_button('⬜️')

    # ステータスを切り替え
    click_on '⬜️'

    # 完了状態（✅）に変わったか確認
    expect(page).to have_button('✅')
  end

  it 'タスク詳細画面から編集・更新ができる' do
    task = FactoryBot.create(:task, user: user, title: '編集前のタスク')
    visit task_path(task)
    
    click_on '編集する'
    fill_in 'タイトル', with: 'タイトルを更新しました'
    # 優先度を明示的に選択し直す
    select '重要・緊急', from: '優先度'
    click_on 'タスクを更新する'

    expect(page).to have_current_path(tasks_path)
    expect(page).to have_content('タイトルを更新しました')
  end

  it 'タスク詳細画面から削除ができる' do
    task = FactoryBot.create(:task, user: user, title: '削除するタスク')
    visit task_path(task)

    expect {
      page.accept_confirm do
        click_on '削除する'
      end
      expect(page).to have_current_path(tasks_path)
      expect(page).to have_no_content('削除するタスク')
    }.to change { Task.count }.by(-1)
  end

  it '期限切れのタスクには警告が表示される' do
    # 昨日の日付で未完了のタスクを作成
    overdue_task = FactoryBot.create(:task, user: user, deadline: Date.yesterday, is_completed: false)
    visit tasks_path

    expect(page).to have_content('⚠️ 期限切れ')
    expect(page).to have_selector('.overdue')
  end

  describe 'アクセス制限' do
    it '他人のタスク詳細画面にアクセスしようとするとリダイレクトされる' do
      other_user = FactoryBot.create(:user)
      other_task = FactoryBot.create(:task, user: other_user)
      
      visit task_path(other_task)
      expect(page).to have_current_path(root_path) # または設計上のリダイレクト先
    end
  end
end