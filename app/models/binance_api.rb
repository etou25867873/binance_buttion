class BinanceApi
    DOMAIN = 'https://api.binance.com'.freeze
    API_KEY = ENV['BINANCE_API_KEY']
    SECRET_KEY = ENV['BINANCE_SECRET_KEY']

    class << self
        def fetch_system_status
            path = '/sapi/v1/system/status'
            result = get(path)
        end

        private
            def get(path)
                url = DOMAIN + path

                response = Faraday.get(url)

                return JSON.parse(response&.body)
            end
    end
end