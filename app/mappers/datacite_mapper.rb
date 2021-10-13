# frozen_string_literal: true

class DataciteMapper
  def self.call(curation_concern)
    {
      "data": {
        "id": "#{ENV.fetch('DOI_SHOULDER')}/#{curation_concern.noid}",
        "type": 'dois',
        "attributes": {
          "event": 'publish',
          "doi": "#{ENV.fetch('DOI_SHOULDER')}/#{curation_concern.noid}",
          "publisher": I18n.t('sufia.institution_name'),
          "creators": [{
            "name": curation_concern.creator
          }],
          "titles": [{
            "title": curation_concern.title
          }],
          "publicationYear": curation_concern.date_uploaded.year,
          "types": {
            "resourceType": 'CreativeWork',
            "resourceTypeGeneral": 'Other'
          },
          "url": Curate.permanent_url_for(curation_concern)
        }
      }
    }
  end
end
