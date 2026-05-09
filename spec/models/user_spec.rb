# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    before do
      @user = build(:user)
    end

    context '新規登録できるとき' do
      it 'name, email, password, password_confirmation, location_idが存在すれば登録できる' do
        expect(@user).to be_valid
      end
    end

    context '新規登録できないとき' do
      # ---name関連---
      it 'nameが空では登録できない' do
        @user.name = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("名前を入力してください")
      end

      it 'nameが21文字以上では登録できない' do
        @user.name = 'a' * 21
        @user.valid?
        expect(@user.errors.full_messages).to include("名前は20文字以内で入力してください")
      end

      # ---email関連---
      it 'emailが空では登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("メールアドレスを入力してください")
      end

      it '重複したemailが存在する場合登録できない' do
        @user.save
        another_user = build(:user, email: @user.email)
        another_user.valid?
        expect(another_user.errors.full_messages).to include("メールアドレスはすでに存在します")
      end

      it 'emailに@を含まない場合は登録できない' do
        @user.email = 'testmail'
        @user.valid?
        expect(@user.errors.full_messages).to include("メールアドレスは不正な値です")
      end

      # ---password関連---
      it 'passwordが空では登録できない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワードを入力してください")
      end

      it 'passwordが5文字以下では登録できない' do
        @user.password = '12345'
        @user.password_confirmation = '12345'
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワードは6文字以上で入力してください")
      end

      it 'passwordが129文字以上では登録できない' do
        too_long_password = 'a' * 129
        @user.password = too_long_password
        @user.password_confirmation = too_long_password
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワードは128文字以内で入力してください")
      end

      it 'passwordとpassword_confirmationが不一致では登録できない' do
        @user.password = '123456'
        @user.password_confirmation = '1234567'
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワード（確認用）とパスワードの入力が一致しません")
      end

      # ---location_id関連---
      it 'location_idが未選択（0など）では登録できない' do
        @user.location_id = 0
        @user.valid?
        expect(@user.errors.full_messages).to include("地域を選択してください")
      end

      it 'location_idが空では登録できない' do
        @user.location_id = nil
        @user.valid?
        expect(@user.errors.full_messages).to include("地域を選択してください")
      end

      it '選択肢にないID（64以上）では登録できない' do
        @user.location_id = 64
        @user.valid?
        expect(@user.errors.full_messages).to include("地域を選択してください")
      end
    end
  end
end