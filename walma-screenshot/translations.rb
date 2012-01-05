require "json"

# Too simple translations management

class Translations

  def initialize(lang)
    @lang = lang
    @strings = {}
    @file = "#{File.dirname(__FILE__)}/lang/#{ @lang }.json"

    read_lang_file
  end


  def get(s)
    return s if @lang == "en"

    t = @strings[s]
    return t if t and t != "__missing__"

    $stderr.puts "Cannont find #{ @lang } translation for string '#{ s }'"
    @strings[s] = "__missing__"

    if ENV["GENERATE_LANG"]
      File.open(@file, "w") do |f|
        f.write JSON.pretty_generate @strings
      end
      $stderr.puts "Generated new language file for #{ @lang }"
    end

    return s
  end


  private

  def read_lang_file
    return if @lang == "en"
    begin
      data = File.open(@file) { |f| f.read }
    rescue
      if $!.errno == 2
        $stderr.puts "Could not find translation file #{ @file } #{ $!.message }"
      else
        raise $!
      end
    end

    if data
      @strings = JSON.parse data
    end

    $stderr.puts "Loaded #{ @lang } with #{ @strings.size } translations from #{ @file }"

  end


end

