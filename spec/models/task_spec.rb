# spec/models/task_spec.rb
require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'タスク新規登録' do
    before do
      @task = build(:task)
    end

    context '新規登録できるとき' do
      it 'すべての値が正しく入力されていれば登録できる' do
        expect(@task).to be_valid
      end
      it 'deadlineが空でも登録できる' do
        @task.deadline = nil
        expect(@task).to be_valid
      end
    end

    context '新規登録できないとき' do
      # ---title関連---
      it 'titleが空では登録できない' do
        @task.title = ''
        @task.valid?
        expect(@task.errors.full_messages).to include("タイトルを入力してください")
      end
      it 'titleが51文字以上では登録できない' do
        @task.title = 'a' * 51
        @task.valid?
        expect(@task.errors.full_messages).to include("タイトルは50文字以内で入力してください")
      end

      # ---content関連---
      it 'contentが空では登録できない' do
        @task.content = ''
        @task.valid?
        expect(@task.errors.full_messages).to include("内容を入力してください")
      end
      it 'contentが1001文字以上では登録できない' do
        @task.content = 'a' * 1001
        @task.valid?
        expect(@task.errors.full_messages).to include("内容は1000文字以内で入力してください")
      end

      # ---priority_level関連 ---
      it 'priority_levelが空では登録できない' do
        @task.priority_level = nil
        @task.valid?
        expect(@task.errors.full_messages).to include("優先度を入力してください")
      end
      it 'priority_levelが1〜4以外では登録できない' do
        [0, 5].each do |level|
          @task.priority_level = level
          @task.valid?
          expect(@task.errors.full_messages).to include("優先度は一覧にありません")
        end
      end

      # ---is_completed関連 ---
      it 'is_completedが空では登録できない' do
        @task.is_completed = nil
        @task.valid?
        expect(@task.errors.full_messages).to include("完了ステータスは一覧にありません")
      end

      # ---ユーザー関連---
      it 'userが紐付いていないと保存できない' do
        @task.user = nil
        @task.valid?
        expect(@task.errors.full_messages).to include("ユーザーを入力してください")
      end
    end
  end
end