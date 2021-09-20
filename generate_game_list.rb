require 'ostruct'
require 'sequel'
require 'sqlite3'

class GenerateGameList
  def initialize
    @db = Sequel.connect('sqlite://GameDB.db')[:games]
    @gamefile = File.open('AM/romlists/GameList.txt', 'w+')
    @rocketlauncher = File.open('Rocketlauncher/Modules/PCLauncher/PCLauncher.ini', 'w+')
  end

  def process_game(game)
    add_game_to_am_list game
    create_teknoparrot_bash_script(game) unless game.teknoparrot_script.nil?
    add_game_to_rocketlauncher game
  end

  def add_game_to_am_list(game)
    entry = "#{game.name};#{game.name};#{game.platform};;#{game.year};#{game.studio};#{game.genre};#{game.players};#{game.version}"
    entry = "#{entry};#{game.buttons};;;;#{game.platform};#{game.alt_name};"
    @gamefile.puts entry
  end

  def add_game_to_rocketlauncher(game)
    @rocketlauncher.puts "[#{game.name}]"
    @rocketlauncher.puts "Application=..\\Games\\TeknoParrot\\#{game.name}.bat"
    @rocketlauncher.puts "ahk_class #{game.rocketlauncher_class}"
    @rocketlauncher.puts ""
  end

  def create_teknoparrot_bash_script(game)
    bash = "..\\..\\TeknoParrot\\TeknoParrotUi.exe --profile=#{game.teknoparrot_script}.xml"
    File.write("Games/TeknoParrot/#{game.name}.bat", bash, mode: 'w+')
  end

  def run
    @db.where(active: 1).order(:name).all.each{ process_game OpenStruct.new(_1) }
  end
end
