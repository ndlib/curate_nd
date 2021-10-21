# frozen_string_literal: true

class DataciteMapper
  def self.call(curation_concern)
    {
      "data": {
        "id": "#{Figaro.env.doi_shoulder}/#{curation_concern.noid}",
        "type": 'dois',
        "attributes": {
          "event": 'publish',
          "doi": "#{Figaro.env.doi_shoulder}/#{curation_concern.noid}",
          "publisher": I18n.t('sufia.institution_name'),
          "creators": [{
            "name": Array.wrap(curation_concern.creator).collect(&:to_s).join(", ")
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
