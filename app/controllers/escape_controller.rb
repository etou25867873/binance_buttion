class EscapeController < ApplicationController
def index
        @button = "Binance Escape!"
        render template: "escape/index"
    end
end
