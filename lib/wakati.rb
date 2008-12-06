require 'MeCab'
module Wakati
  def wakati
    m = MeCab::Tagger.new("-O wakati")
    m.parse(self).strip
  rescue
    nil
  end
end

class String
  include Wakati
end
