require 'btce'

COLORS = {
    :reset  => "\e[0m",
    :green  => "\e[32m",
    :yellow => "\e[33m",
    :red    => "\e[31m",
    :cyan   => "\e[36m"
}

puts "BTC-E :: Account Total Value\n\n"

sum  = 0
info = Btce::TradeAPI.new_from_keyfile.get_info

# Error check
if info['success'] == 0
  puts "#{COLORS[:red]}#{info['error'].capitalize}#{COLORS[:reset]}"
  exit
end

open_orders = info['return']['open_orders']

my_currencies = info['return']['funds'].select { |currency, amount| amount > 0 }

my_currencies.each do |currency, amount|
  if currency == "usd"
    sum += amount
    puts "#{COLORS[:yellow]}#{currency.upcase} : #{COLORS[:cyan]}#{amount}"
  else
    if Btce::API::CURRENCY_PAIRS.include? "#{currency}_usd"
      ticker = Btce::Ticker.new "#{currency}_usd"
      sum +=(ticker.last * amount)
    else
      ticker     = Btce::Ticker.new "#{currency}_btc"
      ticker_btc = Btce::Ticker.new "btc_usd"
      usd_price  = ticker.last * ticker_btc.last
      sum += (usd_price * amount)
    end
    usd_price.nil? ? exchange = "USD" : exchange = "BTC"
    printf "#{COLORS[:yellow]}%s : #{COLORS[:green]}%-13s #{COLORS[:cyan]} @ %-8s #{COLORS[:yellow]}%s\n",
           currency.upcase, amount, ticker.last, exchange
  end
end

puts "\n#{COLORS[:red]}You have #{open_orders} open orders!" if open_orders > 0

puts "\n#{COLORS[:cyan]}#{sum.round(2)}#{COLORS[:yellow]}$#{COLORS[:reset]}\n\n"