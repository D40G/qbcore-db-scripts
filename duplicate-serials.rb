#!/usr/bin/env ruby

require 'mysql2'
require 'pp'
require 'json'

#############
# Variables #
#############
Debug = false
serials = Hash.new { |hash, key| hash[key] = [] }
guntype = Hash.new { |hash, key| hash[key] = [] }
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

client = Mysql2::Client.new(:default_file => "/etc/.db.cnf")

#players = client.query('SELECT * from players WHERE citizenid = \'NTO01339\'')
players = client.query('SELECT * from players')

players.each do |row|
    if valid_json?(row["charinfo"]) then
        charinfo = JSON.parse(row["charinfo"])
        cid = row["citizenid"]

        charinfomap[cid] = charinfo["charname"]

        if row["inventory"] != nil then
            inventory = JSON.parse(row["inventory"])

            inventory.each do |e|
                next if e == nil

                if Debug == true then
                    pp e
                end

                if e.class == Hash then
                    next if e["name"] =~ /evidence/
                    next if e["name"] =~ /casing/
                    next if e.class == Array
                    if e.has_key?("info") then
                        next if e["info"] == []
                        next if e["info"] == ""
                        if e["info"].has_key?("serie") then
                            serial = e["info"]["serie"]
                            next if serial == ""
                            serials[serial].push(cid)
                            wheremap[serial].push("#{cid} inventory")
                            guntype[serial].push(e["name"])
                        end
                    end
                end

                if e.class == Array then
                    next if e[1]["name"] =~ /evidence/
                    next if e[1]["name"] =~ /casing/
                    if e[1].has_key?("info") then
                        next if e[1]["info"] == []
                        next if e[1]["info"] == ""
                        if e[1]["info"].has_key?("serie") then
                            serial = e[1]["info"]["serie"]
                            next if serial == ""
                            serials[serial].push(cid)
                            wheremap[serial].push("#{cid} inventory")
                            guntype[serial].push(e[1]["name"])
                        end
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
        items.each do |e|
            next if e == nil

            if e.class == Hash then
                next if e["name"] =~ /evidence/
                next if e["name"] =~ /casing/
                if e.has_key?("info") then
                    if e["info"].has_key?("serie") then
                        serial = e["info"]["serie"]
                        next if serial == ""
                        owner = stashmap[stash]

                        if owner == nil then
                            owner = stash
                        end

                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{stash} stash")
                        guntype[serial].push(e["name"])
                    end
                end
            end

            if e.class == Array then
                next if e[1]["name"] =~ /evidence/
                next if e[1]["name"] =~ /casing/
                next if e[1]["info"] == []
                next if e[1]["info"] == ""
                if e[1].has_key?("info") then
                    if e[1]["info"].has_key?("serie") then

                        owner = stashmap[stash]

                        if owner == nil then
                            owner = stash
                        end

                        serial = e[1]["info"]["serie"]
                        next if serial == ""
                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{stash} stash")
                        guntype[serial].push(e[1]["name"])
                    end
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

        items.each do |e|
            next if e == nil

            if e.class == Hash then
                if e.has_key?("info") then
                    next if e["info"] == []
                    if e["info"].has_key?("serie") then
                        serial = e["info"]["serie"]
                        next if serial == ""
                        owner = stashmap[plate]

                        if owner == nil then
                            owner = plate
                        end

                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{plate} trunk")
                        guntype[serial].push(e["name"])
                    end
                end
            end

            if e.class == Array then
                if e[1].has_key?("info") then
                    next if e[1]["info"] == []
                    next if e[1]["info"] == ""
                    if e[1]["info"].has_key?("serie") then

                        owner = stashmap[plate]

                        if owner == nil then
                            owner = plate
                        end

                        serial = e[1]["info"]["serie"]
                        next if serial == ""
                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{plate} trunk")
                        guntype[serial].push(e[1]["name"])
                    end
                end
            end
        end
    end
end

glovebox = client.query('SELECT * from gloveboxitems')

glovebox.each do |row|
    if valid_json?(row["items"]) then
        plate = row["plate"]
        items = JSON.parse(row["items"])

        items.each do |e|
            next if e == nil

            if e.class == Hash then
                if e.has_key?("info") then
                    next if e["info"] == []
                    if e["info"].has_key?("serie") then
                        serial = e["info"]["serie"]
                        next if serial == ""
                        owner = stashmap[plate]

                        if owner == nil then
                            owner = plate
                        end

                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{plate} glove")
                        guntype[serial].push(e["name"])
                    end
                end
            end

            if e.class == Array then
                if e[1].has_key?("info") then
                    if e[1]["info"].has_key?("serie") then

                        owner = stashmap[plate]

                        if owner == nil then
                            owner = plate
                        end

                        serial = e[1]["info"]["serie"]
                        next if serial == ""
                        serials[serial].push(owner)
                        wheremap[serial].push("#{owner} #{plate} glove")
                        guntype[serial].push(e[1]["name"])
                    end
                end
            end
        end
    end
end

serials.each do |k,v|
    if v.count > 1
        v.each do |e|
            next if e =~ /police/
            next if e =~ /caseid_trash/
            next if guntype[k][0] =~ /evidence/
            next if e =~ /caseid/

            next if k == "HUNTING"
            next if guntype[k][0] =~ /knife/
            next if guntype[k][0] =~ /switchblade/
            next if guntype[k][0] =~ /hatchet/
            next if guntype[k][0] =~ /pistol/
            next if guntype[k][0] =~ /poolcue/
            next if guntype[k][0] =~ /flashlight/
            next if guntype[k][0] =~ /nightstick/
            next if guntype[k][0] =~ /weapon_bat/
            next if guntype[k][0] =~ /dildo/
            next if guntype[k][0] =~ /sword/

            printf "\n\nSerial: #{k} (#{guntype[k][0]}) is duplicated\n"
            if charinfomap[e] then
                printf "\t- Character: #{e} (#{charinfomap[e]})\n"
                printf "\t- Locations:\n"
                wheremap[k].each do |x|
                    printf "\t\t- #{x}\n"
                end

            else
                printf "\t- Character: #{e}\n"
                printf "\t- Locations:\n"
                wheremap[k].each do |x|
                    printf "\t\t- #{x}\n"
                end
            end
        end
    end
end
