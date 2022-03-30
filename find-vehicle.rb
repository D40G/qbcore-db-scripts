#!/usr/bin/env ruby

require 'mysql2'
require 'pp'
require 'json'
require 'time'

#############
# Variables #
#############
stashmap = Hash.new
wheremap = Hash.new { |hash, key| hash[key] = [] }
charinfomap = Hash.new

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

if ARGV[0] == nil or ARGV[0] == "" then
    printf "You must enter in an vehicle like: ./find-item.rb models\n"
    exit
end

model = ARGV[0]
client = Mysql2::Client.new(:default_file => "/etc/.db.cnf")

players = client.query('SELECT * from players')

printf("%-30s %-15s %-15s %-15s\n", "Person", "CID", "Plate", "Last Used (days)")
players.each do |row|
    if valid_json?(row["charinfo"]) then
        charinfo = JSON.parse(row["charinfo"])
        cid = row["citizenid"] 

        charinfomap[cid] = charinfo["charname"]
    end
end

vehicles = client.query("SELECT * from player_vehicles WHERE vehicle = '#{model}' ORDER BY epoch DESC")
vehicles.each do |row|
    stashmap[row["plate"]] = row["citizenid"]

    cid = row["citizenid"]
    epoch = row["epoch"]
    plate = row["plate"]

    person = "unknown"

    if charinfomap[cid] then
        person = charinfomap[cid]
    end

    now = Time.now.to_i
    delta = now - epoch.to_i
    days = delta / 86400

    if days == 0 then
        days = "today"
    end

    printf("%-30s %-15s %-15s %-15s\n", "#{person}", cid, plate, days)

end
