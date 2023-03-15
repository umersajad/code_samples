# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  def elasticsearch_lookup(term)
    models = [Curriculum, Course, Step]

    if !current_account.basic_plan? && current_account.enable_forum? && current_user.forum_enabled?
      models.push(Question, Answer)
    end

    unless general_permission? || current_account.build_plan?
      models.push(Survey::Survey, Survey::Question)
    end

    search_for term, models
  end

  def search_for(term, models, limit = nil)
    Searchkick.search term, models: models, where: search_filters, limit: limit, misspellings: edit_distance,
                            scope_results: ->(results) do
      scope = case results.name
              when 'Curriculum'
                curriculums_scope
              when 'Course'
                courses_scope
              when 'Survey::Survey'
                surveys_scope
              when 'Survey::Question'
                survey_questions_scope
              when 'Step'
                steps_scope
              else
                return results
      end

      scope.call(results)
    end
  end

  private
    def curriculums_scope
      ->(results) do
        results = results.not_archived

        if general_permission?
          results = results.where(published: true)
        end

        results = if general_permission? || author_permission?
          results.left_joins(:assignments).where(assignments: { user_id: current_user.id })
        else
          results
        end

        results.select(curriculum_columns)
      end
    end

    def edit_distance
      { edit_distance: ConfigManager.search_edit_distance }
    end

    def curriculum_columns
      <<~SQL.squish
        curriculums.deleted_at,
        curriculums.description,
        curriculums.id,
        curriculums.title,
        curriculums.emoji,
        NOT curriculums.published AS unpublished
      SQL
    end

    def courses_scope
      ->(results) do
        results = results.left_joins(curriculum: :assignments).merge(Curriculum.not_archived)

        if general_permission?
          results = results.status_finished.where(curriculums: { published: true })
        end

        results = if general_permission? || author_permission?
          results.where(assignments: { user_id: current_user.id })
        else
          results
        end

        results.select(course_columns)
      end
    end

    def course_columns
      <<~SQL.squish
        courses.deleted_at,
        courses.description,
        courses.id,
        courses.title,
        curriculums.id AS curriculum_id,
        curriculums.title AS curriculum_title,
        curriculums.emoji AS curriculum_emoji,
        NOT curriculums.published AS unpublished
      SQL
    end

    def surveys_scope
      ->(results) do
        results = results.left_joins(curriculum: :assignments).merge(Curriculum.not_archived)

        results = if author_permission?
          results.where(assignments: { user_id: current_user.id })
        else
          results
        end

        results.select(survey_columns)
      end
    end

    def survey_columns
      <<~SQL.squish
        survey_surveys.deleted_at,
        survey_surveys.description,
        survey_surveys.id,
        survey_surveys.name,
        survey_surveys.minimum_score,
        curriculums.id AS curriculum_id,
        curriculums.title AS curriculum_title,
        curriculums.emoji AS curriculum_emoji,
        NOT curriculums.published AS unpublished
      SQL
    end

    def survey_questions_scope
      ->(results) do
        results = results.left_joins(survey: { curriculum: :assignments }).merge(Curriculum.not_archived)

        results = if author_permission?
          results.where(assignments: { user_id: current_user.id })
        else
          results
        end

        results.select(survey_question_columns)
      end
    end

    def survey_question_columns
      <<~SQL.squish
        survey_questions.account_id,
        survey_questions.deleted_at,
        survey_questions.id,
        survey_questions.survey_id,
        survey_questions.text,
        survey_questions.updated_at,
        survey_surveys.name AS survey_title,
        curriculums.id AS curriculum_id,
        curriculums.title AS curriculum_title,
        curriculums.emoji AS curriculum_emoji,
        NOT curriculums.published AS unpublished
      SQL
    end

    def steps_scope
      ->(results) do
        results = results.left_joins(course: { curriculum: :assignments }).merge(Curriculum.not_archived)

        if general_permission?
          results = results.where(curriculums: { published: true }).merge(Course.status_finished)
        end

        results = if general_permission? || author_permission?
          results.where(assignments: { user_id: current_user.id })
        else
          results
        end

        results.select(step_columns)
      end
    end

    def step_columns
      <<~SQL.squish
        steps.account_id,
        steps.content,
        steps.course_id,
        steps.deleted_at,
        steps.id,
        steps.position,
        steps.title,
        steps.updated_at,
        courses.title AS course_title,
        curriculums.id AS curriculum_id,
        curriculums.title AS curriculum_title,
        curriculums.emoji AS curriculum_emoji,
        NOT curriculums.published AS unpublished
      SQL
    end

    def general_permission?
      current_user.general_permission?
    end

    def author_permission?
      current_user.author_permission?
    end

    def search_filters
      { account_id: current_account.id }
    end
end
