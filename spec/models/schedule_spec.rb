require 'rails_helper'

RSpec.describe Schedule, type: :model do
  before do
    @schedule = FactoryBot.build(:schedule)
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

      it 'end_timeがstart_timeと同じ時間では登録できる' do
        time = Time.zone.now
        @schedule.start_time = time
        @schedule.end_time = time
        expect(@schedule).to be_valid
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