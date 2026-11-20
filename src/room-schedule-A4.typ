#import "template/vendor/template.typ": a4-program, schedule-page, schedule-row
#import "template/vendor/schedule-data.typ": load-schedule

#let schedule = load-schedule()

#let room-pages(schedule) = {
  schedule.dates.map(date => {
    schedule.rooms
    .filter(room => schedule.events.any(event => event.date == date and event.room == room))
    .map(room => (date: date, room: room))
  }).flatten()
}

#show: a4-program

#for (page-index, page-info) in room-pages(schedule).enumerate() [
  #let page-events = schedule.events.filter(
    event => event.date == page-info.date and event.room == page-info.room,
  )
  #schedule-page(page-info.date, page-info.room, first: page-index == 0)[
    #for event in page-events [
      #schedule-row((event,))
    ]
  ]
]
