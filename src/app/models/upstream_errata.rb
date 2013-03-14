class UpstreamErrata < ActiveRecord::Base

  def self.last_installed_date
    latest_errata.first.created_at
  end

  def self.latest_errata
    UpstreamErrata.order("updated DESC, issued DESC")
  end

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
    errata.engproduct_id = json["engids"]
    #errata.pkglist = json["pkglist"]["packages"].collect { |p| p["name"] }
    #errata.references = json["references"][0"]["href"]
    # TODO add summary
    # TODO add type

    errata
  end

  def self.refresh(url)
    ep = ErrataProcessor.new(url, self.last_errata)
    errata = ep.refresh
    errata.each do |e|
        UpstreamErrata.load_from_json(e)
    end
  end

  def self.load_from_json(e)
    upstream_errata = UpstreamErrata.from_json(e)
    if upstream_errata.is_new_errata
      upstream_errata.save
    end
  end

  def self.last_errata
    return DateTime.parse('15 Feb 2003')
  end
end
