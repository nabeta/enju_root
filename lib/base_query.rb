module Sunspot
  module Query
    #
    # Encapsulates information common to all queries - in particular, keywords
    # and types.
    #
    class BaseQuery #:nodoc:
      def to_params
        params = {}
        if @keywords
          params[:q] = @keywords
          params[:fl] = '* score'
          params[:fq] = types_phrase
          params[:qf] = text_field_names.join(' ')
          #params[:defType] = 'dismax'
        else
          params[:q] = types_phrase
        end
        params
      end
    end
  end
end
