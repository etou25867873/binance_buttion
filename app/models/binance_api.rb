class BinanceApi
    DOMAIN = 'https://api.binance.com'.freeze
    API_KEY = ENV['BINANCE_API_KEY']
    API_SECRET_KEY = ENV['BINANCE_SECRET_KEY']

    class << self
        def fetch_system_status
            path = '/sapi/v1/system/status'
            result = get(path)
        end

        def fetch_balances
            path = '/api/v3/account'
            response = request_with_auth(path: path)
            result = response.dig('balances').select { |b| b["free"].to_d > 0 }.each{ |b| 
                currency = b["asset"]
                wallet = ENV["#{currency}_WALLET"]
                network = ENV["#{currency}_NETWORK"]
                b["wallet"] = if wallet.present?
                                            wallet
                                        else
                                            "None"
                                        end
                b["network"] = if network.present?
                                    network
                                else
                                    "None"
                                end            
            } if response.dig('balances').present?
            result
        end

        def withdraw(currency, amount, wallet, network)
            path = '/sapi/v1/capital/withdraw/apply'
            options = {
                coin: currency,
                address: wallet,
                network: network,
                amount: amount,
            }
            request_with_auth(path: path, options: options, method: 'POST')
        end

        private
            def get(path)
                url = DOMAIN + path
                conn = Faraday.new do |c|
                    c.options.open_timeout = 10
                    c.options.timeout = 10
                end
                response = conn.get(url)
                return JSON.parse(response&.body)
            end

            def request_with_auth(path:, options: {}, method: "GET")
                options = add_default_value_to_options(options: options)
                digest = OpenSSL::Digest::SHA256.new
                signature = OpenSSL::HMAC.hexdigest(digest, API_SECRET_KEY, options.to_query)
                options[:signature] = signature
                url = DOMAIN + path
                conn = Faraday.new do |c|
                    c.options.open_timeout = 10
                    c.options.timeout = 10
                    c.headers['X-MBX-APIKEY'] = API_KEY
                    c.request :url_encoded
                    c.adapter Faraday.default_adapter
                end
                if method.to_s.upcase == 'GET' || path.to_s.include?("wapi")
                    url = url + "?" + build_binance_query_with_signature(options)
                    options = {}
                end

                case method.to_s.upcase
                when 'GET'
                    response = conn.get(url)
                when 'POST'
                    response = conn.post(url, options)
                end
                
                result = JSON.parse(response&.body)

                if response.status.to_i != 200
                    raise result
                end

                result
            end

            def add_default_value_to_options(options: {})
                options[:recvWindow] = 5000.to_s
                options[:timestamp] = (Time.zone.now.utc.to_f * 1000).to_i.to_s
                options
            end

            def build_binance_query_with_signature(params, params_encoder = nil)
                query = ""
                if params
                    without_signature = params.reject{ |k, _| k.to_s == "signature" }
                    with_signature = params.select{ |k, _| k.to_s == "signature" }
                    query = without_signature.to_query(params_encoder)
                    query = query + "&" + with_signature.to_query if with_signature.present?
                end
                query
            end
    end
end