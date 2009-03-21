class AawsResponse < ManifestationApiResponse
  def self.expire
    AawsResponse.delete_all(['created_at < ?', 30.days.from_now])
    logger.info "#{Time.zone.now} aaws responses expired!"
  #rescue
  #  logger.info "#{Time.zone.now} expiring aaws responses failed!"
  end
end
