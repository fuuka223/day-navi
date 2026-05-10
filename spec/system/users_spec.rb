require 'rails_helper'

RSpec.describe "ユーザー管理機能", type: :system do
  before do
    @user = FactoryBot.build(:user)
    Location.find_or_create_by(id: 9, city: '福岡市博多区')
  end

  describe 'ユーザー新規登録' do
    it '正しい情報を入力すればユーザー新規登録ができてトップページに移動する' do
      visit root_path
      expect(page).to have_content('Sign up')
      click_link 'Sign up'
      
      fill_in 'ユーザー名', with: @user.name
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      fill_in 'パスワード（確認用）', with: @user.password_confirmation
      select '福岡市博多区', from: 'お住まいの地域' 
      
      click_on '登録する'
      
      expect(page).to have_current_path(root_path)
      expect(User.count).to eq(1)

      # アイコンの干渉を避けるため、JavaScriptでクリック
      page.execute_script('document.querySelector(\'a[href="/users/show"]\').click()')
      
      expect(page).to have_content('ログアウト')
      expect(page).to have_no_content('Sign up')
      expect(page).to have_no_content('ログイン')
    end

    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      visit new_user_registration_path
      fill_in 'ユーザー名', with: ''
      fill_in 'メールアドレス', with: ''
      click_on '登録する'
      
      expect(page).to have_current_path(new_user_registration_path)
      expect(page).to have_content('新規アカウント登録') 
      expect(User.count).to eq(0)
    end
  end

  describe 'ログイン・ログアウト' do
    before do
      @user_save = FactoryBot.create(:user)
    end

    it '保存されているユーザーの情報を使えばログインできる' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: @user_save.email
      fill_in 'パスワード', with: @user_save.password
      click_on 'ログイン'
      
      expect(page).to have_current_path(root_path)
      
      # JavaScriptでクリック
      page.execute_script('document.querySelector(\'a[href="/users/show"]\').click()')
      expect(page).to have_content('ログアウト')
    end

    it 'ログアウトができる' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: @user_save.email
      fill_in 'パスワード', with: @user_save.password
      click_on 'ログイン'
      
      # JavaScriptでクリック
      page.execute_script('document.querySelector(\'a[href="/users/show"]\').click()')
      
      expect(page).to have_content('ログアウト')
      click_on 'ログアウト'
      
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('ログイン')
    end
  end
end