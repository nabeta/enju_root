module GoogleMap

  class LetterIcon < GoogleMap::Icon
    #include Reloadable

    alias_method :parent_initialize, :initialize

    def initialize(letter)
      parent_initialize(:image_url => "http://www.google.com/mapfiles/marker#{letter}.png")
    end
  end

end