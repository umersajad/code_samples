# frozen_string_literal: true

class Answer < ApplicationRecord
  MAX_TITLE_SIZE = 20

  include PublicActivity::Common, Contentable

  acts_as_tree order: 'created_at ASC', dependent: :destroy

  searchkick callbacks: :async, settings: { number_of_shards: ConfigManager.search_results_number_of_shards }

  belongs_to :account, counter_cache: true
  belongs_to :question
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_many :activities, as: :trackable, class_name: 'Activity', dependent: :destroy

  validates :content, :account, :author, presence: true

  before_save :set_title

  delegate :name, to: :author, prefix: true
  delegate :title, :open_status?, to: :question, prefix: true

  scope :with_active_account, -> { joins(:account).where(accounts: { status: :active }) }

  def author_avatar
    author.avatar.row.url
  end

  def send_notifications
    subscribers = question.subscribers.active - [author]
    activity = create_activity(:create, owner: author, account_id: account_id)

    subscribers.each do |subscriber|
      if subscriber.forum_enabled?
        if subscriber.forum_new_messages_emails?
          NotificationMailer.comment_on_topic(subscriber.id, id).deliver_later
        end

        NotificationWorker.perform_async(subscriber.id, activity.id)
      end
    end
  end

  def accept
    answers = question.answers.where.not(id: id)
    answers.update_all(accepted_answer: false)
    toggle(:accepted_answer).save
  end

  def search_data
    { account_id: account_id,
      content: content,
      title: title }
  end

  def should_index?
    deleted_at.nil?
  end

  private
    def set_title
      stripped_content = ActionView::Base.full_sanitizer.sanitize(content)

      self.title =
        if stripped_content.length > MAX_TITLE_SIZE
          content.truncate_words(MAX_TITLE_SIZE, omission: '...')
        else
          stripped_content
        end
    end
end
