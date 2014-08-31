require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'json'

def get_game_id(game_name, game_platform = '')
    base_url = 'http://thegamesdb.net/api/GetGamesList.php'

    request_url = base_url + '?' + 'name=' + CGI.escape(game_name) + '&platform=' + CGI.escape(game_platform)
    xml_string = open(request_url)

    doc = Nokogiri.XML(xml_string)

    game_id = doc.css('Data Game:first-child id').text

    return game_id.length > 0 ? Integer(game_id) : nil
end

def get_game_art(game_id)

    base_url = 'http://thegamesdb.net/api/GetArt.php'

    request_url = base_url + '?' + 'id=' + String(game_id)

    xml_string = open(request_url)

    doc = Nokogiri.XML(xml_string)

    base_img_url = doc.css('Data baseImgUrl').text
    img_element = doc.css('Data Images boxart[side="front"]')

    return {
        'img_url' => base_img_url + img_element.text,
        'width'   => Integer(img_element.attribute('width').value),
        'height'  => Integer(img_element.attribute('height').value)
    }
end

def get_tgdb_platform_name(platform)
    platforms = {
        'Game Boy'                            => 'Nintendo Game Boy',
        'Game Boy Advance'                    => 'Nintendo Game Boy Advance',
        'Game Boy Color'                      => 'Nintendo Game Boy Color',
        'Nintendo Entertainment System'       => 'Nintendo Entertainment System (NES)',
        'Super Nintendo Entertainment System' => 'Super Nintendo (SNES)',
        'Wii'                                 => 'Nintendo Wii',
        'Wii U'                               => 'Nintendo Wii U',
        'PlayStation'                         => 'Sony Playstation',
        'PlayStation 2'                       => 'Sony Playstation 2',
        'PlayStation Portable'                => 'Sony PSP',
        'Xbox 360'                            => 'Microsoft Xbox 360',
    }

    return platforms[platform] || platform
end

def get_art_for_games(input, output = input)
    games = JSON.parse(File.read(input))

    games.each_with_index do |game, index|
        tgdb_platform_name = get_tgdb_platform_name(game['platform']['name'])

        game['tgdb_id'] = get_game_id(game['name'], tgdb_platform_name)
        game['image']   = game['tgdb_id'] ? get_game_art(game['tgdb_id']) : nil

        puts game
    end

    json = games.to_json

    File.open(output, 'w') { |file|
        file.write(json)
    }

    return true
end

puts get_art_for_games('games.json')
