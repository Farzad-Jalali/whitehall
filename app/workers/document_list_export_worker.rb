class DocumentListExportWorker < WorkerBase
  def perform(filter_options, user_id)
    user = User.find(user_id)
    filter = create_filter(filter_options, user)

    Tempfile.open("document_list_export_worker") do |file|
      file.unlink
      csv = generate_csv(filter, file)
      send_mail(csv, user, filter)
    end
  end

private

  def send_mail(csv, user, filter)
    MailNotifications.document_list(csv, user.email, filter.page_title).deliver_now
  end

  def create_filter(filter_options, user)
    Admin::EditionFilter.new(
      Edition,
      user,
      filter_options.symbolize_keys.merge(
        include_unpublishing: true,
        include_locked_documents: false,
      ),
    )
  end

  def generate_csv(filter, csv_file)
    headers = DocumentListExportPresenter.header_row
    csv = CSV.new(csv_file, headers: headers, write_headers: true)

    filter.each_edition_for_csv do |edition|
      presenter = DocumentListExportPresenter.new(edition)
      csv << presenter.row
    end

    csv_file.rewind
    csv_file.read
  end
end
