class EscapeController < ApplicationController
    def index
        render template: "escape/index"
    end

    def read
        @api_key = ENV['BINANCE_API_KEY']
        @secret_key = ENV['BINANCE_SECRET_KEY']
        @system_status = BinanceApi.fetch_system_status["msg"]
        @balances = BinanceApi.fetch_balances
        render template: "escape/index"
    end

    def withdraw
        currency = params[:currency]
        balance_info = BinanceApi.fetch_balances.select { |b| b["asset"] == currency}[0]
        amount = balance_info["free"].to_d.truncate(8)
        withdraw_wallet = balance_info["withdraw_wallet"]
        BinanceApi.withdraw(currency, amount, withdraw_wallet)
        redirect_to controller: :escape, action: :read
    end
end
