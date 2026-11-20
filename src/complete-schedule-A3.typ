#import "template/vendor/template.typ": a3-program, schedule-page, schedule-row
#import "template/vendor/schedule-data.typ": load-schedule

#let schedule = load-schedule()
#let dates = schedule.dates

#let events-by-starttime(events) = {
  let starttimes = events.map(event => event.starttime).dedup()
  starttimes.map(starttime => events.filter(event => event.starttime == starttime))
}

#show: a3-program

#for (day-index, date) in dates.enumerate() [
  #let day-events = schedule.events.filter(event => event.date == date)
  #schedule-page(date, "Full conference program", first: day-index == 0)[
    #for slot-events in events-by-starttime(day-events) [
      #let workshops = slot-events.filter(event => event.type == "Workshop")
      #let other-events = slot-events.filter(event => event.type != "Workshop")
      #schedule-row(workshops)
      #for event in other-events [
        #schedule-row((event,))
      ]
    ]
  ]
]
