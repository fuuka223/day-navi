require 'rails_helper'

RSpec.describe "スケジュール管理機能", type: :system do
  let(:user) { FactoryBot.create(:user) }
  
  before do
    driven_by(:selenium_chrome)
    sign_in user
    
    @today = Time.zone.today
    @start_time = @today.to_time.change(hour: 12, min: 0)
    @end_time = @today.to_time.change(hour: 13, min: 0)

    @my_schedule = FactoryBot.create(:schedule, 
      user: user, 
      start_time: @start_time, 
      end_time: @end_time,
      title: "スワイプ対象の予定"
    )
  end

  it 'タイムラインの予定ブロックをスワイプ（クリック）すると詳細が表示される' do
    visit schedule_path(id: @today.to_s)
    expect(page).to have_selector('.swipe-content', text: @my_schedule.title, wait: 5)
    find('.swipe-content', text: @my_schedule.title).click
  end

  it 'タイムラインから編集画面へ遷移し、内容を更新できる' do
    visit schedule_path(id: @today.to_s)
    expect(page).to have_selector('.btn-edit', visible: false, wait: 5)
    edit_button = find('.btn-edit', visible: false)
    page.execute_script("arguments[0].click();", edit_button)
    
    fill_in '何をしますか？（50文字以内）', with: 'タイトルを更新しました'
    find('.btn-submit').click 
    
    expect(page).to have_content('タイトルを更新しました')
    expect(page).to have_current_path(schedule_path(id: @today.to_s))
  end

  it 'タイトルを空で更新しようとすると、エラーが表示される' do
    visit edit_schedule_path(@my_schedule)
    fill_in '何をしますか？（50文字以内）', with: ''
    find('.btn-submit').click
    
    expect(page).to have_content("タイトルを入力してください")
  end

  it '詳細ページで削除ボタンにより予定を削除できる' do
    visit schedule_path(id: @today.to_s)
    
    expect {
      page.accept_confirm do
        delete_button = find('.btn-delete', visible: false)
        page.execute_script("arguments[0].click();", delete_button)
      end
      expect(page).to have_no_content(@my_schedule.title, wait: 5)
    }.to change { Schedule.count }.by(-1)
  end

  describe 'アクセス制限' do
    before do
      @other_user = FactoryBot.create(:user)
      @other_schedule = FactoryBot.create(:schedule, user: @other_user, title: "他人の予定")
    end

    it '他人の予定の編集画面にアクセスしようとすると、トップページにリダイレクトされる' do
      visit edit_schedule_path(@other_schedule)
      expect(page).to have_current_path(root_path)
    end
  end
end