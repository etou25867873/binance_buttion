class EscapeController < ApplicationController
    def index
        render template: "escape/index"
    end

    def read
        @balance = ENV["HOME"]
        render template: "escape/index"
    end

    def withdraw
        @balance = "escape!"
        render template: "escape/index"
    end
end
