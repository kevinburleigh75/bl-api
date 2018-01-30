class Services::CreateEcosystem::Service
  def process(ecosystem_info:)
    ##
    ## Convert the ecosystem attributes to an EcosystemEvent.
    ##

    ecosystem_event = EcosystemEvent.new(
      event_uuid:             ecosystem_info.fetch(:ecosystem_uuid),
      event_type:             EcosystemEvent.event_type.create_ecosystem,
      event_has_been_bundled: false,
      ecosystem_uuid:         ecosystem_info.fetch(:ecosystem_uuid),
      ecosystem_seqnum:       0,
      event_data: ecosystem_info.slice(
        :ecosystem_uuid,
        :book,
        :exercises,
        :imported_at,
      ),
    )

    ##
    ## Create a block that creates BookContainers for each book
    ## chapter and page.
    ##

    block = lambda {
        book_containers = ecosystem_info.fetch(:book).fetch(:contents).map{ |page_module|
            BookContainer.new(
                ecosystem_uuid: ecosystem_info.fetch(:ecosystem_uuid),
                container_uuid: page_module.fetch(:container_uuid),
            )
        }

        BookContainer.import book_containers, on_duplicate_key_ignore: true
    }

    ##
    ## Delegate to the CourseEvent recording service, which handles
    ## the details of transaction isolation, locks, etc.
    ##

    created_ecosystem_uuids = Services::RecordEcosystemEvents::Service.new.process(ecosystem_events: [ecosystem_event], &block)

    return {created_ecosystem_uuid: created_ecosystem_uuids.first}
  end
end
