# qbcore-db-scripts

# How these work?
This just searches through the commonly used QBCore tables to answer common questions that many RP servers may have.

You can:

1. Find duplicate weapons across the servers
2. You can list top wealthy people (all money, and vehicles)
3. You can find items across the server and see who owns what, it'll figure out apartments, stashes and houses and who owns what.
4. You can find vehicles and when they were last taken out.

# How do configure
1. Configure a mysql config file, it's harcoded in the scripts as /etc/.db.cnf, you can change this to anything. It should look like below:

        [client]
        user=USERNAMEHERE
        password=PASSWORDHERE
        database=DATABASENAME
        port=PORTHERE
        host=IPHERE

2. Change the table names to what your tables are called. Mine are called `players`, `stashitems`, `trunkitems, `gloveboxitems` etc. You'll need to edit the scripts if your DB schema is different.

3. You may need to edit yours to fit your server. For example I filter out things like police evidence bags, etc. 

4. If you're calculating wealth, you'll need to supply a vehicles.txt which has the model name and how much its worth on your server. I have included ours.

5. You may need to edit your vehicles table to include last withdrawl. Every time someone takes a vehicle from a garage we record is so we can keep track of if people are driving those expensive imports, and we repo them if they sit too long.

6. You need the mysql2 rubygem.

# Examples

## Find Duplicate Items (weapon serial numbers)
    ./duplicate-serials.rb
    Serial: 90ZWL3JN340GSmG (weapon_compactrifle) is duplicated
        - Character: CKR43620 (Alejandro González )
        - Locations:
                - CKR43620 laguna pl2 stash
                - CKR43620 nowhere rd1 stash

## Find items across the various places people can have them
    ./find-item.rb tunerlaptop
    Person                         CID             Location       
    Matt Kayden                    CCO33278        Player Inventory
    Nova Gillon                    CNI32230        Player Inventory
    Dominic Taylor                 FJX80892        Player Inventory
    Ben Luchiano                   GTC47981        Player Inventory
    TJ Rhodes                      IPQ16693        Player Inventory
    Chamo Muerez                   OLD42979        Player Inventory
    Skyla Rose                     PLC97196        Player Inventory
    Anthony Polman                 QVI37300        Player Inventory
    The Batman                     RBU82997        Player Inventory
    Nico Northbeach                TGT80371        Player Inventory
    Tate Sullivan                  VBJ05904        Player Inventory
    David  Bale                    VBW93859        Player Inventory
    Ben Lewis                      YCW97175        Player Inventory
    Jamie Jackson                  KWL34317        alta st2       
    TJ Rhodes                      IPQ16693        apartment2471  
    Ben Lewis                      YCW97175        apartment31567 

## Top 20 wealthy people (takes into account car costs)
    ./top_ten_wealth.rb 
    Nova Gillon              $33,266,013
    David  Bale              $11,633,155
    Ben Lewis                $8,307,490
    Ben Luchiano             $5,565,436
    Matt Kayden              $5,145,782
    Anthony Polman           $4,760,627
    Nico Northbeach          $4,229,903
    Donny Kebap              $3,717,491
    Dominic Taylor           $3,565,971
    Yang Shen                $3,343,175
    Blood Bane               $3,315,084
    Saoirse OTool            $3,277,094
    George Ooaaa             $3,186,931
    Tyler Reed               $2,870,417
    Victor Wainwright        $2,810,497
    Cole Hannan              $2,805,970
    Chase Getaway            $2,773,179
    Noah Bosch               $2,747,420
    Talula Cole              $2,628,276
    Rosa Klein               $2,621,455
    Annie Apollo             $2,457,958

## Find Vehicles
    awojnarek@vps-7fe05d34:~/scripts$ ./find-vehicle.rb models
    Person                         CID             Plate           Last Used (days)
    Flo Bloom                      ABP31468        44OAB894        today          
    Nova Gillon                    CNI32230        PAYURTAX        today          
    Booka Kipps                    QCS86404        MOUNTAIN        1              
    Sparky Taco                    NRW54072        TESLAAAA        1              
    Darryl Umbridge                KYV85534        83JDX824        11             
    Victor Wainwright              UQR90885        DFSW6285        13             
    Aran Silver                    PXF77186        CHRU1239        41             
    Scar Lawd                      WZW32122        QHCA4657        112   