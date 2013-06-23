# -*- encoding: utf-8 -*-
module ManifestationsHelper
  def link_to_remote_manifestation(e_url)
    string = ""
    e_rdf = JSON::LD::API.toRDF("#{e_url}.json")
    m_urls = e_rdf.value["http://purl.org/vocab/frbr/core#embodiment"]
    m_urls.each do |m_url|
      m_rdf =JSON::LD::API.toRDF("#{m_url}.json")
      remote_url = m_rdf.value["http://purl.org/dc/terms/identifier"]
      m_title = m_rdf.value["http://purl.org/dc/terms/title"]
      string << link_to(m_title, m_url)
      string << "\n(#{link_to '目録システム', remote_url})"
    end
    string.html_safe
  end

  def remote_work(e_url)
    string = ""
    e_rdf = JSON::LD::API.toRDF("#{e_url}.json")
    w_url = e_rdf.value["http://purl.org/vocab/frbr/core#realizationOf"]
    w_rdf = JSON::LD::API.toRDF("#{w_url}.json")
    remote_url = w_rdf.value["http://purl.org/dc/terms/identifier"]
    w_title = w_rdf.value["http://purl.org/dc/terms/title"]
    string << link_to(w_title, w_url)
    string.html_safe
  end
end
