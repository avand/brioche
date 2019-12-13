require "sinatra"
require "google_drive"
require "twilio-ruby"
require "mail"
require "csv"
require "down"
require "dotenv"
Dotenv.load

client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
client_secret = StringIO.new(Base64.decode64(ENV['GDRIVE_AUTH']))

post "/expenses" do
  to_number   = params["To"]
  from_number = params["From"]

  text  = params["Body"]

  if text.match(/^(\S*)(m|M|d|D|h|H)(.*)/)
    match = text.match(/^(\S*)(m|M|d|D|h|H)(.*)/)

    expamount   = match[1].to_f
    exptype     = match[2].strip
    expitem     = match[3].strip
    date        = Time.now.strftime("%-m/%-d/%Y")

    session     = GoogleDrive::Session.from_service_account_key(client_secret)
    spreadsheet = session.spreadsheet_by_key(ENV["SPREADSHEET_KEY"])
    worksheet   = spreadsheet.worksheets[0]
    row         = worksheet.num_rows + 1

    worksheet[row, 2] = expitem
    worksheet[row, 3] = exptype
    worksheet[row, 4] = expamount
    worksheet[row, 5] = date
    worksheet[row, 6] = from_number

    worksheet.save()

    if exptype == "m" || exptype == "M"
      confirmation = "Drove #{expamount} miles on #{date} to/from #{expitem}"
    elsif exptype == "d" || exptype == "D"
      confirmation = "Spent #{expamount} dollars on #{date} at/on #{expitem}"
    elsif exptype == "h" || exptype == "H"
      confirmation = "Worked #{expamount} hours on #{date} for #{expitem}"
    else
      confirmation = "Unknown expense type, please try again"
    end
  else
    confirmation = "Unknown command, please try again"
  end

  client.messages.create(
    from: to_number,
    to:   from_number,
    body: confirmation
  ) if to_number && from_number
end

get "/expenses/send" do
  $recipients = params["recipients"]

  if request.params.count > 0
    stamp = Time.now.strftime('%Y-%m-%d-')
    $attachfile = stamp + 'expenses.csv'
    expfile = Down.download(ENV['EXP_QUERY'])
    exptable = CSV.parse(expfile, :headers => true)
    sumfile = Down.download(ENV['SUM_QUERY'])
    sumtable = CSV.foreach(sumfile, :headers => true, header_converters: :symbol, :converters => :float) do |row|
        expensesum = row[0].to_f.round(2)
        exptable << ["Total","","","","","$" + expensesum.to_s]
        tempfile = File.new($attachfile,"w")
        tempfile << exptable
        tempfile.close
    end

    def mailsender
        Mail.defaults do
          delivery_method :smtp, {
            :address => 'email-smtp.us-east-1.amazonaws.com',
            :port => 465,
            :user_name => ENV['AWS_SMTP_USER'],
            :password => ENV['AWS_SMTP_PASSWORD'],
            :authentication => :plain,
            :tls => true
          }
        end

        Mail.deliver do
          from     ENV['AWS_SMTP_FROM']
          to       $recipients
          subject  ENV['SMTP_BODY']
          body     ENV['SMTP_SUBJECT']
          add_file $attachfile
        end
    end

    # Send expense report if exists
    if File.file?('*expenses.csv')
      puts mailsender
    else
      return 'No expenses file found'
    end

    # Delete csv file after send
    File.delete($attachfile)
    return 'Message sent to ' + $recipients

  else
    return 'Missing email recipient'
  end

end
