require "sinatra"
require "google_drive"
require "twilio-ruby"
require 'dotenv'
Dotenv.load

client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

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

    session     = GoogleDrive::Session.from_config("config.json")
    spreadsheet = session.spreadsheet_by_key(ENV["SPREADSHEET_KEY"])
    worksheet   = spreadsheet.worksheets[ENV["WORKSHEET_INDEX"].to_i]
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