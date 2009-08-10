class OAI::Provider::ActiveRecordWrapper
  def sql_conditions(opts)
    sql = []
    # Manifestationモデルでリポジトリ公開の可否を決定
    sql << "repository_content IS TRUE"
    sql << "#{timestamp_field} >= ?" << "#{timestamp_field} <= ?"
    sql << "set = ?" if opts[:set]
    esc_values = [sql.join(" AND ")]
    esc_values << Time.zone.parse(opts[:from].to_s) << Time.zone.parse(opts[:until].to_s)
    esc_values << opts[:set] if opts[:set]

    return esc_values
  end

  def sets
    Manifestation.all(:limit => 100)
  end
end

class OaiProvider < OAI::Provider::Base
  repository_name LibraryGroup.site_config.name
  repository_url LibraryGroup.url + "manifestations"
  record_prefix "oai:" + LIBRARY_WEB_HOSTNAME # + "/manifestations"
  admin_email LibraryGroup.site_config.email
  source_model OAI::Provider::ActiveRecordWrapper.new(Manifestation, :limit => 100)
end
