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
    ## Delegate to the CourseEvent recording service, which handles
    ## the details of transaction isolation, locks, etc.
    ##

    created_ecosystem_uuids = Services::RecordEcosystemEvents::Service.new.process(ecosystem_events: [ecosystem_event])

    return {created_ecosystem_uuid: created_ecosystem_uuids.first}

    # book_container_attributes = book.fetch(:contents).map do |content|
    #   { uuid: content.fetch(:container_uuid), ecosystem_uuid: ecosystem_uuid }
    # end

    # EcosystemEvent.transaction do
    #   BookContainer.append book_container_attributes

    #   EcosystemEvent.append(
    #     uuid: ecosystem_uuid,
    #     type: :create_ecosystem,
    #     ecosystem_uuid: ecosystem_uuid,
    #     sequence_number: 0,
    #     data: {
    #       ecosystem_uuid: ecosystem_uuid,
    #       sequence_number: 0,
    #       book: book,
    #       exercises: exercises,
    #       imported_at: imported_at
    #     }
    #   )
    # end

    # { created_ecosystem_uuid: ecosystem_uuid }
  end
end
