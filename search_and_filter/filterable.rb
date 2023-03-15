# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  attr_writer :filter_params

  def filter_by_choice(field)
    choice = filter_params["#{field}_choice"]&.to_sym
    value = filter_params[field]

    elasticsearch_clauses(value)[choice] if value.present?
  end

  def filter_by_range(field)
    start_value = filter_params["#{field}_start"]
    end_value = filter_params["#{field}_end"]

    if field.include?('date')
      start_value = start_value&.to_date
      end_value = end_value&.to_date
    end

    elasticsearch_clauses(nil, start_value, end_value)[:range] if start_value.present? && end_value.present?
  end

  private
    def account_status
      status_index = filter_params['account_status_eq']&.to_i
      Account.statuses.key(status_index)
    end

    def elasticsearch_clauses(value = nil, range_start = nil, range_end = nil)
      {
        cont: { like: "%#{value}%" },
        eq: value,
        start: { like: "#{value}%" },
        end: { like: "%#{value}" },
        gt: { gt: value },
        lt: { lt: value },
        range: { gte: range_start, lte: range_end }
      }
    end

    def filter_params
      @filter_params ||= serialize_data
    end

    def serialize_data
      data = {}

      return data if params[:filters]&.values.blank?

      params[:filters].values.each do |filter|
        next if filter[:value].blank?

        data[filter[:name]] = data[filter[:name]].present? ? [*(data[filter[:name]]), filter[:value]] : filter[:value]
      end

      data
    end
end
