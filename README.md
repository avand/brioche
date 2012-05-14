# Brioche

The fun way to slice the bread.

## What is it?

A simple way to enter expenses into Google Docs from a text-message.

For example, if you texted:

* "35 Burgers with the team"
* "420.15 Hosting costs"

You would end up with this:

<table>
  <tr>
    <th>Description</th>
    <th>Date</th>
    <th>Amount</th>
  </tr>
  <tr>
    <td>Burgers with the team</td>
    <td>4/12/2012</td>
    <td>$35.00</td>
  </tr>
  <tr>
    <td>Hosting costs</td>
    <td>4/12/2012</td>
    <td>$420.15</td>
  </tr>
</table>

## Setup

1. Push this code up to a Heroku Cedar app.
2. Setup the following env variables (.env if you're using [Foreman][1]):
  * `GOOGLE_EMAIL`: The email address associated with your Google account.
  * `GOOGLE_PASSWORD`: The password for your Google account.
  * `TWILIO_ACCOUNT_SID`: Available on your Twilio dashboard.
  * `TWILIO_AUTH_TOKEN`: Keep this a secret.
  * `SPREADSHEET_KEY`: Grab this from the URL to the Google Doc spreadsheet.
  * `WORKSHEET_INDEX`: The index (0-based) of the worksheet.
  * Make sure you don't add these files to your git repo!
2. Register a Twilio number.
3. Point the SMS URL for that number to http://your-app.herokuapp.com/expenses.
4. Send a text to the number in the format: "\<amount\> \<description\>".

[1]: https://devcenter.heroku.com/articles/procfile#developing_locally_with_foreman
