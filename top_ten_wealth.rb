#!/usr/bin/env ruby

require 'mysql2'
require 'pp'
require 'json'

#############
# Variables #
#############
wealth = Hash.new(0)
charinfomap = Hash.new
modelmoney = Hash.new

#############
# Functions #
#############
def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
end

########
# Main #
########

array = %x[cat vehicles.txt].split("\n")

array = []
File.readlines('vehicles.txt').each do |line|
    array << line.strip
end

array.each do |e|
    model = e.split(" ")[0]
    price = e.split(" ")[1]

    modelmoney[model] = price
end

client = Mysql2::Client.new(:default_file => "/etc/.db.cnf")

players = client.query('SELECT * from players')
players.each do |row|
    if valid_json?(row["charinfo"]) then
        charinfo = JSON.parse(row["charinfo"])
        cid = row["citizenid"]
        charinfomap[cid] = charinfo["charname"]

        if valid_json?(row["money"]) then
            money = JSON.parse(row["money"])
            total = money["cash"].to_i + money["bank"].to_i + money["dirty"].to_i
            wealth[cid] += total
        end

    end
end

vehicles = client.query('SELECT * from player_vehicles')
vehicles.each do |row|
    cid = row["citizenid"]
    plate = row["plate"]
    model = row["vehicle"]

    price = 0
    price = modelmoney[model]
    price = 0 if price == nil

    wealth[cid] += price.to_i
end

wealth = wealth.sort_by {|k,v| v}.reverse

count = 0
printf("%-30s %-35s\n", "Person", "Total Wealth")
wealth.each do |k,v|
    exit if count > 20
    #printf("%-30s %-35s\n", "#{charinfomap[k]}", "$#{v.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,')}")

    x = v.to_s.split('.')
    x[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    x = x.join('.')
    
    printf("%-30s %-35s\n", "#{charinfomap[k]}", "$#{x}")
    count += 1
end