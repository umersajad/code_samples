# frozen_string_literal: true

require 'rails_helper'

describe API::V2::Admin::Imports::ImportsAPI do
  include ApiTestHelpers

  describe 'POST /weekly_text_responses' do
    let(:file) { fixture_file_upload('uploads/pay_circle/weekly_text_response.csv') }
    let(:response) { call_service(:post, 'admin/imports/weekly_text_responses', { file: file }) }
    let(:acting_user) { admin }
    let(:payout_period_beginning_on) { HolidayPay::PayoutPeriod.new(date: '20/06/2022 03:02'.to_date).beginning_on }

    context 'with valid params' do
      it 'imports the weekly text responses' do
        worker1 = create(:worker, id: 1)
        worker2 = create(:worker, id: 2)

        HolidayPay::HistoricAccrual.create!(
          worker: worker1,
          amount: 150.0,
          average_hourly_rate: 11.5,
          imported_at: Time.current
        )
        HolidayPay::HistoricAccrual.create!(
          worker: worker2,
          amount: 150.0,
          average_hourly_rate: 11.5,
          imported_at: Time.current
        )

        expect { response }.to change(HolidayPay::WeeklyRequest, :count).from(0).to(2)
        expect(worker1.historic_holiday_pay_requests.pluck(:amount, :payout_period_beginning_on))
          .to eq([[150.0, payout_period_beginning_on]])
        expect(worker2.historic_holiday_pay_requests.pluck(:amount, :payout_period_beginning_on))
          .to eq([[150.0, payout_period_beginning_on]])
        expect(worker1.weekly_holiday_pay_requests.pluck(:payout_period_beginning_on))
          .to eq([payout_period_beginning_on])
        expect(worker2.weekly_holiday_pay_requests.pluck(:payout_period_beginning_on))
          .to eq([payout_period_beginning_on])
        expect_http_status 202
      end
    end

    context 'when the file has invalid headers' do
      let(:file) { fixture_file_upload('uploads/pay_circle/missing_header_weekly_text_response.csv') }

      it 'returns an error' do
        expect { response }.not_to change(HolidayPay::WeeklyRequest, :count)
        expect(response.to_h).to eq({ 'error' => 'missing_header',
                                      'error_description' => 'Missing header: Worker ID' })
        expect_http_status 422
      end
    end

    context 'when the file has an unknown worker' do
      let(:file) { fixture_file_upload('uploads/pay_circle/weekly_text_response.csv') }

      it 'returns warnings' do
        expect { response }.not_to change(HolidayPay::WeeklyRequest, :count)
        expect(response.to_h).to eq({ 'weekly_imported_rows' => 0,
                                      'weekly_warnings' => ['Unknown worker id: 1', 'Unknown worker id: 2'],
                                      'historic_imported_rows' => 0,
                                      'historic_warnings' => ['Unknown worker id: 1', 'Unknown worker id: 2'] })
        expect_http_status 202
      end
    end

    context 'when the timestamp is invalid' do
      let(:file) { fixture_file_upload('uploads/pay_circle/invalid_timestamp_weekly_text_response.csv') }

      it 'returns warnings' do
        create(:worker, id: 1)

        expect { response }.not_to change(HolidayPay::WeeklyRequest, :count)
        expect(response.to_h).to eq({ 'weekly_imported_rows' => 0,
                                      'weekly_warnings' => ['Invalid Timestamp: 20/14/2022 03:02'],
                                      'historic_imported_rows' => 0,
                                      'historic_warnings' => ['Invalid Timestamp: 20/14/2022 03:02'] })
        expect_http_status 202
      end
    end

    context 'when the workers have no historic holiday pay' do
      let(:file) { fixture_file_upload('uploads/pay_circle/weekly_text_response.csv') }

      it 'returns warnings' do
        create(:worker, id: 1)
        create(:worker, id: 2)

        expect { response }.not_to change(HolidayPay::HistoricRequest, :count)
        expect(HolidayPay::WeeklyRequest.count).to eq(2)
        expect(response.to_h).to eq({ 'weekly_imported_rows' => 2,
                                      'weekly_warnings' => [],
                                      'historic_imported_rows' => 0,
                                      'historic_warnings' => ['Worker with id: 1 has no historic holiday pay',
                                                              'Worker with id: 2 has no historic holiday pay'] })
        expect_http_status 202
      end
    end

    context 'when the pay requests already exist' do
      let(:file) { fixture_file_upload('uploads/pay_circle/weekly_text_response.csv') }

      it 'returns warnings' do
        worker1 = create(:worker, id: 1)
        worker2 = create(:worker, id: 2)

        create(:holiday_pay_historic_request,
               worker: worker1,
               start_date: Time.current,
               pays_on: Time.current,
               payout_period_beginning_on: payout_period_beginning_on)

        create(:holiday_pay_weekly_request,
               worker: worker1,
               requested_at: '20/06/2022 03:02'.to_date)

        HolidayPay::HistoricAccrual.create!(
          worker: worker2,
          amount: 150.0,
          average_hourly_rate: 11.5,
          imported_at: Time.current
        )
        HolidayPay::HistoricAccrual.create!(
          worker: worker1,
          amount: 150.0,
          average_hourly_rate: 11.5,
          imported_at: Time.current
        )

        expect(response.to_h).to eq({ 'weekly_imported_rows' => 1,
                                      'weekly_warnings' => ['Weekly request for worker_id: 1 already exists for'\
                                                            " payout period: #{payout_period_beginning_on}"],
                                      'historic_imported_rows' => 1,
                                      'historic_warnings' => ['Historic request for worker_id: 1 already exists for'\
                                                              " payout period: #{payout_period_beginning_on}"] })
        expect_http_status 202
      end
    end
  end
end
