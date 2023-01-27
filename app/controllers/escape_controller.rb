class EscapeController < ApplicationController
    def index
        render template: "escape/index"
    end

    def read
        @api_key = ENV['BINANCE_API_KEY']
        @secret_key = ENV['BINANCE_SECRET_KEY']
        @system_status = BinanceApi.fetch_system_status["msg"]
        render template: "escape/index"
    end

    def withdraw
        @balance = "escape!"
        render template: "escape/index"
    end
end
