require 'rails_helper'

RSpec.describe Schedule, type: :model do
  before do
    @user = FactoryBot.create(:user) 
    @schedule = FactoryBot.build(:schedule, user: @user)
  end

  describe '予定の新規登録' do
    context '新規登録できるとき' do
      it 'すべての値が正しく入力されていれば登録できる' do
        expect(@schedule).to be_valid
      end

      it 'contentが空でも登録できる' do
        @schedule.content = ''
        expect(@schedule).to be_valid
      end

      it 'カテゴリー名を入力し、カラーを選択すれば登録できる' do
      @schedule.category_name = "プログラミング"
      @schedule.category_color = "#0000ff"
      expect(@schedule).to be_valid
    end

    it 'カテゴリー名もカラーも空の場合はデフォルト（グレー）で登録できる' do
      @schedule.category_name = ""
      @schedule.category_color = ""
      @schedule.save
      expect(@schedule.category_color).to eq "#f8f9fa"
      expect(@schedule).to be_valid
    end
    end

    context '新規登録できないとき' do
      # ---title関連---
      it 'titleが空では登録できない' do
        @schedule.title = ''
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("タイトルを入力してください")
      end

      it 'titleが51文字以上では登録できない' do
        @schedule.title = 'a' * 51
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("タイトルは50文字以内で入力してください")
      end

      # ---content関連---
      it 'contentが1001文字以上では登録できない' do
        @schedule.content = 'a' * 1001
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("内容は1000文字以内で入力してください")
      end

      # ---time関連---
      it 'start_timeが空では登録できない' do
        @schedule.start_time = nil
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("開始時間を入力してください")
      end

      it 'end_timeが空では登録できない' do
        @schedule.end_time = nil
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("終了時間を入力してください")
      end

      it 'end_timeがstart_timeより前の時間では登録できない' do
        @schedule.start_time = Time.zone.now
        @schedule.end_time = Time.zone.now - 1.hour
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("終了時間は開始時間より後の時間に設定してください")
      end

      it 'end_timeがstart_timeより後の時間（かつ15分以上）でないと登録できない' do
        @schedule.start_time = Time.zone.parse("2026-05-10 10:00:00")
        @schedule.end_time = Time.zone.parse("2026-05-10 10:05:00") # 5分後
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("終了時間は開始時間から15分以上間隔を空けてください")
      end

      it '既に存在する予定の時間と被っていたら登録できない' do
        # 1つ目の予定
        begin
          FactoryBot.create(:schedule, 
            user: @user,
            start_time: Time.zone.parse("2026-05-10 13:00:00"),
            end_time: Time.zone.parse("2026-05-10 14:00:00")
          )
        rescue ActiveRecord::RecordInvalid => e
          puts "--- デバッグ情報: 1つ目の保存に失敗しました ---"
          puts e.record.errors.full_messages
          raise e
        end
        # 2つ目の予定
        @schedule.user = @user
        @schedule.start_time = Time.zone.parse("2026-05-10 13:30:00")
        @schedule.end_time = Time.zone.parse("2026-05-10 14:30:00")

        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("入力された時間は既に存在する予定と重複しています")
      end

      # ---user関連---
      it 'userが紐付いていないと保存できない' do
        @schedule.user = nil
        @schedule.valid?
        expect(@schedule.errors.full_messages).to include("ユーザーを入力してください")
      end
    end
  end
end