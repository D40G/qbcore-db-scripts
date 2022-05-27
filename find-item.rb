#!/usr/bin/env ruby

require 'mysql2'
require 'pp'
require 'json'

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
    printf "You must enter in an item like: ./find-item.rb weapon_pistol\n"
    exit
end

item = ARGV[0]
client = Mysql2::Client.new(:default_file => "/etc/.db.cnf")

players = client.query('SELECT * from players')

printf("%-30s %-15s %-15s\n", "Person", "CID", "Location")
players.each do |row|
    if valid_json?(row["charinfo"]) then
        charinfo = JSON.parse(row["charinfo"])
        cid = row["citizenid"] 

        charname = charinfo["firstname"] + " " + charinfo["lastname"]
        charinfomap[cid] = charname

        if row["inventory"] != nil then
            inventory = JSON.parse(row["inventory"])

            inventory.each do |e|
                next if e == nil

                if e.class == Hash then
                    if e["name"] == item then
                        printf("%-30s %-15s %-15s\n", "#{charinfo["charname"]}", "#{cid}", "Player Inventory")
                    end
                end

                if e.class == Array then
                    if e[1]["name"] == item then
                        printf("%-30s %-15s %-15s\n", "#{charinfo["charname"]}", "#{cid}", "Player Inventory")
                    end
                end
            end
        end
    end
end


apartments = client.query('SELECT * from apartments')
apartments.each do |row|
    stashmap[row["name"]] = row["citizenid"]
end

houses = client.query('SELECT * from player_houses')
houses.each do |row|
    stashmap[row["house"]] = row["citizenid"]
end

vehicles = client.query('SELECT * from player_vehicles')
vehicles.each do |row|
    stashmap[row["plate"]] = row["citizenid"]
end

stash = client.query('SELECT * from stashitems')

stash.each do |row|
    if valid_json?(row["items"]) then
        stash = row["stash"]
        items = JSON.parse(row["items"])
        person = "unknown"
        cid = "unknown"

        if stashmap[stash] then
            cid = stashmap[stash]

            if charinfomap[cid] then
                person = charinfomap[cid]
            end
        end

        items.each do |e|
            next if e == nil

            if e.class == Hash then
                if e["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "#{stash}")
                end
            end

            if e.class == Array then
                if e[1]["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "#{stash}")
                end
            end
        end
    end
end 

trunk = client.query('SELECT * from trunkitems')

trunk.each do |row|
    if valid_json?(row["items"]) then
        plate = row["plate"]
        items = JSON.parse(row["items"])
        cid = row["citizenid"]

        person = "unknown"

        if stashmap[stash] then
            cid = stashmap[stash]

            if charinfomap[cid] then
                person = charinfomap[cid]
            end
        end

        items.each do |e|
            next if e == nil

            if e.class == Hash then
                if e["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "Trunk #{plate}")
                end
            end

            if e.class == Array then
                if e[1]["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "Trunk #{plate}")
                end
            end
        end
    end
end

gloveboxitems = client.query('SELECT * from gloveboxitems')

gloveboxitems.each do |row|
    if valid_json?(row["items"]) then
        plate = row["plate"]
        items = JSON.parse(row["items"])
        cid = row["citizenid"]

        person = "unknown"

        if stashmap[stash] then
            cid = stashmap[stash]

            if charinfomap[cid] then
                person = charinfomap[cid]
            end
        end

        next if items == "[]"
        items.each do |e|

            next if e == nil

            if e.class == Hash then
                if e["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "Glovebox #{plate}")
                end
            end

            if e.class == Array then
                if e[1]["name"] == item then
                    printf("%-30s %-15s %-15s\n", "#{person}", cid, "Glovebox #{plate}")
                end
            end
        end
    end
end