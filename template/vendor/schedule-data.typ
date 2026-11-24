#let expected-schedule-header = "Date,Starttime,Endtime,Type,Titel,Untertitel,Beschreibung,Raum,Speaker"
#let expected-speaker-header = "Name,Nachname,Title,Jobtitel,Arbeitgeber,Image-path"

#let validate-date(event-date) = {
  assert(
    event-date.matches(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")).len() == 1,
    message: "Invalid Date; use YYYY-MM-DD.",
  )
  let (year, month, day) = event-date.split("-").map(int)
  assert(year > 0, message: "Date is not a valid calendar date.")
  let date = datetime(year: year, month: month, day: day)
}

#let load-schedule(schedule-csv, speaker-csv) = {
  let schedule-rows =schedule-csv
  let speaker-rows = speaker-csv

  assert(
    schedule-rows.len() > 1,
    message: "Conference Schedule must contain a header and at least one event.",
  )
  assert(
    schedule-rows.first().join(",") == expected-schedule-header,
    message: "Conference Schedule has unexpected columns or column order.",
  )
  assert(
    speaker-rows.len() > 0 and speaker-rows.first().join(",") == expected-speaker-header,
    message: "Speaker List has unexpected columns or column order.",
  )
  assert(
    schedule-rows.slice(1).all(row => row.len() == 9),
    message: "Every Conference Schedule row must contain exactly 9 fields (" + expected-schedule-header + ").",
  )
  assert(
    speaker-rows.slice(1).all(row => row.len() == 6),
    message: "Every Speaker List row must contain exactly 6 fields (" + expected-speaker-header + ").",
  )

  let speakers = speaker-rows.slice(1).map(row => (
    full-name: (row.at(0) + " " + row.at(1)).trim(),
    title: row.at(2).trim(),
    job-title: row.at(3).trim(),
    employer: row.at(4).trim(),
    image-path: row.at(5).trim(),
  ))

  let events = schedule-rows.slice(1).map(row => {
    let event-date = row.at(0).trim()
    let starttime = row.at(1).trim()
    let endtime = row.at(2).trim()
    let event-type = row.at(3).trim()
    let title = row.at(4).trim()
    let room = row.at(7).trim()
    let names = if row.at(8).trim() == "" {
      ()
    } else {
      row.at(8).split("|").map(name => name.trim()).filter(name => name != "")
    }

    validate-date(event-date)
    assert(
      starttime.matches(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$")).len() == 1
        and endtime.matches(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$")).len() == 1,
      message: "Invalid Starttime or Endtime; use 24-hour HH:MM.",
    )
    assert(
      event-type != "",
      message: "Type must not be empty.",
    )
    assert(title != "" and room != "", message: "Every event needs a Titel and Raum.")

    let resolved-speakers = names.map(name => {
      let matches = speakers.filter(speaker => speaker.full-name == name)
      if matches.len() == 1 {
        matches.first()
      } else if matches.len() == 0 {
        (
          full-name: name + " (Speaker not found)",
          title: "",
          job-title: "",
          employer: "",
          image-path: "",
        )
      } else {
        (
          full-name: name + " (ambiguous speaker name)",
          title: "",
          job-title: "",
          employer: "",
          image-path: "",
        )
      }
    })

    (
      date: event-date,
      starttime: starttime,
      endtime: endtime,
      type: event-type,
      title: title,
      subtitle: row.at(5).trim(),
      description: row.at(6).trim(),
      room: room,
      speakers: resolved-speakers,
    )
  }).sorted(key: event => event.date + event.starttime + event.room)

  assert(
    events.all(event => event.starttime < event.endtime),
    message: "Each event must end after it starts; overnight events are not supported.",
  )

  (
    events: events,
    dates: events.map(event => event.date).dedup(),
    rooms: events.map(event => event.room).sorted().dedup(),
  )
}

#let get-day-tag(date, dates) = {
  let day-index = dates.position(d => d == date)
  "Tag " + str(day-index + 1)
}
