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
    ## Create BookContainers for each book chapter and page.
    ##

    book_containers = ecosystem_info.fetch(:book).fetch(:contents).map{ |page_module|
        BookContainer.new(
            ecosystem_uuid: ecosystem_info.fetch(:ecosystem_uuid),
            container_uuid: page_module.fetch(:container_uuid),
        )
    }

    created_ecosystem_uuids = BookContainer.transaction(isolation: :read_committed) do
        BookContainer.import book_containers, on_duplicate_key_ignore: true

        Utils::RecordEcosystemEvents::Util.new.process(ecosystem_events: [ecosystem_event])
    end

    return {created_ecosystem_uuid: created_ecosystem_uuids.first}
  end
end
