class UpstreamErrata < ActiveRecord::Base

  include Glue::ElasticSearch::Errata if Katello.config.use_elasticsearch

  def update_or_save
    old = old_erratum
    if old == nil
      save
    elsif old.updated < updated
      update_errata(old)
    end
  end

  def repoids
    ""
  end

  def product_ids
    []
  end

  def old_erratum
    UpstreamErrata.where("errata_id = '#{self.errata_id}'").first
  end

  def update_errata(old)
    old.title = self.title
    old.description = self.description
    old.version = self.version
    old.release = self.release
    old.status = self.status
    old.updated = self.updated
    old.issued = self.issued
    old.reboot_suggested = self.reboot_suggested
    old.severity = self.severity
    old.engproduct_id = self.engproduct_id
    old.save
  end

  def self.latest_errata
    errata = UpstreamErrata.order("updated DESC, issued DESC").first
    if errata != nil
      return errata.updated
    else
      return Date.parse("1 Feb 1970")
    end
  end

  # note that this method is highly volatile until the format is completely
  # decided upon. these values are essentially placeholders until then
  def self.from_json(json)
    errata = UpstreamErrata.new
    errata.errata_id = json["id"]
    errata.title = json["title"]
    errata.description = json["description"]
    errata.version = json["version"]
    errata.release = json["epoch"]
    errata.status = json["status"]
    errata.updated = json["updated"]
    errata.issued = json["issued"]
    errata.reboot_suggested = json["reboot_suggested"]
    errata.severity = json["severity"]
    # TODO sketchy
    #errata.repolist = json["repoids"]
    errata.engproduct_id = combine_engids(json["engids"])
    #errata.pkglist = json["pkglist"]["packages"].collect { |p| p["name"] }
    #errata.references = json["references"][0"]["href"]
    # TODO add summary
    # TODO add type
    errata
  end

  def self.combine_engids(j)
    return j.join(",")
  end

end
