class UpstreamErrata < ActiveRecord::Base

  def save_if_new
    old_errata = UpstreamErrata.where("errata_id = '#{self.errata_id}'")
    if old_errata != nil
      if updated > old_errata.updated
        old_errata.delete
        save
      end
    else
      save
    end
  end

  def self.latest_errata
    errata = UpstreamErrata.order("updated DESC, issued DESC").first
    if errata != nil
      return errata.updated
    else
      return Date.parse("1 Feb 1970")
    end
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

  def self.refresh(url)
    if !Katello.config.use_pulp
      ep = ErrataProcessor.new(url, latest_errata)
      errata = ep.refresh
      if !errata.empty?
        errata.each do |e|
          new_errata = from_json(e)
          new_errata.save_if_new
        end
      end
    end
  end

end
