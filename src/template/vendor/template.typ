#let conference-name = "Conference Name"

#let colors = (
  ink: rgb("#182333"),
  muted: rgb("#526174"),
  paper: rgb("#FFFFFF"),
  line: rgb("#D9E1EA"),
  accent: rgb("#175C78"),
  talk: rgb("#EAF3F7"),
  workshop: rgb("#F0F1FA"),
  pause: rgb("#F5F2E9"),
)

#let page-style = (
  a3: (margin: (x: 1.4cm, y: 1.25cm), text-size: 10pt, leading: 0.65em),
  a4: (margin: (x: 1.5cm, y: 1.4cm), text-size: 11pt, leading: 0.7em),
  font: "Helvetica Neue",
)

#let speaker-style = (
  image-size: 3.2em,
  image-column: 3.4em,
  column-gutter: 0.6em,
  row-gutter: 0.25em,
  spacing: 0.35em,
)

#let card-style = (
  inset: 0.8em,
  accent-width: 3pt,
  time-column: 5.4em,
  column-gutter: 0.8em,
  time-spacing: 0.2em,
  start-size: 0.92em,
  end-size: 0.82em,
  type-size: 0.76em,
  title-size: 1.15em,
  subtitle-size: 0.95em,
  description-size: 0.88em,
  room-size: 0.8em,
  title-spacing: 0.15em,
  description-spacing: 0.3em,
  detail-spacing: 0.35em,
)

#let schedule-style = (
  column-gutter: 0.8em,
  row-gutter: 0.65em,
  row-spacing: 0.65em,
  heading-size: 2em,
  date-size: 1.25em,
  heading-spacing: 0.8em,
)

#let a3-program(body) = {
  set page(
    paper: "a3",
    flipped: false,
    margin: page-style.a3.margin,
    fill: colors.paper,
  )
  set text(font: page-style.font, size: page-style.a3.text-size, fill: colors.ink)
  set par(leading: page-style.a3.leading)
  body
}

#let a4-program(body) = {
  set page(
    paper: "a4",
    flipped: false,
    margin: page-style.a4.margin,
    fill: colors.paper,
  )
  set text(font: page-style.font, size: page-style.a4.text-size, fill: colors.ink)
  set par(leading: page-style.a4.leading)
  body
}

#let speaker-portrait(speaker) = {
  let size = speaker-style.image-size
  if speaker.image-path != "" {
    image("../../" + speaker.image-path, width: size, height: size, fit: "cover")
  } else {
    box(width: size, height: size, fill: colors.line)[]
  }
}

#let speaker-line(speakers) = {
  for (index, speaker) in speakers.enumerate() [
    #grid(
      columns: (speaker-style.image-column, 1fr),
      column-gutter: speaker-style.column-gutter,
      row-gutter: speaker-style.row-gutter,
      speaker-portrait(speaker),
      [
        #strong(speaker.full-name)
        #if speaker.title != "" [ · #speaker.title]
        #linebreak()
        #if speaker.job-title != "" [#speaker.job-title]
        #if speaker.job-title != "" and speaker.employer != "" [ · ]
        #if speaker.employer != "" [#speaker.employer]
      ],
    )
    #if index < speakers.len() - 1 [#v(speaker-style.spacing)]
  ]
}

#let event-card(event, tint) = {
  block(
    width: 100%,
    fill: tint,
    inset: card-style.inset,
    stroke: (left: card-style.accent-width + colors.accent),
  )[
    #grid(
      columns: (card-style.time-column, 1fr),
      column-gutter: card-style.column-gutter,
      [
        #stack(
          spacing: card-style.time-spacing,
          text(size: card-style.start-size, weight: "bold")[#event.starttime],
          text(size: card-style.end-size, fill: colors.muted)[to #event.endtime],
        )
      ],
      [
        #text(size: card-style.type-size, weight: "bold", fill: colors.accent)[#upper(event.type)]
        #v(card-style.title-spacing)
        #text(size: card-style.title-size, weight: "bold")[#event.title]
        #if event.subtitle != "" [
          #linebreak()
          #text(size: card-style.subtitle-size, fill: colors.muted)[#event.subtitle]
        ]
        #if event.description != "" [
          #v(card-style.description-spacing)
          #text(size: card-style.description-size)[#event.description]
        ]
        #v(card-style.detail-spacing)
        #text(size: card-style.room-size, weight: "bold", fill: colors.muted)[#event.room]
        #v(card-style.detail-spacing)
        #speaker-line(event.speakers)
      ],
    )
  ]
}

#let talk-block(event) = event-card(event, colors.talk)
#let workshop-block(event) = event-card(event, colors.workshop)
#let pause-block(event) = event-card(event, colors.pause)

#let schedule-event(event) = {
  if event.type == "Workshop" {
    workshop-block(event)
  } else if event.type == "Pause" {
    pause-block(event)
  } else {
    talk-block(event)
  }
}

#let schedule-row(events) = [
  #if events.len() == 1 [
    #schedule-event(events.first())
  ] else if events.len() > 1 [
    #grid(
      columns: events.len(),
      column-gutter: schedule-style.column-gutter,
      row-gutter: schedule-style.row-gutter,
      ..events.map(schedule-event),
    )
  ]
  #if events.len() > 0 [#v(schedule-style.row-spacing)]
]

#let day-heading(date, subtitle) = [
  #text(size: schedule-style.heading-size, weight: "bold", fill: colors.ink)[#conference-name]
  #linebreak()
  #text(size: schedule-style.date-size, fill: colors.accent)[#date]
  #if subtitle != "" [ · #subtitle]
  #v(schedule-style.heading-spacing)
]

#let schedule-page(date, subtitle, first: false, body) = [
  #if not first [#pagebreak()]
  #day-heading(date, subtitle)
  #body
]
