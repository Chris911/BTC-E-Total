require 'btce'

COLORS = {
      :reset   => "\e[0m",

      :green    => "\e[32 m",
      :yellow  => "\e[33m"
    }

sum = 0;
info = Btce::TradeAPI.new_from_keyfile.get_info

my_currencies = info['return']['funds'].select {|currency, amount| amount > 0 }

my_currencies.each do |currency, amount|
	puts "#{COLORS[:yellow]}#{currency} : #{COLORS[:green]}#{amount}"
	if currency == "usd"
		sum += amount
	else
		if Btce::API::CURRENCY_PAIRS.include? "#{currency}_usd"
			ticker = Btce::Ticker.new "#{currency}_usd"
			sum +=(ticker.last * amount)
		else
			ticker = Btce::Ticker.new "#{currency}_btc"
			ticker_btc = Btce::Ticker.new "btc_usd"
			usd_price = ticker.last * ticker_btc.last
			sum += (usd_price * amount)
		end
	end
end

puts "\n#{COLORS[:green]}#{sum}#{COLORS[:yellow]}$#{COLORS[:reset]}"
