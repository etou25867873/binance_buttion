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
        wallet = balance_info["wallet"]
        network = balance_info["network"]
        BinanceApi.withdraw(currency, amount, wallet, network)
        redirect_to controller: :escape, action: :read
    end
end
