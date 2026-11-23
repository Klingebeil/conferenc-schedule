#import "template/vendor/template.typ": schedule-page, schedule-row, colors, page-style
#import "template/vendor/schedule-data.typ": load-schedule

#let conference-schedule = csv("conference-schedule.csv") // Path the conference schedule CSV file
#let speaker-list = csv("speaker-list.csv") // Path to the speaker list CSV file
#let conference-name = "Conference Name"

#let schedule = load-schedule(conference-schedule, speaker-list)
#let dates = schedule.dates

#let template = (
  show-times: true,
  show-room: true,
  show-speakers: true,
  show-speaker-images: true,
  show-subtitles: true,
  show-description: true
)

#let events-by-starttime(events) = {
  let starttimes = events.map(event => event.starttime).dedup()
  starttimes.map(starttime => events.filter(event => event.starttime == starttime))
}

#set page(
  paper: "a3",
  flipped: false,
  margin: (x: 1.5cm, y: 1.25cm),
  fill: colors.paper,
)

#set text(font: page-style.font, size: page-style.a3.text-size, fill: colors.ink)
#set par(leading: page-style.a3.leading)

#for (day-index, date) in dates.enumerate() [
  #let day-events = schedule.events.filter(event => event.date == date)
  #schedule-page(date, first: day-index == 0)[
    = #conference-name 
    == Tag #(day-index + 1) #h(2em) #date
    #v(2em, weak: true)
    #for slot-events in events-by-starttime(day-events) [
      #line(length: 100%, stroke: 0.5pt)
      #schedule-row(slot-events, template: template)
    ]
  ]
]
