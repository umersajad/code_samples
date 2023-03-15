# frozen_string_literal: true

class SaasAdmin::SuperAdmin::AccountsController < SaasAdminController
  include Saas::Accountable
  include Saas::Accountable::DemoSubjectsAssignable
  include Searchable
  include Filterable
  include Hostable
  include PromoCodable

  before_action :set_accounts_data, only: %i[index]
  before_action :set_accounts, only: %i[index datatable download]

  def index
    respond_with_accounts
  end

  def datatable
    respond_with_accounts
  end

  def new
    @new_account_form = SaasAdmin::NewAccountForm.new
  end

  def create
    @accounts_form = SaasAdmin::NewAccountForm.new \
      current_admin_account.accounts.build,
      new_account_params

    if @accounts_form.save
      copy_template_group(@accounts_form)
      @invitation_url = configure_invitation_url(@accounts_form.owner)
    else
      flash[:alert] = @accounts_form.errors.full_messages.join('. ')
      redirect_to accounts_path
    end
  end

  def update
    return render :show_confirm_extension_modal if trial_end_extended?

    authorize :saas_application, :super_admin_account?
    account_updating =
      SaasAdmin::UpdateAccount.call \
        account: @account,
        params: account_params,
        current_admin_user: current_admin_user

    @account = account_updating.result

    if account_updating.errors.present?
      flash[:alert] = account_updating.errors
    elsif account_updating.success?
      if @account.total_user_slots_count_previously_changed?
        flash[:notice] = t('.user_limit_notice')
      else
        flash[:notice] = t('.notice')
      end
    else
      flash[:alert] = @account.validation_errors
    end

    redirect_back(fallback_location: account_path(@account))
  end

  def show_confirm_extension_modal; end

  def download
    download_data_from_follower('Account', @accounts.ids)
  end

  def coupon_details
    @coupon = Stripe::Coupon.retrieve(params[:coupon])

    if @coupon&.valid
      render json: { message: tiered_plan_coupon_message(@coupon) }, status: :ok
    else
      render json: { errors: 'Promo Code Not Found.' }, status: :not_found
    end
  rescue Stripe::InvalidRequestError => error
    render json: { errors: error.message }, status: :not_found
  end

  def cancel
    if @account.present? && policy([:saas_admin, @account]).cancel?
      @account.skip_name_validation = true
      @account&.stripe_subscription&.delete
      @account.update(
        status: :canceled, cancellation_date: Time.current,
        cancelled_in_trial: @account.trialing?,
        cancellation_reason: 'saas cancellation',
        cancellation_requested_at: Time.current
      )
      flash[:notice] = t('saas_admin.super_admin.accounts.danger_zone.cancel.messages.success')
    else
      flash[:alert] = t('saas_admin.super_admin.accounts.danger_zone.cancel.messages.error')
    end
    redirect_to account_path(@account.id)
  end

  def destroy
    Accounts::HardDeleteWorker.perform_async(@account.id)
    flash[:notice] = t('saas_admin.super_admin.accounts.danger_zone.hard_delete.messages.success')
    redirect_to accounts_path
  end

  private
    def set_accounts_data
      DbAction.read_with_follower do
        @available_admin_accounts = AdminAccount.pluck(:name, :id)
        @available_cx_owners = AdminUser.active.order(:name).pluck(:name)
        @available_tags = Account.all_tags.pluck(:name, :id)
        @stripe_plans = Account.pluck(:stripe_plan_id).uniq.compact.sort
      end
    end

    def set_accounts
      DbAction.read_with_follower do
        accounts = account_collection
        @q = SaasAdmin::AccountsDatatableQuery.call(accounts)
        filtered_accounts = FilteredByFindAccountsQuery.(@q, find: params[:find], current_admin_user: current_admin_user)
        @accounts = FilteredByKindAccountsQuery.call(filtered_accounts, kind: params[:kind])
        set_kind_counts(accounts)
      end
    end

    def new_account_params
      params.require(:account).permit \
        :name, :subdomain, :user_name, :user_email,
        :user_email_confirmation, :user_password,
        :user_password_confirmation, :phone, :product_name,
        :total_user_slots_count, :unlimited_user_slots,
        :premium_features, :custom_email_message,
        :stripe_id, :stripe_plan_id, :cardholder_name,
        :coupon, :trial_end, :billing_period,
        :stripe_customer_id, :form_version, :template_group,
        :street_address, :address_2, :city, :state, :postal_code, :country,
        :confirmed
    end

    def trial_end_extended?
      params[:account][:trial_end] != @account.trial_end&.strftime('%m/%d/%Y') &&
      %w[canceled unpaid].include?(@account.status) &&
      params[:account][:confirmed].nil?
    end

    def configure_invitation_url(owner)
      accept_user_invitation_url(invitation_token: owner.raw_invitation_token, host: owner.account.app_domain, account_slug: owner.account.slug)
    end

    def account_collection
      search_string = params[:search_string]
      return Account.all if search_string.blank? && search_filters.blank?

      account_ids = search_for(search_string.present? ? search_string : '*', Account).pluck(:id)
      Account.where(id: account_ids)
    end

    def set_kind_counts(accounts)
      counted = accounts.where(status: %i[active trialing trial_ended past_due canceled]).group(:status).size
      @counts = { all: accounts.size,
                  active: counted.fetch('active', 0),
                  trialing: counted.fetch('trialing', 0),
                  trial_ended: counted.fetch('trial_ended', 0),
                  past_due: counted.fetch('past_due', 0),
                  canceled: counted.fetch('canceled', 0),
                  comped: accounts.comp_accounts.size,
                  on_hold: accounts.hold_accounts.size,
                  non_billing: accounts.non_billing.size }
    end

    def search_filters
      filters = {}
      filters[:admin_account_id] = filter_params['admin_account_id_in[]']
      filters[:cx_account_owner_name] = filter_params['cx_account_owner_name_in[]']
      filters[:name] = filter_by_choice('name')
      filters[:date_created_at] = filter_by_range('date')
      filters[:stripe_plan] = filter_params['stripe_plan_id_in[]']
      filters[:industry] = filter_params['industry_in[]']
      filters[:employee_size] = filter_params['employee_size_in[]']
      filters[:source] = filter_params['source_in[]']
      filters[:curriculums_count] = filter_by_choice('curriculums_count')
      filters[:active_users_count] = filter_by_choice('used_user_slots_count')
      filters[:status] = account_status
      filters[:tags] = filter_params['taggings_tag_id_in[]']
      filters[:cancellation_reason] = filter_params['cancellation_reason_in[]']
      filters[:cancellation_at] = filter_by_range('cancellation_date')
      filters[:cancellation_requested_at] = filter_by_range('cancellation_requested_date')
      filters.compact
    end
end
