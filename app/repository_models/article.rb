class Article < ActiveFedora::Base
  include ActiveModel::Validations
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include CurationConcern::WithJsonMapper

  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: ArticleMetadataDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit or reference a preprint or published article."

  self.indefinite_article = 'an'
  self.contributor_label = 'Author'

  attribute :title,
    datastream: :descMetadata, multiple: false,
    label: "Title of your Article",
    validates: { presence: { message: 'Your article must have a title.' } }
  attribute :alternate_title,
    datastream: :descMetadata, multiple: true
  attribute :creator, datastream: :descMetadata, multiple: true, validates: { multi_value_presence: true }
  attribute :affiliation,datastream: :descMetadata, hint: "Creator's Affiliation to the Institution.", multiple: false
  attribute :organization,
    datastream: :descMetadata, multiple: true,
    label: "Organization",
    hint: "Organizations which creators belong to."
  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."
  attribute :contributor,
    datastream: :descMetadata, multiple: true,
    label: "Contributing Author(s)",
    hint: "Who else played a non-primary role in the creation of your Article."
  attribute :repository_name,
    datastream: :descMetadata, multiple: true,
    label: "Repository Name",
    hint: "The physical location of the materials."
  attribute :contributor_institution,
    datastream: :descMetadata, multiple: true,
    label: "Contributor Institution",
    hint: "The Institution that is contributing the item to the repository."
  attribute :collection_name,
    datastream: :descMetadata, multiple: true,
    label: "Collection Name",
    hint: "The name of the collection that is being digitized."
  attribute :abstract,
    label: "Abstract or Summary of the Article",
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your Article must have an abstract.' } }
  attribute :content_format,
    label: "Content Format",
    datastream: :descMetadata, multiple: false
  attribute :is_part_of,
    label: "Journal or Other Work Title",
    hint: "The title of the journal or other work in which the article was published.",
    datastream: :descMetadata, multiple: false
  attribute :recommended_citation,
    label: "Recommended Citation",
    datastream: :descMetadata, multiple: true
  attribute :date_created,
    default: lambda { Date.today.to_s("%Y-%m-%d") },
    label: "When did your finish your Article",
    hint: "This does not need to be exact, but your best guess.",
    datastream: :descMetadata, multiple: false
  attribute :publication_date,
    datastream: :descMetadata, multiple: false,
            validates: {
              allow_blank: true,
              format: {
                with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
                message: 'Must be a four-digit year or year-month/year-month-day formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
              }
            }
  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false
  attribute :date_modified,
    datastream: :descMetadata, multiple: false
  attribute :volume,
    hint: "The number or name of the volume in which the article was published.",
    datastream: :descMetadata, multiple: false
  attribute :issue,
    hint: "The number or name of the issue in which the article was published.",
    datastream: :descMetadata, multiple: false
  attribute :page_start,
    hint: "The first page on which your article appears.",
    datastream: :descMetadata, multiple: false
  attribute :page_end,
    hint: "The last page on which your article appears.",
    datastream: :descMetadata, multiple: false
  attribute :num_pages,
    hint: "The number of pages in your article.",
    datastream: :descMetadata, multiple: false,
      validates: {
        allow_blank: true,
        format: {
          with: /\A\d{1,}\Z/,
          message: 'Must be a number.'
        }
      }
  attribute :isbn,
    hint: "If your article was published in a volume with an ISBN, include that here.",
    datastream: :descMetadata, multiple: false
  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :subject,
    label: "Keyword(s) or phrase(s)",
    hint: "What words or phrases would be helpful for someone searching for your Article",
    datastream: :descMetadata, multiple: true
  attribute :language,
    hint: "What is the language(s) in which you wrote your work?",
    default: ['English'],
    datastream: :descMetadata, multiple: true
  attribute :publisher,
    datastream: :descMetadata, multiple: true
  attribute :spatial_coverage,
    datastream: :descMetadata, multiple: false
  attribute :temporal_coverage,
    datastream: :descMetadata, multiple: false
  attribute :issn,
    datastream: :descMetadata, multiple: false,
    editable: true
  attribute :eIssn,
    hint: "The electronic ISSN, or eISSN of the publication in which the article appeared.",
    datastream: :descMetadata, multiple: false
  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :relation,
    hint: "Link to External Content",
    datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        format: {
            with: URI::regexp(%w(http https ftp)),
            message: 'must be a valid URL.'
        }
    }

  attribute :requires,
    datastream: :descMetadata, multiple: true

  attribute :size,
    datastream: :descMetadata, multiple: true

  attribute :alephIdentifier, multiple: true,
    datastream: :descMetadata,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }

  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
