#import "vendor/template.typ": a4-program, schedule-page, schedule-row
#import "vendor/schedule-data.typ": load-schedule

#let conference-schedule = csv("conference-schedule.csv") // Path the conference schedule CSV file
#let speaker-list = csv("speaker-list.csv") // Path to the speaker list CSV file
#let conference-name = "Conference Name"

#let template = (
  show-times: true,
  show-room: false,
  show-speakers: true,
  show-subtitles: true,
  show-description: true,
  show-speaker-images: true,
)

#let schedule = load-schedule(conference-schedule, speaker-list)
#let dates = schedule.dates

#let room-pages(schedule) = {
  schedule.dates.map(date => {
    schedule.rooms
    .filter(room => schedule.events.any(event => event.date == date and event.room == room))
    .map(room => (date: date, room: room))
  }).flatten()
}

#show: a4-program

#for (page-index, page-info) in room-pages(schedule).enumerate() [
  #if page-index > 0 [
    #pagebreak()
  ]
  = #page-info.room #(page-info.date)
  #v(2em, weak: true)
  #let page-events = schedule.events.filter(
    event => event.date == page-info.date and event.room == page-info.room,
  )
  #for event in page-events [
    #line(length: 100%, stroke: 0.5pt)
    #schedule-row((event,), template: template)
  ]
]
