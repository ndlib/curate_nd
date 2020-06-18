module RDF
  # This is an approximation of a refinement. At present it is perhaps not
  # adequate, but by marking the property as 'contributor#advisor' the
  # URL resolves to the DC Term 'contributor'
  class QualifiedDC < Vocabulary('http://purl.org/dc/terms/')
    property 'contributor#advisor'.to_sym
    property 'contributor#artist'.to_sym
    property 'contributor#author'.to_sym
    property 'contributor#curator'.to_sym
    property 'contributor#editor'.to_sym
    property 'contributor#illustrator'.to_sym
    property 'contributor#institution'.to_sym
    property 'contributor#photographer'.to_sym
    property 'contributor#repository'.to_sym
    property 'contributor#speaker'.to_sym
    property 'coverage#spatial'.to_sym
    property 'coverage#temporal'.to_sym
    property 'creator#administrative_unit'.to_sym
    property 'creator#affiliation'.to_sym
    property 'creator#artist'.to_sym
    property 'creator#author'.to_sym
    property 'creator#editor'.to_sym
    property 'creator#illustrator'.to_sym
    property 'creator#local'.to_sym
    property 'creator#organization'.to_sym
    property 'creator#photographer'.to_sym
    property 'creator#repository'.to_sym
    property 'date#approved'.to_sym
    property 'date#created'.to_sym
    property 'date#digitized'.to_sym
    property 'date#application'.to_sym
    property 'date#prior_publication'.to_sym
    property 'description#abstract'.to_sym
    property 'description#code_list'.to_sym
    property 'description#data_processing'.to_sym
    property 'description#file_structure'.to_sym
    property 'description#methodology'.to_sym
    property 'description#note'.to_sym
    property 'description#table_of_contents'.to_sym
    property 'description#technical'.to_sym
    property 'description#variable_list'.to_sym
    property 'extent#claims'.to_sym
    property 'format#extent'.to_sym
    property 'format#mimetype'.to_sym
    property 'identifier#doi'.to_sym
    property 'identifier#isbn'.to_sym
    property 'identifier#issn'.to_sym
    property 'identifier#local'.to_sym
    property 'identifier#other'.to_sym
    property 'identifier#patent'.to_sym
    property 'identifier#other_application'.to_sym
    property 'identifier#prior_publication'.to_sym
    property 'isVersionOf#edition'.to_sym
    property 'publisher#country'.to_sym
    property 'relation#ispartof'.to_sym
    property 'rights#permissions'.to_sym
    property 'subject#lcsh'.to_sym
    property 'subject#uspc'.to_sym
    property 'subject#cpc'.to_sym
    property 'subject#ipc'.to_sym
    property 'title#alternate'.to_sym
  end
end
