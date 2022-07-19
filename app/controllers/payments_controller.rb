class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]
  layout 'layouts/checkout', only: [:checkout, :status, :create_payment_intent]
  skip_before_action :verify_authenticity_token, only: [:checkout, :create_payment_intent]


  # GET /payments or /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1 or /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments or /payments.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to payment_url(@payment), notice: "Payment was successfully created." }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to payment_url(@payment), notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url, notice: "Payment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def checkout

  end

  def status
    puts "====params===#{params[:redirect_status]}==="
    @status = params[:redirect_status]
  end

  def create_payment_intent
    puts "============creating_payment_intent===================="
    @invoice = Invoice.find(params[:invoice_id])
    invoice_amount = @invoice.amount #9000 #in cents
    stripe_fee_amount = (invoice_amount * 0.029) + 30 #US Stripe Fees in cents for Card-Payment: Formula : (2.9% + $0.30)
    app_fee_amount = stripe_fee_amount + 100 #in cents

    params = {
      amount: invoice_amount.round,  #Required # amount is in Cent : So here, 1.09 USD
      currency: 'USD', #Required
      payment_method_types: ['card', 'us_bank_account'], #us_bank_account => This is ACH direct debit payment
      statement_descriptor: 'Invoice transaction',
      application_fee_amount: app_fee_amount.round, #this is in cent
      description: '3-Making payment from demo client to demo vendor - web',
      receipt_email: 'recipient@example.com', # Client / company email
      metadata: {
        invoice_id: 1,
        pay_from_connected_account_id: 'acct_1LMtFSRClzJSUu73',
        pay_from_uc_company_id: 1,
      },
      transfer_data: {
        destination: 'acct_1LMxuHRSKLI1b44n', #Vendor or Broker accountId
      },
      # on_behalf_of: 'acct_1LMAcsROvpuZ9HoV' # Connected Account ID - client
    }
    begin
      payment_intent = Stripe::PaymentIntent.create(params)
      puts "-----Intent------#{payment_intent.inspect}---"
      render json: { clientSecret: payment_intent.client_secret }
    rescue Stripe::CardError => e
      render json: { error: "A payment card error occurred: #{e.message}" }, status: :not_found
    rescue Stripe::InvalidRequestError => e
      render json: { error: "An invalid request occurred: #{e.message}" }, status: :bad_request
    rescue Stripe::StripeError => e
      render json: { error: "Another problem occurred, maybe unrelated to Stripe: #{e.message}" }, status: :bad_request
    rescue Stripe::APIError => e
      render json: { error: "Stripe API server error: #{e.message}" }, status: :internal_server_error
    end

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:amount)
    end
end
