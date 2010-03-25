module OaiController
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    private
    def check_oai_params(params)
      oai = {}
      if params[:format] == 'oai'
        oai[:need_not_to_search] = nil
        oai[:errors] = []
        case params[:verb]
        when 'Identify'
          oai[:need_not_to_search] = true
        when 'ListSets'
          oai[:need_not_to_search] = true
        when 'ListMetadataFormats'
          oai[:need_not_to_search] = true
        when 'ListIdentifiers'
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        when 'ListRecords'
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        when 'GetRecord'
          if params[:identifier].blank?
            oai[:need_not_to_search] = true
            oai[:errors] << "badArgument"
          end
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "cannotDisseminateFormat"
          end
        else
          oai[:errors] << "badVerb"
        end
      end
      return oai
    end

    def valid_metadata_format?(format)
      if format.present?
        if ['oai_dc'].include?(format)
          true
        else
          false
        end
      else
        true
      end
    end
  end
end
