# frozen_string_literal: true

module HolidayPay
  class TextResponseImport
    include Helpers::Attributes
    include Helpers::Callable
    prepend Helpers::AdminAuthorization
    prepend Helpers::OperationErrorCatcher

    attribute :actor
    attribute :file

    HEADERS = {
      worker_id: 'Worker ID',
      timestamp: 'Request Timestamp'
    }.freeze

    def call
      @csv = CSV.read(file[:tempfile], headers: true)
      validate_all_headers_present!
      weekly_warnings, weekly_updated_rows = make_weekly_requests
      historic_warnings, histric_updated_rows = make_historic_requests

      {
        weekly_imported_rows: weekly_updated_rows.length,
        weekly_warnings: weekly_warnings,
        historic_imported_rows: histric_updated_rows.length,
        historic_warnings: historic_warnings
      }
    end

    private

    def validate_all_headers_present!
      return if (@csv.headers & HEADERS.values) == HEADERS.values

      error! :missing_header, "Missing header: #{(HEADERS.values - @csv.headers).to_sentence}"
    end

    def make_weekly_requests
      all_warnings, valid_rows = validate_rows('weekly')
      return [all_warnings, []] if valid_rows.blank?

      updated_rows = HolidayPay::WeeklyRequest.insert_all(
        valid_rows.map do |row|
          {
            worker_id: row[HEADERS[:worker_id]],
            payout_period_beginning_on: payout_period(row[HEADERS[:timestamp]]).beginning_on,
            requested_at: row[HEADERS[:timestamp]].to_datetime,
            created_at: Time.zone.now,
            updated_at: Time.zone.now
          }
        end,
        unique_by: %i[worker_id payout_period_beginning_on]
      )
      [all_warnings, updated_rows]
    end

    def make_historic_requests
      all_warnings, valid_rows = validate_rows('historic')
      return [all_warnings, []] if valid_rows.blank?

      updated_rows = HolidayPay::HistoricRequest.insert_all(
        valid_rows.map do |row|
          worker = Worker.find(row[HEADERS[:worker_id]])
          accrual_statement = GetHistoricAccrualStatement.call(worker: worker)
          payout_period = payout_period(row[HEADERS[:timestamp]])

          {
            worker_id: row[HEADERS[:worker_id]],
            holiday_rate: accrual_statement.fetch(:average_holiday_rate),
            holiday_rate_currency: 'GBP',
            amount: accrual_statement.fetch(:available),
            payout_period_beginning_on: payout_period.beginning_on,
            pays_on: payout_period.pays_on,
            created_at: row[HEADERS[:timestamp]].to_datetime,
            updated_at: Time.zone.now
          }
        end,
        unique_by: %i[worker_id payout_period_beginning_on]
      )
      [all_warnings, updated_rows]
    end

    def validate_rows(request_type)
      valid_rows = []
      all_warnings = []
      @csv.each do |row|
        warnings = validate_row(row, request_type)

        if warnings.present?
          all_warnings += warnings
        else
          valid_rows << row
        end
      end

      [all_warnings, valid_rows]
    end

    def validate_row(row, request_type)
      warnings = []

      if known_relevant_worker_ids.include?(row[HEADERS[:worker_id]])
        row[HEADERS[:timestamp]].to_datetime

        case request_type
        when 'weekly'
          warnings = weekly_request_warnings(row)
        when 'historic'
          warnings = historic_request_warnings(row)
        end
      else
        warnings << "Unknown worker id: #{row[HEADERS[:worker_id]]}"
      end
    rescue Date::Error
      warnings << "Invalid Timestamp: #{row[HEADERS[:timestamp]]}"
    end

    def weekly_request_warnings(row)
      warnings = []
      payout_period_beginning_on = payout_period(row[HEADERS[:timestamp]]).beginning_on

      if existing_weekly_requests.include?([row[HEADERS[:worker_id]].to_i, payout_period_beginning_on])
        warnings << "Weekly request for worker_id: #{row[HEADERS[:worker_id]]} already exists for"\
                     " payout period: #{payout_period_beginning_on}"
      end

      warnings
    end

    def historic_request_warnings(row)
      warnings = []
      payout_period_beginning_on = payout_period(row[HEADERS[:timestamp]]).beginning_on
      worker = Worker.find(row[HEADERS[:worker_id]])

      if existing_historic_requests.include?([row[HEADERS[:worker_id]].to_i, payout_period_beginning_on])
        warnings << "Historic request for worker_id: #{row[HEADERS[:worker_id]]} already exists for"\
                     " payout period: #{payout_period_beginning_on}"
      end

      if GetHistoricAccrualStatement.call(worker: worker).fetch(:available) <= 0
        warnings << "Worker with id: #{row[HEADERS[:worker_id]]} has no historic holiday pay"
      end

      warnings
    end

    def known_relevant_worker_ids
      @known_relevant_worker_ids ||= Worker.where(id: @csv.pluck(HEADERS[:worker_id])).ids.map(&:to_s)
    end

    def payout_period(date)
      PayoutPeriod.new(date: date.to_date)
    end

    def existing_weekly_requests
      @existing_weekly_requests ||= HolidayPay::WeeklyRequest.where(worker_id: @csv.pluck(HEADERS[:worker_id]))
                                      .pluck(:worker_id, :payout_period_beginning_on)
    end

    def existing_historic_requests
      @existing_historic_requests ||= HolidayPay::HistoricRequest.where(worker_id: @csv.pluck(HEADERS[:worker_id]))
                                        .pluck(:worker_id, :payout_period_beginning_on)
    end
  end
end
