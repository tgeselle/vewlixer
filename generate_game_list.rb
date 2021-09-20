require 'ostruct'
require 'sequel'
require 'sqlite3'

class GenerateGameList
  def initialize
    @db = Sequel.connect('sqlite://GameDB.db')[:games]
    @gamefile = File.open('AttractMode/romlists/GameList.txt', 'w+')
  end

  def add_game(game)
    entry = "#{game.name};#{game.name};#{game.platform};;#{game.year};#{game.studio};#{game.genre};#{game.players};#{game.version}"
    entry = "#{entry};#{game.buttons};;;;#{game.platform};#{game.alt_name};"
    @gamefile.puts entry
  end

  def run
    @db.order(:name).all.each{ add_game OpenStruct.new(_1) }
  end
end


GenerateGameList.new.run
