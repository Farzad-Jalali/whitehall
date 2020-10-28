class DocumentListExportWorker < WorkerBase
  def perform(filter_options, user_id)
    user = User.find(user_id)
    filter = create_filter(filter_options, user)

    Tempfile.open("document_list_export_worker") do |file|
      file.unlink
      csv = generate_csv(filter, file)
      public_url = upload_file(csv, filter_options[:type])
      send_mail(public_url, user, filter)
    end
  end

private

  def send_mail(csv_filename, user, filter)
    MailNotifications.document_list(csv_filename, user.email, filter.page_title).deliver_now
  rescue Notifications::Client::BadRequestError
    render plain: "Error: One or more recipients not in GOV.UK Notify team (code: 400)", status: :bad_request
  end

  def upload_file(csv, type)
    export_id = SecureRandom.uuid
    document_type_slug = if type.present?
                           type.downcase.gsub(%r{[^a-z0-9]+}, "_")
                         else
                           "documents"
                         end

    filename = DocumentListExportPresenter.s3_filename(document_type_slug, export_id)
    S3FileHandler.save_file_to_s3(filename, csv)
    Plek.find("whitehall-admin", external: true) + "/export/#{document_type_slug}/#{export_id}"
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
