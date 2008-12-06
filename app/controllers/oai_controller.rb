class OaiController < ApplicationController
  def provide
    # Remove controller and action from the options.  Rails adds them automatically.
    if params[:identifier]
      params[:identifier] = extract_id_from_oai_identifier(params[:identifier])
    end

    if params[:verb] == 'GetRecord'
      raise ActiveRecord::RecordNotFound unless params[:identifier]
    end
    
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    provider = OaiProvider.new
    response =  provider.process_request(options)
    render :text => response, :content_type => 'text/xml'
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private
  def extract_id_from_oai_identifier(oai_identifier)
    base_url = "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/"
    if oai_identifier =~ /^#{base_url}/
      id = oai_identifier.gsub(base_url, '').to_s
    end
  end
end
